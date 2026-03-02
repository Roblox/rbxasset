local cli = require("@pkg/cli")
local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local constants = require("@root/constants")
local readManifest = require("@root/manifest/readManifest")
local types = require("./types")

local ASSET_MANIFEST_FILENAME = constants.ASSET_MANIFEST_FILENAME

local args = cli.parser()

args:add("project-path", "option", {
	help = `Path to a directory containing an {ASSET_MANIFEST_FILENAME} file`,
	aliases = { "p" },
})

local command: types.Subcommand = {
	parser = args,
	run = function()
		local userProjectPathPath = args:get("project-path")

		local projectPath = if userProjectPathPath then path.resolve(userProjectPathPath) else process.cwd()
		local manifestPath = path.join(projectPath, ASSET_MANIFEST_FILENAME)

		if not fs.exists(projectPath) then
			print(`failed to find the project at {projectPath}. does the directory exist?`)
			process.exit(1)
			return
		end

		local success, err = pcall(function()
			readManifest(projectPath)
			return nil
		end)

		if not success then
			print(err)
			process.exit(1)
		end

		print(`manifest at {manifestPath} is valid`)
	end,
}

return command
