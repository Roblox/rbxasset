local path = require("@std/path")
local process = require("@std/process")

local types = require("@self/types")

local ARGS = { ... }

local SUBCOMMANDS: { [string]: types.Subcommand } = {}

local function getPossibleSubcommands()
	local names = {}
	for subcommandName in SUBCOMMANDS do
		table.insert(names, subcommandName)
	end
	return table.concat(names, ", ")
end

do
	--[[
		Lute CLI battery doesn't support subcommands yet, so to work around that
		each of our subcommands is a new Parser instance, and this top-level
		interface just routes to each subcommand.
	]]

	local scriptPath = path.resolve(ARGS[1])
	local subcommandName = ARGS[2]
	local remainingArgs = table.unpack(ARGS, 2, #ARGS)
	local userArgs = { scriptPath, remainingArgs }

	local subcommand = rawget(SUBCOMMANDS, subcommandName)

	if subcommand then
		subcommand.parser:parse(table.unpack(userArgs))
		subcommand.run()
	else
		local message = {
			`No command named {subcommandName}`,
			`Possible subcommands: {getPossibleSubcommands()}`,
			"Usage:",
			"  rbxasset <subcommand> [...options]",
		}
		print(table.concat(message, "\n"))

		process.exit(1)
		return
	end
end
