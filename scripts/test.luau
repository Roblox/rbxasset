-- local process = require("@lute/process")

local test = require("@std/test")

local logging = require("@root/logging")
local run = require("@root/lib/run")

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

test.setreporter(function(result)
	-- process.exit(if success then 0 else 1)
	assert(result.failed > 0, "one or more unit tests failed")
end)

test.run()
