local rbxasset = require("@root/")

local process = require("@lute/process")

local apiKey = process.args[1]
assert(apiKey, "argument #1 must be a valid Open Cloud API key")

assert(process.cwd:match("examples/plugin"), "you must be in the `examples/plugin` folder when running this script")

process.exec("rojo", { "build", "-o", "plugin.rbxm" })

rbxasset.publishPackageAsync(process.cwd, "plugin", apiKey)
