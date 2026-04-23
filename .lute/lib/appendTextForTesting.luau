local fs = require("@std/fs")
local path = require("@std/path")

local function appendTextForTesting(filePath: path.Pathlike, text: string)
	local handle = fs.open(filePath, "a+")
	fs.write(handle, text)
	fs.close(handle)
end

return appendTextForTesting
