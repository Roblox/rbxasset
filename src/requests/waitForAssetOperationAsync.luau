local json = require("@lute/std/json")
local task = require("@lute/task")

local fetch = require("@root/requests/fetch")
local types = require("@root/types")

local MAX_RETRIES = 5
local RETRY_MULTIPLIER = 2

type OperationResponse = types.OperationResponse

local function waitForAssetOperationAsync(operationId: string, apiKey: string): OperationResponse
	local currentRetries = 0
	local retryPollingDelay = 1

	while currentRetries < MAX_RETRIES do
		local res = fetch(`https://apis.roblox.com/assets/v1/operations/{operationId}`, {
			method = "GET",
			headers = {
				["x-api-key"] = apiKey,
			},
		})

		-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
		local body: any = json.deserialize(res.body)

		if res.ok and body.done then
			return body
		else
			task.wait(retryPollingDelay)
			retryPollingDelay *= RETRY_MULTIPLIER
		end
	end
	error(`operation "{operationId}" did not complete within {MAX_RETRIES} attempts`)
end

return waitForAssetOperationAsync
