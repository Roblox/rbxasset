local rbxasset = require("@root/init")

local process = require("@lute/process")

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

rbxasset.publishWorkspaceAsync(process.cwd(), process.env.ROBLOX_API_KEY)
