local fs = require("@lute/fs")
local json = require("@lute/std/json")

local executeLuauTask = require("@root/cloud/executeLuauTask")
local logging = require("@root/logging")
local run = require("@root/lib/run")

local TEMP_DIR = "temp"

local function buildLuauExecutionRobloxPlace(outputPath: string): string
	local rojoProjectPath = `{outputPath}/default.project.json`
	local placePath = `{outputPath}/build.rbxl`

	logging.info("creating Rojo project")
	local rojoProject = {
		name = "LuauExecutionPlace",
		tree = {
			["$className"] = "DataModel",
		},
	}

	fs.writestringtofile(rojoProjectPath, json.serialize(rojoProject))

	run("rojo", { "build", rojoProjectPath, "-o", placePath })

	return placePath
end

local function runLuauTask(
	scriptContent: string,
	globals: {
		[string]: string | number | boolean,
	},
	runnerContext: {
		universeId: number,
		placeId: number,
		apiKey: string,
		modelPath: string?,
	}
)
	run("rm", { "-rf", TEMP_DIR })

	if not fs.exists(TEMP_DIR) then
		fs.mkdir(TEMP_DIR)
	end

	local placePath = buildLuauExecutionRobloxPlace(TEMP_DIR)

	if runnerContext.modelPath then
		local game = roblox.deserializePlace(fs.readfiletostringtostring(placePath))
		local root = roblox.deserializeModel(fs.readfiletostringtostring(runnerContext.modelPath))
		for _, child in root do
			child.Parent = game:GetService("ReplicatedStorage")
			logging.debug(`parented {child} to ReplicatedStorage`)
		end
		fs.writestringtofile(placePath, roblox.serializePlace(game))
	end

	logging.info("substituting globals", globals)

	for global, value in globals do
		scriptContent = scriptContent:gsub(`= _G.{global}`, `= "{value}"`)
	end

	local variables =
		executeLuauTask(placePath, scriptContent, runnerContext.universeId, runnerContext.placeId, runnerContext.apiKey)

	run("rm", { "-rf", TEMP_DIR })

	return variables
end

return runLuauTask
