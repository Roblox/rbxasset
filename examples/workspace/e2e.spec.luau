local frktest = require("@pkg/frktest")
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")

local test = frktest.test
local check = frktest.assert.check

local ROOT_PATH = "examples/workspace"
local MANIFEST_PATH = `{ROOT_PATH}/rbxasset.toml`

local apiKey = process.env.ROBLOX_API_KEY
assert(apiKey, "End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local packageAssetId = lockfile.assets.package.assetId
local pluginAssetId = lockfile.assets.plugin.assetId

local function appendTextForTesting(path: string, text: string)
	local content = fs.readFile(path)
	content ..= text
	fs.writeFile(path, content)
end

process.exec("rojo", { "build", "-o", "plugin.rbxm" }, {
	cwd = ROOT_PATH,
})

test.case("uploads each workspace member to the Creator Store", function()
	local packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	local pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	local prevPackageRevisionId = packageAssetDetails.revisionId
	local prevPluginRevisionId = pluginAssetDetails.revisionId

	local filesToChange = {
		`{ROOT_PATH}/package/src/init.luau`,
		`{ROOT_PATH}/plugin/src/init.plugin.luau`,
	}

	for _, path in filesToChange do
		appendTextForTesting(path, `\nprint("New!")`)
	end

	process.exec("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	process.exec("git", { "restore", table.unpack(filesToChange) })

	packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	check.not_equal(packageAssetDetails.revisionId, prevPackageRevisionId)
	check.not_equal(pluginAssetDetails.revisionId, prevPluginRevisionId)
end)

test.case("text fields in rbxasest.toml get mirrored to the asset details", function()
	local packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	local pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	local manifest = readManifest(ROOT_PATH)

	local id = math.random(1, 1e10)

	manifest.assets.package.name = `{manifest.assets.package.name}\n({id})`
	manifest.assets.package.description = `{manifest.assets.package.description}\n({id})`

	manifest.assets.plugin.name = `{manifest.assets.plugin.name}\n({id})`
	manifest.assets.plugin.description = `{manifest.assets.plugin.description}\n({id})`

	fs.writeFile(MANIFEST_PATH, serde.encode("toml", manifest))

	process.exec("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	process.exec("git", { "restore", MANIFEST_PATH })

	packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	check.equal(packageAssetDetails.displayName, manifest.assets.package.name)
	check.equal(packageAssetDetails.description, manifest.assets.package.description)

	check.equal(pluginAssetDetails.displayName, manifest.assets.plugin.name)
	check.equal(pluginAssetDetails.description, manifest.assets.plugin.description)
end)

test.case("only publishes a new version for changed workspace members", function()
	local packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	local pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	local prevPackageRevisionId = packageAssetDetails.revisionId
	local prevPluginRevisionId = pluginAssetDetails.revisionId

	-- We make a change to a single workspace member so we can verify that only
	-- that member was given a new revision after publishing
	local path = `{ROOT_PATH}/package/src/init.luau`
	appendTextForTesting(path, `\nprint("New!")`)

	process.exec("lune", { "run", "deploy.luau", apiKey }, {
		cwd = ROOT_PATH,
	})

	process.exec("git", { "restore", path })

	packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	check.not_equal(packageAssetDetails.revisionId, prevPackageRevisionId)
	check.equal(pluginAssetDetails.revisionId, prevPluginRevisionId)
end)
