local run = require("@root/lib/run")

local foldersToAnalyze = {
	"examples",
	"scripts",
	"src",
}

run("luau-lsp", {
	"analyze",
	"--settings=.vscode/settings.json",
	`--ignore="**/pkg/**"`,
	"--platform=standard",
	table.unpack(foldersToAnalyze),
})
