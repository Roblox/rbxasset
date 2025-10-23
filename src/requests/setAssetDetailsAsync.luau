local json = require("@std/json")

local createFormData = require("@root/requests/forms/createFormData")
local fetch = require("@root/requests/fetch")
local types = require("@root/types")
local waitForAssetOperationAsync = require("@root/requests/waitForAssetOperationAsync")

type OperationResponse = types.OperationResponse

type AssetDetails = {
	displayName: string,
	description: string?,
}

local function setAssetDetailsAsync(assetId: string, apiKey: string, details: AssetDetails)
	local formData = createFormData({
		request = {
			value = {
				assetId = assetId,
				displayName = details.displayName,
				description = details.description,
			},
			contentType = "application/json",
		},
	})

	local res = fetch(`https://apis.roblox.com/assets/v1/assets/{assetId}?updateMask=description,displayName`, {
		method = "PATCH",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = `multipart/form-data; boundary={formData.boundary}`,
		},
		body = formData.body,
	})

	-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
	local body: OperationResponse = json.deserialize(res.body) :: any

	if body.message then
		error(body.message)
	else
		waitForAssetOperationAsync(body.operationId, apiKey)
	end
end

return setAssetDetailsAsync
