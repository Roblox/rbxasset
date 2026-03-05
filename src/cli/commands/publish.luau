local cli = require("@pkg/cli")

local parseApiKey = require("@root/cli/parsers/parseApiKey")
local parseProjectPath = require("@root/cli/parsers/parseProjectPath")
local publishPackageAsync = require("@root/requests/publishPackageAsync")
local publishWorkspaceAsync = require("@root/requests/publishWorkspaceAsync")
local types = require("@root/cli/types")

local args = cli.parser()

args:add("asset", "option", {
	help = "Name of one of the assets defined in rbxasset.toml that will be published",
	aliases = { "a" },
})
args:add("project-path", "option", {
	help = "Path to a directory containing an rbxasset.toml manifest",
	aliases = { "c" },
})
args:add("api-key", "option", {
	help = "Open Cloud API key with `asset:read` and `asset:write` scopes",
	aliases = { "k" },
})

local command: types.Subcommand = {
	parser = args,
	run = function()
		local projectPath = parseProjectPath(args, "project-path")
		local apiKey = parseApiKey(args, "api-key")
		local assetName = args:get("asset")

		print(`using project at {projectPath}`)

		if assetName then
			publishPackageAsync(projectPath, assetName, apiKey)
		else
			publishWorkspaceAsync(projectPath, apiKey)
		end
	end,
}

return command
