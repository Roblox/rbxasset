local path = require("@std/path")

local logging = require("@root/logging")
local publishAssetAsync = require("@root/requests/publishAssetAsync")
local publishImagesAsync = require("@root/requests/publishImagesAsync")
local readManifest = require("@root/manifest/readManifest")
local setAssetIconAsync = require("@root/requests/setAssetIconAsync")

local function publishWorkspaceAsync(projectPath: path.Pathlike, apiKey: string)
	local manifest = readManifest(projectPath)

	for assetName, asset in manifest.assets do
		local environment = manifest.environments[asset.environment]

		local assetId = publishAssetAsync(projectPath, assetName, asset, environment, apiKey)
		publishImagesAsync(projectPath, asset, environment, apiKey)
		setAssetIconAsync(projectPath, assetName, asset, apiKey)

		logging.info("package published successfully! View it on the Creator Store:")
		logging.info(`https://create.roblox.com/store/asset/{assetId}`)
	end
end

return publishWorkspaceAsync
