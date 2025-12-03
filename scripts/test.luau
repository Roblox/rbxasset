local luau = require("@std/luau")
-- local process = require("@lute/process")
local test = require("@std/test")

local find = require("./lib/find")
local logging = require("@root/logging")

local function loadTestCases()
	local files = find("src", "%.spec%.luau")

	logging.info("spec files:")
	for _, file in files do
		logging.info(`  {file}`)
	end

	for _, file in files do
		luau.loadbypath(file)
	end
end

loadTestCases()

-- FIXME: Can't set the reported right now. Currently this fails with 'attempt
-- to modify a readonly table'. Looks like a Lute bug
-- test.setreporter(function(result)
-- 	process.exit(if result.failed == 0 then 0 else 1)
-- end)

test.run()
