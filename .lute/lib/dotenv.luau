local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@std/process")

local DOTENV_FILE_NAME = ".env"

local function dotenv()
	local current = process.cwd()
	local env: { [string]: string } = {}

	for _, file in fs.listdirectory(current) do
		local filePath = path.join(current, file.name)
		if file.name == DOTENV_FILE_NAME then
			local content = fs.readfiletostring(filePath)

			for line in content:gmatch("[^\r\n]+") do
				local key, value = line:match("([%u_]+)[%s+]?=[%s+]?(.*)")

				if key and value and value ~= "" then
					value = value:gsub('"', "")
					env[key] = value
				end
			end
		end
	end

	for key, value in env do
		process.env[key] = value
	end
end

return dotenv
