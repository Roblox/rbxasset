local rbxasset = require("@root")

local process = require("@lute/process")

assert(process.cwd():match("examples/plugin"), "you must be in the `examples/plugin` folder when running this script")

process.system("rojo build -o plugin.rbxm")

rbxasset.publishPackageAsync(process.cwd(), "plugin", process.env.ROBLOX_API_KEY)
