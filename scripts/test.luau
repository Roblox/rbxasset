local luau = require("@std/luau")
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

test.run()
