local run = require("@root/lib/run")

local foldersToAnalyze = {
	"examples",
	"scripts",
	"src",
}

run("luau-lsp", {
	"analyze",
	`--ignore="**/pkg/**"`,
	"--platform=standard",
	"--flag:LuauSolverV2=true",
	table.unpack(foldersToAnalyze),
})
