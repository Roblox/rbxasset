local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local join = require("@root/lib/join")
local publishAssetTask = require("@root/tasks/publishAsset")
local runLuauTask = require("@root/lib/runLuauTask")
local setAssetDetailsAsync = require("@root/requests/setAssetDetailsAsync")
local types = require("@root/types")
local writeLockfile = require("@root/manifest/writeLockfile")

type AssetConfig = types.AssetConfig
type EnvironmentConfig = types.EnvironmentConfig

local function publishAssetAsync(
	projectPath: string,
	assetName: string,
	asset: AssetConfig,
	environment: EnvironmentConfig,
	apiKey: string
): string?
	local lockfile = getOrCreateAssetLockfile(projectPath)
	local existingAsset = lockfile.assets[assetName]

	-- If this assetId exists then `tasks/publishAsset` will update the asset
	-- version. Otherwise it will create the asset for the first time
	local existingAssetId = if existingAsset then existingAsset.assetId else nil
	local assetDetails = if existingAssetId then getAssetDetailsAsync(existingAssetId, apiKey) else nil

	local variables = runLuauTask(publishAssetTask, {
		CREATOR_ID = environment.creatorId,
		CREATOR_TYPE = environment.creatorType,
		ASSET_TYPE = asset.type or "Package",

		-- Only provide the assetId from the lockfile if there's a matching
		-- asset on the Creator Store. We need this check in case the lockfile
		-- is edited manually to a nonexistent id
		ASSET_ID = if assetDetails and assetDetails.assetId then existingAssetId else nil :: any,
	}, {
		universeId = environment.universeId,
		placeId = environment.placeId,
		modelPath = asset.model,
		apiKey = apiKey,
	})

	local assetId = if variables then variables.ASSET_ID else nil

	if assetId then
		-- CreateAssetAsync and CreateAssetVersionAsync in the Luau task
		-- don't actually update the asset's name/description, so we need to
		-- handle that manually.
		setAssetDetailsAsync(assetId, apiKey, {
			displayName = asset.name,
			description = asset.description,
		})

		local newLockfile: types.Lockfile = join(lockfile, {
			assets = join(lockfile.assets, {
				[assetName] = join(lockfile.assets[assetName], {
					assetId = assetId,
				}),
			}),
		})

		writeLockfile(projectPath, newLockfile)
	end

	return assetId
end

return publishAssetAsync
