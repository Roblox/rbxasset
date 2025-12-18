local expect = require("@std/test/assert")
local fs = require("@lute/fs")
local process = require("@lute/process")
local test = require("@std/test")
local toml = require("@root/lib/toml")

local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")
local run = require("@root/lib/run")

local ROOT_PATH = "examples/workspace"
local MANIFEST_PATH = `{ROOT_PATH}/rbxasset.toml`

local apiKey = process.env.ROBLOX_API_KEY
assert(apiKey, "End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local packageAssetId = lockfile.assets.package.assetId
local pluginAssetId = lockfile.assets.plugin.assetId

local function appendTextForTesting(path: string, text: string)
	local handle = fs.open(path, "w+")
	local content = fs.read(handle)
	content ..= text
	fs.write(handle, content)
	fs.close(handle)
end

run("rojo", { "build", `plugin/default.project.json`, "-o", "plugin.rbxm" }, {
	cwd = ROOT_PATH,
})
run("rojo", { "build", `package/default.project.json`, "-o", "package.rbxm" }, {
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

	local success, result = pcall(function()
		return run("lute", { "deploy.luau", apiKey }, {
			cwd = ROOT_PATH,
		})
	end)

	run("git", { "restore", table.unpack(filesToChange) })

	assert(success, result)

	packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	expect.neq(packageAssetDetails.revisionId, prevPackageRevisionId)
	expect.neq(pluginAssetDetails.revisionId, prevPluginRevisionId)
end)

test.case("text fields in rbxasest.toml get mirrored to the asset details", function()
	local packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	local pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	local manifest = readManifest(ROOT_PATH)

	local id = os.time()

	manifest.assets.package.name = `{manifest.assets.package.name}\n({id})`
	manifest.assets.package.description = `{manifest.assets.package.description}\n({id})`

	manifest.assets.plugin.name = `{manifest.assets.plugin.name}\n({id})`
	manifest.assets.plugin.description = `{manifest.assets.plugin.description}\n({id})`

	local handle = fs.open(MANIFEST_PATH, "w")
	fs.write(handle, toml.serialize(manifest))
	fs.close(handle)

	local success, result = pcall(function()
		return run("lute", { "deploy.luau" }, {
			env = {
				ROBLOX_API_KEY = apiKey,
			},
			cwd = ROOT_PATH,
		})
	end)

	run("git", { "restore", MANIFEST_PATH })

	assert(success, result)

	packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	expect.eq(packageAssetDetails.displayName, manifest.assets.package.name)
	expect.eq(packageAssetDetails.description, manifest.assets.package.description)

	expect.eq(pluginAssetDetails.displayName, manifest.assets.plugin.name)
	expect.eq(pluginAssetDetails.description, manifest.assets.plugin.description)
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

	local success, result = pcall(function()
		return run("lute", { "deploy.luau" }, {
			env = {
				ROBLOX_API_KEY = apiKey,
			},
			cwd = ROOT_PATH,
		})
	end)

	run("git", { "restore", path })

	assert(success, result)

	packageAssetDetails = getAssetDetailsAsync(packageAssetId, apiKey)
	pluginAssetDetails = getAssetDetailsAsync(pluginAssetId, apiKey)

	expect.neq(packageAssetDetails.revisionId, prevPackageRevisionId)
	expect.eq(pluginAssetDetails.revisionId, prevPluginRevisionId)
end)
