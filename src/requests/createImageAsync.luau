local fs = require("@lute/fs")
local json = require("@lute/std/json")

local createFormData = require("@root/requests/forms/createFormData")
local fetch = require("@root/requests/fetch")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")

local function createImageAsync(
	displayName: string,
	imagePath: string,
	creatorId: number,
	creatorType: "User" | "Group",
	apiKey: string
)
	local creatorIdKey = if creatorType == "User" then "userId" else "groupId"

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
			filename = imagePath:match("[/\\](.+)$"),
			value = fs.readfiletostring(imagePath),
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

	local body = json.deserialize(res.body)

	return waitForAssetOperationAsync(body.operationId, apiKey)
end

return createImageAsync
