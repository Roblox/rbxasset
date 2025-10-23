local json = require("@lute/std/json")
local task = require("@lute/task")

local fetch = require("@root/requests/fetch")

local function waitForTaskCompletion(operationPath: string, apiKey: string)
	while true do
		local res = fetch(`https://apis.roblox.com/cloud/v2/{operationPath}`, {
			headers = {
				["x-api-key"] = apiKey,
			},
		})

		local luauTask = json.deserialize(res.body)

		if luauTask.state ~= "PROCESSING" then
			return luauTask
		else
			task.wait(2)
		end
	end
end

return waitForTaskCompletion
