local json = require("@std/json")

local fetch = require("@root/requests/fetch")

local function getAssetDetailsAsync(assetId: string, apiKey: string)
	local res = fetch(`https://apis.roblox.com/assets/v1/assets/{assetId}`, {
		method = "GET",
		headers = {
			["x-api-key"] = apiKey,
			["Content-Type"] = "application/json",
		},
	})

	-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
	local assetDetails: any = json.deserialize(res.body)

	return assetDetails
end

return getAssetDetailsAsync
