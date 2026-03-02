local path = require("@std/path")
local process = require("@std/process")

local rbxasset = require("@root")

local args = { ... }
local cwd = path.dirname(args[1])

process.system("rojo build package -o package.rbxm", {
	cwd = cwd,
})
process.system("rojo build plugin -o plugin.rbxm", {
	cwd = cwd,
})

rbxasset.publishWorkspaceAsync(cwd, process.env.ROBLOX_API_KEY)
