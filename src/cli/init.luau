local process = require("@std/process")

local check = require("@self/check")
local types = require("@self/types")

local ARGS = { ... }

local SUBCOMMANDS: { [string]: types.Subcommand } = {
	check = check,
}

local function getPossibleSubcommands()
	local names = {}
	for subcommandName in SUBCOMMANDS do
		table.insert(names, subcommandName)
	end
	return table.concat(names, ", ")
end

--[[
	Lute CLI battery doesn't support subcommands yet, so to work around that
	each of our subcommands is a new Parser instance, and this top-level
	interface just routes to each subcommand.
]]

local scriptPath = ARGS[1]
local subcommandName = ARGS[2]
local userArgs = { scriptPath, table.unpack(ARGS, 2, #ARGS) }

local subcommand = rawget(SUBCOMMANDS, subcommandName)

if subcommand then
	subcommand.parser:parse(userArgs)
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
