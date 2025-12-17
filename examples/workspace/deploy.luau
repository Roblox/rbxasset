local rbxasset = require("@root/")

local process = require("@lute/process")

local args = { ... }

local apiKey = args[1]
assert(apiKey, "argument #1 must be a valid Open Cloud API key")

assert(
	process.cwd():match("examples/workspace"),
	"you must be in the `examples/workspace` folder when running this script"
)

process.system("rojo build -o ../package.rbxm", {
	cwd = "package",
})

process.system("rojo build -o ../plugin.rbxm", {
	cwd = "plugin",
})

rbxasset.publishWorkspaceAsync(process.cwd(), apiKey)
