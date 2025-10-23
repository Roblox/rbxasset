local fs = require("@lute/fs")
local json = require("@std/json")

local fetch = require("@root/requests/fetch")
local logging = require("@root/logging")
local types = require("@root/types")

type AssetId = types.AssetId

local function publishPlaceAsync(
	placePath: string,
	universeId: AssetId,
	placeId: AssetId,
	apiKey: string,
	shouldPublish: boolean?
)
	logging.debug("uploading place to Roblox")

	local versionType = if shouldPublish then "Published" else "Saved"

	local res =
		fetch(`https://apis.roblox.com/universes/v1/{universeId}/places/{placeId}/versions?versionType={versionType}`, {
			method = "POST",
			body = fs.readfiletostring(placePath),
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = "application/xml",
				["Accept"] = "application/json",
			},
		})

	if res.ok then
		-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
		local body: any = json.deserialize(res.body)

		if typeof(body) == "table" and next(body) ~= nil then
			return body.versionNumber :: number
		end
	end
	return -1
end

return publishPlaceAsync
