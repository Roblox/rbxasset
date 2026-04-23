local fs = require("@std/fs")
local path = require("@std/path")

local run = require("@root/lib/run")

local INCLUDES = {
	".config.luau",
	"init.luau",
	"LICENSE",
	"README.md",

	"src/",
	"Packages/",
}

local BUILD_PATH = "build"
local ARTIFACT_NAME = "rbxasset"
local ARCHIVE_NAME = "rbxasset.zip"
local ARTIFACT_PATH = path.join(BUILD_PATH, ARTIFACT_NAME)

fs.removeDirectory(BUILD_PATH, {
	recursive = true,
})
fs.createDirectory(ARTIFACT_PATH, {
	makeParents = true,
})

for _, includeName in INCLUDES do
	if fs.type(includeName) == "dir" then
		run("cp", { "-R", includeName, tostring(path.join(ARTIFACT_PATH, includeName)) })
	else
		run("cp", { includeName, tostring(ARTIFACT_PATH) })
	end
end

run("zip", { "-r", ARCHIVE_NAME, ARTIFACT_NAME }, {
	cwd = BUILD_PATH,
})
