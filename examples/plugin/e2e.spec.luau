local frktest = require("@pkg/frktest")
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")

local test = frktest.test
local check = frktest.assert.check

local ROOT_PATH = "examples/plugin"
local MANIFEST_PATH = `{ROOT_PATH}/rbxasset.toml`

local apiKey = process.env.ROBLOX_API_KEY
assert(apiKey, "End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local assetId = lockfile.assets.plugin.assetId

process.exec("rojo", { "build", "-o", "plugin.rbxm" }, {
	cwd = ROOT_PATH,
})

test.case("uploads to the Creator Store", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)

	local prevRevisionId = assetDetails.revisionId

	local path = `{ROOT_PATH}/src/init.plugin.luau`
	local content = fs.readFile(path)
	content ..= `\nprint("New!")`
	fs.writeFile(path, content)

	process.exec("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	process.exec("git", { "restore", path })

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	check.not_equal(assetDetails.revisionId, prevRevisionId)
end)

test.case("text fields in rbxasest.toml get mirrored to the asset details", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)
	local prevRevisionId = assetDetails.revisionId

	local manifest = readManifest(ROOT_PATH)

	local id = math.random(1, 1e10)
	manifest.assets.plugin.name = `{manifest.assets.plugin.name}\n({id})`
	manifest.assets.plugin.description = `{manifest.assets.plugin.description}\n({id})`

	fs.writeFile(MANIFEST_PATH, serde.encode("toml", manifest))

	process.exec("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	process.exec("git", { "restore", MANIFEST_PATH })

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	check.equal(assetDetails.displayName, manifest.assets.plugin.name)
	check.equal(assetDetails.description, manifest.assets.plugin.description)
	check.not_equal(assetDetails.revisionId, prevRevisionId)
end)

test.case("does not publish a new version when there are no changes", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)

	local prevRevisionId = assetDetails.revisionId

	process.exec("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	check.equal(assetDetails.revisionId, prevRevisionId)
end)
