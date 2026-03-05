local fs = require("@std/fs")
local json = require("@std/json")
local path = require("@std/path")

local createFormData = require("@root/requests/forms/createFormData")
local fetch = require("@root/requests/fetch")
local getAssetDetailsAsync = require("@root/requests/getAssetDetailsAsync")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local join = require("@root/lib/join")
local logging = require("@root/logging")
local setAssetDetailsAsync = require("@root/requests/setAssetDetailsAsync")
local types = require("@root/types")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")
local writeLockfile = require("@root/manifest/writeLockfile")

type AssetConfig = types.AssetConfig
type EnvironmentConfig = types.EnvironmentConfig

local function publishAssetAsync(
	projectPath: path.pathlike,
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

	local creatorIdKey = if environment.creatorType == types.CreatorType.User then "userId" else "groupId"

	local assetId

	local modelPath = path.join(projectPath, asset.model)
	local modelContent = fs.readfiletostring(modelPath)

	if assetDetails and assetDetails.assetId then
		logging.info("publishing new version...")
		local formData = createFormData({
			request = {
				value = {
					assetId = assetDetails.assetId,
				},
				contentType = "application/json",
			},
			fileContent = {
				filename = asset.model,
				value = modelContent,
				contentType = "model/x-rbxm",
			},
		})

		local res = fetch(`https://apis.roblox.com/assets/v1/assets/{assetDetails.assetId}`, {
			method = "PATCH",
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
			},
			body = formData.body,
		})

		-- FIXME: Narrow the return value of `json.deserialize` instead of casting
		-- to `any`
		local body: any = json.deserialize(res.body)

		local operationRes = waitForAssetOperationAsync(body.operationId, apiKey)

		if operationRes and operationRes.response then
			assetId = operationRes.response.assetId
		end
	else
		logging.info("creating asset for the first time...")
		local formData = createFormData({
			request = {
				value = {
					assetType = "Model", -- MUS-2488 TODO: Allow for publishing Plugins
					displayName = asset.name,
					creationContext = {
						creator = {
							[creatorIdKey] = environment.creatorId,
						},
					},
				},
				contentType = "application/json",
			},
			fileContent = {
				filename = asset.model,
				value = modelContent,
				contentType = "model/x-rbxm",
			},
		})

		local res = fetch("https://apis.roblox.com/assets/v1/assets", {
			method = "POST",
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
			},
			body = formData.body,
		})

		-- FIXME: Narrow the return value of `json.deserialize` instead of casting
		-- to `any`
		local body: any = json.deserialize(res.body)

		local operationRes = waitForAssetOperationAsync(body.operationId, apiKey)

		if operationRes and operationRes.response then
			assetId = operationRes.response.assetId
		end
	end

	if assetId then
		setAssetDetailsAsync(assetId, apiKey, {
			displayName = asset.name,
			description = asset.description,
		})

		local newLockfile = join(lockfile, {
			assets = join(lockfile.assets, {
				[assetName] = join(lockfile.assets[assetName], {
					assetId = assetId,
				}),
			}),
		}) :: types.Lockfile

		writeLockfile(projectPath, newLockfile)
	end

	return assetId
end

return publishAssetAsync
