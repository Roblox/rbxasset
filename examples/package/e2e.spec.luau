local frktest = require("@pkg/frktest")
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")
local run = require("@root/lib/run")

local test = frktest.test
local check = frktest.assert.check

local ROOT_PATH = "examples/package"
local MANIFEST_PATH = `{ROOT_PATH}/rbxasset.toml`

local function appendTextForTesting(path: string, text: string)
	local content = fs.readFile(path)
	content ..= text
	fs.writeFile(path, content)
end

local apiKey = process.env.ROBLOX_API_KEY
assert(apiKey, "End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local assetId = lockfile.assets.package.assetId

run("rojo", { "build", "-o", "asset.rbxm" }, {
	cwd = ROOT_PATH,
})

test.case("uploads rbxm to the Creator Store", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)
	local prevRevisionId = assetDetails.revisionId

	local path = `{ROOT_PATH}/src/init.luau`
	appendTextForTesting(path, `\nprint("New!")`)

	local success, result = pcall(function()
		run("lune", { "run", "deploy.luau", apiKey }, {
			cwd = ROOT_PATH,
		})
	end)

	run("git", { "restore", path })

	assert(success, result)

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	check.not_equal(assetDetails.revisionId, prevRevisionId)
end)

test.case("text fields in rbxasest.toml get mirrored to the asset details", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)
	local prevRevisionId = assetDetails.revisionId

	local manifest = readManifest(ROOT_PATH)

	local id = os.time()
	manifest.assets.package.name = `{manifest.assets.package.name}\n({id})`
	manifest.assets.package.description = `{manifest.assets.package.description}\n({id})`

	fs.writeFile(MANIFEST_PATH, serde.encode("toml", manifest))

	run("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	run("git", { "restore", MANIFEST_PATH })

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	check.equal(assetDetails.displayName, manifest.assets.package.name)
	check.equal(assetDetails.description, manifest.assets.package.description)
	check.not_equal(assetDetails.revisionId, prevRevisionId)
end)

test.case("does not publish a new version when there are no changes", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)

	local prevRevisionId = assetDetails.revisionId

	run("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	check.equal(assetDetails.revisionId, prevRevisionId)
end)
