local json = require("@std/json")
local path = require("@std/path")
local stdfs = require("@std/fs")

local createFormData = require("@root/requests/forms/createFormData")
local fetch = require("@root/requests/fetch")
local types = require("@root/types")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")

local function createImageAsync(
	displayName: string,
	imagePath: path.pathlike,
	creatorId: number,
	creatorType: types.CreatorType,
	apiKey: string
)
	local creatorIdKey = if creatorType == types.CreatorType.User then "userId" else "groupId"

	local imageContent = stdfs.readfiletostring(imagePath)

	local formData = createFormData({
		request = {
			value = {
				assetType = "Image",
				displayName = displayName,
				creationContext = {
					creator = {
						[creatorIdKey] = creatorId,
					},
				},
			},
			contentType = "application/json",
		},
		fileContent = {
			filename = path.basename(imagePath),
			value = imageContent,
			contentType = "image/png",
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

	-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
	local body: any = json.deserialize(res.body)

	return waitForAssetOperationAsync(body.operationId, apiKey)
end

return createImageAsync
