local cli = require("@pkg/cli")
local luau = require("@std/luau")
local process = require("@lute/process")
local test = require("@std/test")

local dotenv = require("./lib/dotenv")
local find = require("./lib/find")
local logging = require("@root/logging")

local args = cli.parser()

args:add("apiKey", "option", {
	help = "Open Cloud API key for running end-to-end tests. This can also be supplied by setting the ROBLOX_API_KEY environment variable",
})
args:add("e2e", "flag", {
	help = "Run end-to-end tests",
})

args:parse({ ... })

dotenv()

local apiKey = args:get("apiKey") or process.env.ROBLOX_API_KEY

local function loadTestCases(path: string)
	local files = find(path, "%.spec%.luau")

	logging.info("spec files:")
	for _, file in files do
		logging.info(`  {file}`)
	end

	for _, file in files do
		luau.loadbypath(file)
	end
end

loadTestCases("src")

if args:has("e2e") then
	-- We need to set the API key as an env variable so the E2E tests also have
	-- access to it
	process.env.ROBLOX_API_KEY = apiKey

	loadTestCases("examples")
end

test.run()
