local pp = require("@pkg/pp")
local tableext = require("@std/tableext")
local task = require("@lute/task")

type RetryOptions = {
	maxAttempts: number?,
	waitTime: number?,
}

local defaultOptions = {
	maxAttempts = 3,
	waitTime = 1,
}

type Options = typeof(defaultOptions)

local function retry(callback: () -> (), retryOptions: RetryOptions?)
	local options = tableext.combine(defaultOptions, retryOptions) :: Options

	local attempts = 0
	local start = os.clock()

	while true do
		attempts += 1

		local success, err = pcall(function()
			callback()
			return nil
		end)

		if success then
			break
		end

		if attempts >= options.maxAttempts then
			local elapsed = ("%.2f"):format(os.clock() - start)
			error(`callback did not succeed over {options.maxAttempts} attempts in {elapsed} seconds: {pp(err)}`, 2)
		end

		local waitTime = options.waitTime
		if attempts > 1 then
			waitTime *= 2 * attempts
		end
		task.wait(waitTime)
	end
end

return retry
