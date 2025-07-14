local fs = require("@lune/fs")

local run = require("@root/lib/run")

local packages = "pkg"
local packageIndex = "_Index"

local repos = {
	{ git = "itsfrank/frktest@31770327", main = "src" },
	{ git = "osyrisrblx/t@1dbfccc1", main = "lib" },
}

run("rm", { "-rf", packages })

for _, repo in repos do
	local parts = repo.git:split("@")
	local repoPath = parts[1]
	local rev = parts[2]

	local repoParts = repoPath:split("/")
	local projectName = repoParts[2]
	local dest = `{packages}/{packageIndex}/{projectName}`

	run("git", { "clone", `https://github.com/{repoPath}`, dest })

	run("git", { "reset", "--hard", rev }, {
		cwd = dest,
	})

	local linkerPath = `{packages}/{projectName}.luau`
	fs.writeFile(linkerPath, `return require("./{packageIndex}/{projectName}/{repo.main}")`)
end
