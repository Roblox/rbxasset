local path = require("@std/path")
local process = require("@lute/process")

local rbxasset = require("@root")

local args = { ... }
local cwd = path.dirname(args[1])

process.system("rojo build -o plugin.rbxm", {
	cwd = cwd,
})

rbxasset.publishPackageAsync(cwd, "plugin", process.env.ROBLOX_API_KEY)
