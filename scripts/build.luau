local fs = require("@lune/fs")

local run = require("@root/lib/run")

local INCLUDES = {
	".luaurc",
	"init.luau",
	"LICENSE",
	"README.md",

	"src/",
	"pkg/",
}

local BUILD_PATH = "build"
local ARTIFACT_NAME = "rbxasset"
local ARCHIVE_NAME = "rbxasset.zip"
local ARTIFACT_PATH = `{BUILD_PATH}/{ARTIFACT_NAME}/`

run("rm", { "-rf", BUILD_PATH })
run("mkdir", { "-p", ARTIFACT_PATH })

for _, includeName in INCLUDES do
	if fs.isDir(includeName) then
		run("cp", { "-R", includeName, `{ARTIFACT_PATH}/{includeName}` })
	else
		run("cp", { includeName, ARTIFACT_PATH })
	end
end

run("zip", { "-r", ARCHIVE_NAME, ARTIFACT_NAME }, {
	cwd = BUILD_PATH,
})
