local run = require("@root/lib/run")

run("luau-lsp", {
	"analyze",
	"--settings=.vscode/settings.json",

	"examples",
	"scripts",
	"src",
})
