local path = require("@std/path")
local process = require("@lute/process")

local rbxasset = require("@root")

process.system(`rojo build -o {path.resolve("./package.rbxm")}`, {
	cwd = path.resolve("./package/"),
})
process.system(`rojo build -o {path.resolve("./plugin.rbxm")}`, {
	cwd = path.resolve("./plugin/"),
})

rbxasset.publishWorkspaceAsync(path.resolve("."), process.env.ROBLOX_API_KEY)
