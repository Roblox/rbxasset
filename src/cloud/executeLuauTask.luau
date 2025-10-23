local json = require("@lute/std/json")

local logging = require("@root/logging")
local types = require("@root/types")

local createLuauTask = require("./createLuauTask")
local fetchLuauTaskLogs = require("./fetchLuauTaskLogs")
local getVariablesFromTaskLogs = require("./getVariablesFromTaskLogs")
local publishPlaceAsync = require("./publishPlaceAsync")
local waitForTaskCompletion = require("./waitForTaskCompletion")

type AssetId = types.AssetId

local function executeLuauTask(
	placePath: string,
	scriptContent: string,
	universeId: AssetId,
	placeId: AssetId,
	apiKey: string
): { [string]: string }?
	publishPlaceAsync(placePath, universeId, placeId, apiKey)

	local boundary = ("-"):rep(80)
	logging.debug(`executing script content\n{boundary}\n{scriptContent}\n{boundary}`)

	logging.info("starting Luau task...")
	local luauTask = createLuauTask(scriptContent, universeId, placeId, apiKey)
	logging.debug(`task created: {luauTask.path}`)

	logging.info("waiting for task to complete...")
	local completedLuauTask = waitForTaskCompletion(luauTask.path, apiKey)
	logging.debug(`task is now in {completedLuauTask.state} state`)

	local logs = fetchLuauTaskLogs(completedLuauTask.path, apiKey)
	if #logs == 0 then
		logging.info("the task did not produce any logs")
		return {}
	end

	logging.info("task output:")
	for _, l in logs do
		logging.info(`  {l}`)
	end

	local variables = getVariablesFromTaskLogs(logs)

	if variables then
		logging.debug("extracted variables from output:")
		for key, value in variables do
			logging.debug(`  {key}="{value}"`)
		end
	end

	if completedLuauTask.state == "COMPLETE" then
		if completedLuauTask.output.results then
			logging.info("task output:")
			logging.info(json.serialize(completedLuauTask.output.results, true))
		else
			logging.info("the task did not return any results")
		end
	else
		logging.err(`Task failed, error:\n{json.serialize(completedLuauTask.error)}`)
	end

	return variables
end

return executeLuauTask
