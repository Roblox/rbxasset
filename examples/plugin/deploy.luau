local path = require("@std/path")
local process = require("@lute/process")

local rbxasset = require("@root")

process.system(`rojo build -o {path.resolve("./plugin.rbxm")}`)

rbxasset.publishPackageAsync(path.resolve("."), "plugin", process.env.ROBLOX_API_KEY)
