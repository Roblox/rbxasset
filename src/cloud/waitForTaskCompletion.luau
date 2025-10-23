local json = require("@std/json")
local task = require("@lute/task")

local fetch = require("@root/requests/fetch")
local types = require("@root/types")

local function waitForTaskCompletion(operationPath: string, apiKey: string): types.LuauTaskResponse
	while true do
		local res = fetch(`https://apis.roblox.com/cloud/v2/{operationPath}`, {
			headers = {
				["x-api-key"] = apiKey,
			},
		})

		-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
		local luauTask: any = json.deserialize(res.body)

		if luauTask.state ~= "PROCESSING" then
			return luauTask
		else
			task.wait(2)
		end
	end
end

return waitForTaskCompletion
