local fs = require("@std/fs")
local path = require("@std/path")

local function appendTextForTesting(filePath: path.pathlike, text: string)
	local content = fs.readfiletostring(tostring(filePath))
	content ..= text
	fs.writestringtofile(tostring(filePath), content)
end

return appendTextForTesting
