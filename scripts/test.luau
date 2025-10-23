local process = require("@lune/process")

local frktest = require("@pkg/frktest")

local logging = require("@root/logging")
local run = require("@root/lib/run")

local reporter = frktest._reporters.lune_console_reporter

local function loadTestCases()
	local output = run("find", { "src", "-iname", "*.spec.luau" })
	output = output:gsub("src/", "@root/")

	local files = output:split("\n")

	logging.debug("files", files)

	for _, file in files do
		(require :: any)(file)
	end
end

loadTestCases()

reporter.init()
local success = frktest.run()

process.exit(if success then 0 else 1)
