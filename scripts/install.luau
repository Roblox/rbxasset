local fs = require("@std/fs")
local path = require("@std/path")
local process = require("@lute/process")

local PACKAGES_PATH = "pkg"
local PACKAGE_INDEX_NAME = "_Index"

-- Install Lute batteries first since some core functions (like `run`)
-- depend on them, and it makes it really hard to write install steps
-- without those functions
do
	fs.removedirectory(PACKAGES_PATH, { recursive = true })
	fs.createdirectory(PACKAGES_PATH)

	local function installLuteBatteries()
		local commit = "fc19ad0"
		local batteries = {
			"cli.luau",
			"pp.luau",
			--[[
				TODO: Install the TOML battery once this issue is fixed:
				https://github.com/luau-lang/lute/issues/643

				Currently we use a patched version of this module at
				`src/lib/toml.luau` which supports quoted dictionary keys.
			]]
			-- "toml.luau",
			"richterm.luau",
		}

		for _, battery in batteries do
			print(`installing Lute battery: {battery}`)

			process.run({
				"curl",
				"-LO",
				`https://raw.githubusercontent.com/luau-lang/lute/{commit}/batteries/{battery}`,
			}, {
				stdio = "inherit",
				cwd = PACKAGES_PATH,
			})
		end
	end

	installLuteBatteries()
end

-- Now we can take care of everything else
do
	local run = require("@root/lib/run")

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
			local dest = path.join(PACKAGES_PATH, PACKAGE_INDEX_NAME, projectName)

			run("git", { "clone", `https://github.com/{repoPath}`, tostring(dest) })

			run("git", { "reset", "--hard", rev }, {
				cwd = tostring(dest),
			})

			local linkerPath = path.join(PACKAGES_PATH, `{projectName}.luau`)
			fs.writestringtofile(linkerPath, `return require("./{PACKAGE_INDEX_NAME}/{projectName}/{repo.main}")`)
		end
	end

	-- Setup typedefs for the current Lute version
	run("lute", { "setup" })

	installGitDependencies()
end
