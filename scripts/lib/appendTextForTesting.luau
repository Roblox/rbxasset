local path = require("@std/path")
local stdfs = require("@std/fs")

local function appendTextForTesting(filePath: path.pathlike, text: string)
	local content = stdfs.readfiletostring(tostring(filePath))
	content ..= text
	stdfs.writestringtofile(tostring(filePath), content)
end

return appendTextForTesting
