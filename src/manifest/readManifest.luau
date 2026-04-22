local fs = require("@std/fs")
local path = require("@std/path")
local pp = require("@pkg/Lute@v1.0.0/batteries/pp")
local toml = require("@root/lib/toml")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Manifest = types.Manifest

local function readManifest(packagePath: path.Pathlike): Manifest
	local manifestPath = path.join(packagePath, constants.ASSET_MANIFEST_FILENAME)
	local success, result = pcall(function()
		return fs.readFileToString(manifestPath)
	end)
	assert(success, `failed to read asset manifest at {manifestPath}: {result}`)

	local parsedContent = toml.deserialize(result)

	local isManifestValid, message = types.validateManifest(parsedContent)
	assert(isManifestValid, `failed to parse asset manifest at {manifestPath}: {message}`)

	logging.debug("loaded asset manifest", pp(parsedContent))

	return parsedContent :: Manifest
end

return readManifest
