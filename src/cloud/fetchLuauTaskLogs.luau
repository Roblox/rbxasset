local json = require("@std/json")

local fetch = require("@root/requests/fetch")

local function fetchLuauTaskLogs(taskPath: string, apiKey: string): { string }
	local res = fetch(`https://apis.roblox.com/cloud/v2/{taskPath}/logs`, {
		headers = {
			["x-api-key"] = apiKey,
		},
	})

	-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
	local logs: any = json.deserialize(res.body)

	if #logs["luauExecutionSessionTaskLogs"] == 0 then
		return {} -- no logs found
	end
	return logs["luauExecutionSessionTaskLogs"][1]["messages"]
end

return fetchLuauTaskLogs
