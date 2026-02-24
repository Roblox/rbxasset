local fs = require("@lute/fs")
local path = require("@std/path")
local pp = require("@pkg/pp")
local toml = require("@root/lib/toml")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Manifest = types.Manifest

local function readManifest(packagePath: path.pathlike): Manifest
	local manifestPath = path.join(packagePath, constants.ASSET_MANIFEST_FILENAME)
	local success, result = pcall(function()
		local handle = fs.open(tostring(manifestPath), "r")
		local content = fs.read(handle)
		fs.close(handle)
		return content
	end)
	assert(success, `failed to read asset manifest at {manifestPath}: {result}`)

	local parsedContent = toml.deserialize(result)

	local isManifestValid, message = types.validateManifest(parsedContent)
	assert(isManifestValid, `failed to parse asset manifest at {manifestPath}: {message}`)

	logging.debug("loaded asset manifest", pp(parsedContent))

	return parsedContent :: Manifest
end

return readManifest
