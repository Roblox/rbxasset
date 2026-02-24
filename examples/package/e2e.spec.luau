local expect = require("@std/test/assert")
local fs = require("@lute/fs")
local path = require("@std/path")
local process = require("@lute/process")
local test = require("@std/test")
local toml = require("@root/lib/toml")

local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")
local run = require("@root/lib/run")

local ROOT_PATH = path.resolve("examples/package")
local MANIFEST_PATH = path.join(ROOT_PATH, "rbxasset.toml")
local DEPLOY_SCRIPT = path.join(ROOT_PATH, "deploy.luau")

local function appendTextForTesting(filePath: path.pathlike, text: string)
	local handle = fs.open(tostring(filePath), "w+")
	local content = fs.read(handle)
	content ..= text
	fs.write(handle, content)
	fs.close(handle)
end

local apiKey = process.env.ROBLOX_API_KEY
if not apiKey then
	error("End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")
end

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local assetId = lockfile.assets.package.assetId

process.system(`rojo build -o {path.join(ROOT_PATH, "asset.rbxm")}`)

test.case("uploads rbxm to the Creator Store", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)
	local prevRevisionId = assetDetails.revisionId

	local filePath = path.join(ROOT_PATH, "src/init.luau")
	appendTextForTesting(filePath, `\nprint("New!")`)

	local success, result = pcall(function()
		return process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
			stdio = "inherit",
		})
	end)

	run("git", { "restore", tostring(filePath) })

	assert(success, result)

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	expect.neq(assetDetails.revisionId, prevRevisionId)
end)

test.case("text fields in rbxasest.toml get mirrored to the asset details", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)
	local prevRevisionId = assetDetails.revisionId

	local manifest = readManifest(ROOT_PATH)

	local id = os.time()
	manifest.assets.package.name = `{manifest.assets.package.name}\n({id})`
	manifest.assets.package.description = `{manifest.assets.package.description}\n({id})`

	local handle = fs.open(tostring(MANIFEST_PATH), "w")
	fs.write(handle, toml.serialize(manifest))
	fs.close(handle)

	local success, result = pcall(function()
		return process.run({ "lute", tostring(DEPLOY_SCRIPT) }, {
			stdio = "inherit",
		})
	end)

	run("git", { "restore", tostring(MANIFEST_PATH) })

	assert(success, result)

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	expect.eq(assetDetails.displayName, manifest.assets.package.name)
	expect.eq(assetDetails.description, manifest.assets.package.description)
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
