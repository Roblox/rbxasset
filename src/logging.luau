local process = require("@lute/process")
local richterm = require("@pkg/richterm")

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
		print(richterm.blue(`[info] {...}`))
	end
end

function logging.warn(...)
	if canLog("warn") then
		print(richterm.yellow(`[warn] {...}`))
	end
end

function logging.err(...)
	if canLog("err") then
		print(richterm.red(`[err] {...}`))
	end
end

function logging.debug(...)
	if canLog("debug") then
		print(richterm.black(`[debug] {...}`))
	end
end

return logging
