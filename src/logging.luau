local process = require("@lute/process")
-- local stdio = require("@lute/stdio")

type LogLevel = "info" | "warn" | "err" | "debug"

local LOG_LEVEL_ORDER = {
	"err",
	"info",
	"warn",
	"debug",
}

local function getLogLevel(): LogLevel
	local logLevel = process.env.LOG_LEVEL
	if logLevel and logLevel ~= "" then
		return logLevel:lower() :: LogLevel
	else
		return "info"
	end
end

local function canLog(logLevelToCheck: LogLevel): boolean
	local maxPriority = table.find(LOG_LEVEL_ORDER, getLogLevel())
	local priorityToCheck = table.find(LOG_LEVEL_ORDER, logLevelToCheck)

	if maxPriority and priorityToCheck then
		return priorityToCheck <= maxPriority
	else
		return false
	end
end

local logging = {}

function logging.info(...)
	if canLog("info") then
		print(`[info]`, ...)
	end
end

function logging.warn(...)
	if canLog("warn") then
		-- stdio.write(stdio.color("yellow"))
		print(`[warn]`, ...)
		-- stdio.write(stdio.color("reset"))
	end
end

function logging.err(...)
	if canLog("err") then
		-- stdio.write(stdio.color("red"))
		print(`[err]`, ...)
		-- stdio.write(stdio.color("reset"))
	end
end

function logging.debug(...)
	if canLog("debug") then
		-- stdio.write(stdio.color("black"))
		print(`[debug]`, ...)
		-- stdio.write(stdio.color("reset"))
	end
end

return logging
