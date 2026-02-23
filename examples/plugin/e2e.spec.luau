local expect = require("@std/test/assert")
local fs = require("@lute/fs")
local process = require("@lute/process")
local test = require("@std/test")
local toml = require("@root/lib/toml")

local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local readManifest = require("@root/manifest/readManifest")
local run = require("@root/lib/run")

local ROOT_PATH = "examples/plugin"
local MANIFEST_PATH = `{ROOT_PATH}/rbxasset.toml`

local function appendTextForTesting(path: string, text: string)
	local handle = fs.open(path, "w")
	local content = fs.read(handle)
	content ..= text
	fs.write(handle, content)
	fs.close(handle)
end

local apiKey = process.env.ROBLOX_API_KEY
assert(apiKey, "End-to-end tests can only be run when the ROBLOX_API_KEY envvar is set to a valid Open Cloud API key")

local lockfile = getOrCreateAssetLockfile(ROOT_PATH)
local assetId = lockfile.assets.plugin.assetId

run("rojo", { "build", "-o", "plugin.rbxm" }, {
	cwd = ROOT_PATH,
})

test.case("uploads to the Creator Store", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)

	local prevRevisionId = assetDetails.revisionId

	local path = `{ROOT_PATH}/src/init.plugin.luau`
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

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	expect.eq(assetDetails.displayName, manifest.assets.plugin.name)
	expect.eq(assetDetails.description, manifest.assets.plugin.description)
	expect.neq(assetDetails.revisionId, prevRevisionId)
end)

test.case("does not publish a new version when there are no changes", function()
	local assetDetails = getAssetDetailsAsync(assetId, apiKey)

	local prevRevisionId = assetDetails.revisionId

	run("lute", { "deploy.luau" }, {
		env = {
			ROBLOX_API_KEY = apiKey,
		},
		cwd = ROOT_PATH,
	})

	assetDetails = getAssetDetailsAsync(assetId, apiKey)

	expect.eq(assetDetails.revisionId, prevRevisionId)
end)
