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

type Options = typeof(defaultOptions) & RetryOptions

local function retry(callback: () -> (), retryOptions: RetryOptions?)
	local options = tableext.combine(defaultOptions, retryOptions) :: Options

	local attempts = 0

	while true do
		local success, err = pcall(function()
			callback()
			return nil
		end)

		if success then
			break
		end

		attempts += 1

		if attempts >= options.maxAttempts then
			error(`callback did not succeed in {options.maxAttempts} attempts: {err}`)
		end

		task.wait(options.waitTime)
	end
end

return retry
