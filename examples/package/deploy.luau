local path = require("@std/path")
local process = require("@std/process")

local rbxasset = require("@root")

local args = { ... }
local cwd = path.dirname(args[1])

process.system("rojo build -o asset.rbxm", {
	cwd = cwd,
})

rbxasset.publishPackageAsync(cwd, "package", process.env.ROBLOX_API_KEY)
