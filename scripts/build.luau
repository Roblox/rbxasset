local fs = require("@std/fs")
local path = require("@std/path")
local system = require("@std/system")

local run = require("@root/lib/run")

local INCLUDES = {
	".luaurc",
	"init.luau",
	"LICENSE",
	"README.md",

	"src/",
	"pkg/",
}

local ARTIFACT_NAME = "rbxasset"
local ARCHIVE_NAME = "rbxasset.zip"

local BUILD_PATH = path.resolve("./build")
local PACKAGE_BUILD_PATH = path.join(BUILD_PATH, ARTIFACT_NAME)
local CLI_BUILD_PATH = path.join(PACKAGE_BUILD_PATH, "src/cli/init.luau")
local BINARY_BUILD_PATH = path.join(BUILD_PATH, "bin")

local function compilePackage()
	fs.createdirectory(PACKAGE_BUILD_PATH, {
		makeparents = true,
	})

	for _, includeName in INCLUDES do
		if fs.type(includeName) == "dir" then
			run("cp", { "-R", includeName, tostring(path.join(PACKAGE_BUILD_PATH, includeName)) })
		else
			run("cp", { includeName, tostring(PACKAGE_BUILD_PATH) })
		end
	end
end

local function compileBinary()
	fs.createdirectory(BINARY_BUILD_PATH, {
		makeparents = true,
	})

	local binaryName = if system.win32 then `{ARTIFACT_NAME}.exe` else ARTIFACT_NAME

	run("lute", {
		"compile",
		tostring(CLI_BUILD_PATH),
		"--output",
		tostring(path.join(BINARY_BUILD_PATH, binaryName)),
		"--bundle-stats",
	})
end

fs.removedirectory(BUILD_PATH, {
	recursive = true,
})

compilePackage()
compileBinary()

run("zip", { "-r", ARCHIVE_NAME, ARTIFACT_NAME }, {
	cwd = tostring(BUILD_PATH),
})
