local fs = require("@lute/fs")
local toml = require("@pkg/toml")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Manifest = types.Manifest

local function readManifest(packagePath: string): Manifest
	local manifestPath = `{packagePath}/{constants.ASSET_MANIFEST_FILENAME}`
	local content: string
	local success, err = pcall(function()
		content = fs.readfiletostring(manifestPath)
	end)
	assert(success, `failed to read asset manifest at {manifestPath}: {err}`)

	local parsedContent = toml.deserialize(content)

	local isManifestValid, message = types.validateManifest(parsedContent)
	assert(isManifestValid, `failed to parse asset manifest at {manifestPath}: {message}`)

	logging.debug("loaded asset manifest", parsedContent)

	return parsedContent :: Manifest
end

return readManifest
