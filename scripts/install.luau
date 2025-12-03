local fs = require("@lute/fs")

local run = require("@root/lib/run")

local PACKAGES_PATH = "pkg"
local PACKAGE_INDEX_NAME = "_Index"

local function installGitDependencies()
	local repos = {
		{ git = "osyrisrblx/t@1dbfccc1", main = "lib" },
	}

	for _, repo in repos do
		local parts = repo.git:split("@")
		local repoPath = parts[1]
		local rev = parts[2]

		local repoParts = repoPath:split("/")
		local projectName = repoParts[2]
		local dest = `{PACKAGES_PATH}/{PACKAGE_INDEX_NAME}/{projectName}`

		run("git", { "clone", `https://github.com/{repoPath}`, dest })

		run("git", { "reset", "--hard", rev }, {
			cwd = dest,
		})

		local linkerPath = `{PACKAGES_PATH}/{projectName}.luau`
		fs.writestringtofile(linkerPath, `return require("./{PACKAGE_INDEX_NAME}/{projectName}/{repo.main}")`)
	end
end

local function installLuteBatteries()
	local commit = "4c5adb2"
	local batteries = {
		"cli.luau",
		"toml.luau",
	}

	run("mkdir", { "-p", PACKAGES_PATH })
	for _, battery in batteries do
		run("curl", { "-LO", `https://raw.githubusercontent.com/luau-lang/lute/{commit}/batteries/{battery}` }, {
			cwd = PACKAGES_PATH,
		})
	end
end

run("rm", { "-rf", PACKAGES_PATH })

-- Setup typedefs for the current Lute version
run("lute", { "setup" })

installGitDependencies()
installLuteBatteries()
