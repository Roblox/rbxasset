local cli = require("@pkg/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local function parseProjectPath(parser: cli.Parser, flagName: string): path.path
	local userProjectPath = parser:get(flagName)

	if userProjectPath then
		local projectPath = path.resolve(userProjectPath)

		if fs.exists(projectPath) then
			return projectPath
		else
			error(`failed to find the project at {projectPath}. does the directory exist?`)
		end
	else
		return process.cwd()
	end
end

return parseProjectPath
