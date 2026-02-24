local path = require("@std/path")
local process = require("@lute/process")

local rbxasset = require("@root")

process.system(`rojo build -o {path.resolve("./asset.rbxm")}`)

rbxasset.publishPackageAsync(path.resolve("."), "package", process.env.ROBLOX_API_KEY)
