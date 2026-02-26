local expect = require("@std/test/assert")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@lute/process")
local test = require("@std/test")
local toml = require("@root/lib/toml")

local appendTextForTesting = require("@scripts/lib/appendTextForTesting")
local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")
local retryAsync = require("@scripts/lib/retryAsync")
local run = require("@root/lib/run")

local ROOT_PATH = path.resolve("examples/workspace")
local MANIFEST_PATH = path.join(ROOT_PATH, "rbxasset.toml")
local DEPLOY_SCRIPT = path.join(ROOT_PATH, "deploy.luau")

local apiKey = process.env.ROBLOX_API_KEY
assert(apiKey, "End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local packageAssetId = lockfile.assets.package.assetId
local pluginAssetId = lockfile.assets.plugin.assetId

test.case("uploads each workspace member to the Creator Store", function()
	local initialAssetDetails = {
		package = getAssetDetailsAsync(packageAssetId, apiKey),
		plugin = getAssetDetailsAsync(pluginAssetId, apiKey),
	}

	local filesToChange = {
		path.join(ROOT_PATH, "package/src/init.luau"),
		path.join(ROOT_PATH, "plugin/src/init.plugin.luau"),
	}

	for _, filePath in filesToChange do
		appendTextForTesting(filePath, `\nprint("New!")`)
	end

	local success, err = pcall(function()
		process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
			stdio = "inherit",
		})
		return nil
	end)

	do
		local filePaths = {}
		for _, filePath in filesToChange do
			table.insert(filePaths, tostring(filePath))
		end
		run("git", { "restore", table.unpack(filePaths) })
	end

	assert(success, err)

	retryAsync(function()
		local assetDetails = {
			package = getAssetDetailsAsync(packageAssetId, apiKey),
			plugin = getAssetDetailsAsync(pluginAssetId, apiKey),
		}

		expect.neq(assetDetails.package.revisionId, initialAssetDetails.package.revisionId)
		expect.neq(assetDetails.plugin.revisionId, initialAssetDetails.plugin.revisionId)
	end)
end)

test.case("text fields in rbxasest.toml get mirrored to the asset details", function()
	local manifest = readManifest(ROOT_PATH)

	local id = os.time()

	manifest.assets.package.name = `{manifest.assets.package.name} ({id})`
	manifest.assets.package.description = `{manifest.assets.package.description}\n({id})`

	manifest.assets.plugin.name = `{manifest.assets.plugin.name} ({id})`
	manifest.assets.plugin.description = `{manifest.assets.plugin.description}\n({id})`

	fs.writestringtofile(MANIFEST_PATH, toml.serialize(manifest :: { [unknown]: unknown }))

	local success, err = pcall(function()
		process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
			stdio = "inherit",
		})
		return nil
	end)

	run("git", { "restore", tostring(MANIFEST_PATH) })

	assert(success, err)

	retryAsync(function()
		local assetDetails = {
			package = getAssetDetailsAsync(packageAssetId, apiKey),
			plugin = getAssetDetailsAsync(pluginAssetId, apiKey),
		}

		expect.eq(assetDetails.package.displayName, manifest.assets.package.name)
		expect.eq(assetDetails.package.description, manifest.assets.package.description)

		expect.eq(assetDetails.plugin.displayName, manifest.assets.plugin.name)
		expect.eq(assetDetails.plugin.description, manifest.assets.plugin.description)
	end)
end)

test.case("only publishes a new version for changed workspace members", function()
	local initialAssetDetails = {
		package = getAssetDetailsAsync(packageAssetId, apiKey),
		plugin = getAssetDetailsAsync(pluginAssetId, apiKey),
	}

	-- We make a change to a single workspace member so we can verify that only
	-- that member was given a new revision after publishing
	local filePath = path.join(ROOT_PATH, "package/src/init.luau")
	appendTextForTesting(tostring(filePath), `\nprint("New!")`)

	local success, err = pcall(function()
		process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
			stdio = "inherit",
		})
		return nil
	end)

	run("git", { "restore", tostring(filePath) })

	assert(success, err)

	local assetDetails = {
		package = getAssetDetailsAsync(packageAssetId, apiKey),
		plugin = getAssetDetailsAsync(pluginAssetId, apiKey),
	}

	expect.neq(assetDetails.package.revisionId, initialAssetDetails.package.revisionId)
	expect.eq(assetDetails.plugin.revisionId, initialAssetDetails.plugin.revisionId)
end)
