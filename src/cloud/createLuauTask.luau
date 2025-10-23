local json = require("@std/json")

local fetch = require("@root/requests/fetch")
local types = require("@root/types")

type AssetId = types.AssetId

local function createLuauTask(
	scriptContent: string,
	universeId: AssetId,
	placeId: AssetId,
	apiKey: string
): types.LuauTaskResponse
	local res =
		fetch(`https://apis.roblox.com/cloud/v2/universes/{universeId}/places/{placeId}/luau-execution-session-tasks`, {
			method = "POST",
			headers = {
				["Content-Type"] = "application/json",
				["x-api-key"] = apiKey,
			},
			body = json.serialize({
				["script"] = scriptContent,
			}),
		})

	-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
	local body: any = json.deserialize(res.body)

	return body
end

return createLuauTask
