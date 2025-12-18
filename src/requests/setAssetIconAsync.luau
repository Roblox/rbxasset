local json = require("@std/json")

local createFormData = require("@root/requests/forms/createFormData")
local fetch = require("@root/requests/fetch")
local getOrCreateAssetLockfile = require("@root/manifest/getOrCreateAssetLockfile")
local logging = require("@root/logging")
local types = require("@root/types")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")

type AssetConfig = types.AssetConfig

local ASSETS_BASE_URL = "https://apis.roblox.com/assets/v1"

local function setAssetIconAsync(projectPath: string, assetName: string, assetConfig: AssetConfig, apiKey: string)
	if not assetConfig.icon then
		logging.debug("no icon in the asset manifest. skipping...")
		return
	end

	local assetLockfile = getOrCreateAssetLockfile(projectPath)
	if not assetLockfile then
		logging.err("asset lockfile must exist before the icon can be set")
		return
	end

	local existingAsset = if assetLockfile.assets then assetLockfile.assets[assetName] else nil
	local assetId = if existingAsset then existingAsset.assetId else nil
	if not assetId then
		logging.err("no assetId found in the lockfile. has the package been uploaded before?")
		return
	end

	local iconImage = if assetLockfile.images then assetLockfile.images[assetConfig.icon] else nil
	if not iconImage then
		logging.err(`no image found for {assetConfig.icon} in the lockfile`)
		return
	end

	local formData = createFormData({
		request = {
			value = {
				assetId = assetId,
				icon = `assets/{iconImage.assetId}`,
			},
			contentType = "application/json",
		},
	})

	local res = fetch(`{ASSETS_BASE_URL}/assets/{assetId}?updateMask=icon`, {
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

	if not body.operationId then
		logging.err(`failed to set asset icon`)
		return
	end

	local operation = waitForAssetOperationAsync(body.operationId, apiKey)

	if operation.metadata then
		local problems = {}
		for _, err in operation.metadata.errors do
			table.insert(problems, err.error.message)
		end
		logging.warn(`failed to set asset icon: {table.concat(problems, ", ")}`)
		return
	end

	logging.info(`icon uploaded successfully`)
end

return setAssetIconAsync
