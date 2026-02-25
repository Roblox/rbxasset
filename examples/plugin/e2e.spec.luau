local expect = require("@std/test/assert")
local fs = require("@lute/fs")
local path = require("@std/path")
local process = require("@lute/process")
local test = require("@std/test")
local toml = require("@root/lib/toml")

local appendTextForTesting = require("@scripts/lib/appendTextForTesting")
local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")
local run = require("@root/lib/run")

local ROOT_PATH = path.resolve("examples/plugin")
local MANIFEST_PATH = path.join(ROOT_PATH, "rbxasset.toml")
local DEPLOY_SCRIPT = path.join(ROOT_PATH, "deploy.luau")

local function buildModelFile(): path.path
	local out = path.join(ROOT_PATH, "plugin.rbxm")
	process.system(`rojo build -o {out}`)
	return out
end

local apiKey = process.env.ROBLOX_API_KEY
assert(apiKey, "End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local assetId = lockfile.assets.plugin.assetId

buildModelFile()

test.case("uploads to the Creator Store", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)

	local prevRevisionId = assetDetails.revisionId

	local filePath = path.join(ROOT_PATH, "src/init.plugin.luau")
	appendTextForTesting(filePath, `\nprint("New!")`)

	local success, err = pcall(function()
		process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
			stdio = "inherit",
		})
		return nil
	end)

	run("git", { "restore", tostring(filePath) })

	assert(success, err)

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	expect.neq(assetDetails.revisionId, prevRevisionId)
end)

test.case("text fields in rbxasest.toml get mirrored to the asset details", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)
	local prevRevisionId = assetDetails.revisionId

	local manifest = readManifest(ROOT_PATH)

	local id = os.time()
	manifest.assets.plugin.name = `{manifest.assets.plugin.name}\n({id})`
	manifest.assets.plugin.description = `{manifest.assets.plugin.description}\n({id})`

	local handle = fs.open(tostring(MANIFEST_PATH), "w")
	fs.write(handle, toml.serialize(manifest :: { [any]: any }))
	fs.close(handle)

	local success, err = pcall(function()
		process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
			stdio = "inherit",
		})
		return nil
	end)

	run("git", { "restore", tostring(MANIFEST_PATH) })

	assert(success, err)

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	expect.eq(assetDetails.displayName, manifest.assets.plugin.name)
	expect.eq(assetDetails.description, manifest.assets.plugin.description)
	expect.neq(assetDetails.revisionId, prevRevisionId)
end)

test.case("does not publish a new version when there are no changes", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)

	local prevRevisionId = assetDetails.revisionId

	process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
		stdio = "inherit",
	})

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	expect.eq(assetDetails.revisionId, prevRevisionId)
end)
