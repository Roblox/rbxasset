local rbxasset = require("@root/init")

local process = require("@lute/process")

assert(process.cwd():match("examples/package"), "you must be in the `examples/package` folder when running this script")

process.system("rojo build -o asset.rbxm")

rbxasset.publishPackageAsync(process.cwd(), "package", process.env.ROBLOX_API_KEY)
