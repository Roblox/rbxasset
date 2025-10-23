local fs = require("@lute/fs")
local json = require("@lute/std/json")

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
			body = fs.readfiletostringtostring(placePath),
			headers = {
				["x-api-key"] = apiKey,
				["Content-Type"] = "application/xml",
				["Accept"] = "application/json",
			},
		})

	if res.ok then
		local body = json.deserialize(res.body)
		return body.versionNumber :: number
	end
	return -1
end

return publishPlaceAsync
