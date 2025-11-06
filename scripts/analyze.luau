local run = require("@root/lib/run")

run(
	"luau-lsp",
	{
		"analyze",
		"--settings=.vscode/settings.json",
		`--ignore="**/pkg/**"`,
		"--platform=standard",

		"examples",
		"scripts",
		"src",
	} :: { string }
)
