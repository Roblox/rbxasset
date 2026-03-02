local path = require("@std/path")
local process = require("@std/process")

local logging = require("@root/logging")
local publishAssetAsync = require("@root/requests/publishAssetAsync")
local publishImagesAsync = require("@root/requests/publishImagesAsync")
local readManifest = require("@root/manifest/readManifest")
local setAssetIconAsync = require("@root/requests/setAssetIconAsync")

local function publishPackageAsync(projectPath: path.pathlike, assetName: string, apiKey: string)
	local manifest = readManifest(projectPath)

	local asset = manifest.assets[assetName]
	if not asset then
		logging.err(`publishing failed, could not find an asset named {assetName} in the manifest`)
		process.exit(1)
	end

	local environment = manifest.environments[asset.environment]

	local assetId = publishAssetAsync(projectPath, assetName, asset, environment, apiKey)
	publishImagesAsync(projectPath, asset, environment, apiKey)
	setAssetIconAsync(projectPath, assetName, asset, apiKey)

	logging.info("package published successfully! View it on the Creator Store:")
	logging.info(`https://create.roblox.com/store/asset/{assetId}`)
end

return publishPackageAsync
