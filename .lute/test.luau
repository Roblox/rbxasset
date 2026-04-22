local cli = require("@pkg/Lute@v1.0.0/batteries/cli")
local process = require("@std/process")

local dotenv = require("./lib/dotenv")
local run = require("@root/lib/run")

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

run("lute", { "test", "src" })

if args:has("e2e") then
	-- We need to set the API key as an env variable so the E2E tests also have
	-- access to it
	process.env.ROBLOX_API_KEY = apiKey

	run("lute", { "test", "examples" })
end
