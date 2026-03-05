local cli = require("@pkg/cli")
local process = require("@std/process")

local function parseApiKey(parser: cli.Parser, flagName: string)
	local apiKey = parser:get(flagName)

	if apiKey and apiKey ~= "" then
		return apiKey
	else
		local apiKeyFromEnv = process.env.ROBLOX_API_KEY

		if apiKeyFromEnv and apiKeyFromEnv ~= "" then
			return apiKeyFromEnv
		end
	end

	error(
		`failed to parse Open Cloud API key. Pass the --{flagName} flag or set the ROBLOX_API_KEY environment variable`
	)
end

return parseApiKey
