local path = require("@std/path")
local process = require("@lute/process")

local rbxasset = require("@root")

local args = { ... }
local cwd = path.dirname(args[1])

process.system("rojo build -o package.rbxm", {
	cwd = tostring(path.join(cwd, "package")),
})
process.system("rojo build -o plugin.rbxm", {
	cwd = tostring(path.join(cwd, "plugin")),
})

rbxasset.publishWorkspaceAsync(cwd, process.env.ROBLOX_API_KEY)
