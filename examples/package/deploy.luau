local rbxasset = require("@root/")

local process = require("@lute/process")

local args = { ... }

local apiKey = args[1]
assert(apiKey, "argument #1 must be a valid Open Cloud API key")

assert(process.cwd():match("examples/package"), "you must be in the `examples/package` folder when running this script")

process.system("rojo build -o asset.rbxm")

rbxasset.publishPackageAsync(process.cwd(), "package", apiKey)
