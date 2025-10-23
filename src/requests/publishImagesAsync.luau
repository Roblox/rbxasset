local crypto = require("@lute/crypto")
local fs = require("@lute/fs")

local createImageAsync = require("@root/requests/createImageAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local logging = require("@root/logging")
local types = require("@root/types")
local writeLockfile = require("@root/manifest/writeLockfile")

type AssetConfig = types.AssetConfig
type EnvironmentConfig = types.EnvironmentConfig

type PendingImage = {
	path: string,
	filename: string,
	assetId: string,
}

local function toSha256String(str: string): string
	return buffer.tostring(crypto.digest(crypto.hash.sha256, str))
end

local function publishImagesAsync(
	projectPath: string,
	assetConfig: AssetConfig,
	environment: EnvironmentConfig,
	apiKey: string
)
	local assetLockfile = getOrCreateAssetLockfile(projectPath)
	local pendingImages: { PendingImage } = {}

	local existingImages = if assetLockfile then assetLockfile.images else {} :: typeof(({} :: types.Lockfile).images)

	local icon = assetConfig.icon
	if icon then
		local iconPath = `{projectPath}/{icon}`

		logging.info(`syncing package icon at {iconPath}`)

		local iconHash = toSha256String(fs.readfiletostring(iconPath))

		if existingImages and existingImages[icon] and existingImages[icon].hash == iconHash then
			logging.debug(`hashes match for {iconPath}, skipping...`)
		else
			logging.info(`uploading image at {iconPath}...`)

			local operation = createImageAsync(
				`{assetConfig.name} - Icon`,
				iconPath,
				environment.creatorId,
				environment.creatorType,
				apiKey
			)

			local assetId = if operation.response then operation.response.assetId else nil

			if assetId then
				local pendingImage: PendingImage = {
					path = iconPath,
					filename = icon,
					assetId = assetId,
				}
				table.insert(pendingImages, pendingImage)

				logging.debug(`image uploaded successfully`)
			else
				logging.warn(`failed to upload image at {iconPath}`)
			end
		end
	end

	local thumbnails = assetConfig.thumbnails
	if thumbnails then
		logging.info("syncing package thumbnails...")

		for index, thumbnailFilename in thumbnails do
			local thumbnailPath = `{projectPath}/{thumbnailFilename}`
			local thumbnailHash = toSha256String(fs.readfiletostring(thumbnailPath))

			local existingThumbnail = existingImages and existingImages[thumbnailFilename]
			if existingThumbnail and existingThumbnail.hash == thumbnailHash then
				logging.debug(`hashes match for {thumbnailPath}, skipping...`)
				continue
			end

			logging.info(`uploading image at {thumbnailPath}`)

			local operation = createImageAsync(
				`{assetConfig.name} - Thumbnail {index}`,
				thumbnailPath,
				environment.creatorId,
				environment.creatorType,
				apiKey
			)

			if operation.response then
				local assetId = operation.response.assetId

				if assetId then
					local pendingImage: PendingImage = {
						path = thumbnailPath,
						filename = thumbnailFilename,
						assetId = assetId,
					}
					table.insert(pendingImages, pendingImage)

					logging.debug(`image uploaded successfully`)
				else
					logging.warn(`failed to upload image at {thumbnailPath}`)
				end
			end
		end
	end

	if #pendingImages > 0 then
		local newAssetLockfile = table.clone(assetLockfile or {} :: types.Lockfile)
		newAssetLockfile.images = newAssetLockfile.images or {}

		for _, pendingImage in pendingImages do
			newAssetLockfile.images[pendingImage.filename] = {
				assetId = pendingImage.assetId,
				hash = toSha256String(fs.readfiletostring(pendingImage.path)),
			}

			logging.debug(
				`image {pendingImage.path} uploaded successfully: https://create.roblox.com/store/asset/{pendingImage.assetId}`
			)
		end

		writeLockfile(projectPath, newAssetLockfile)
	else
		logging.debug("no new images to write to the lockfile. skipping...")
	end

	logging.info("successfully synced images to Creator Store")
end

return publishImagesAsync
