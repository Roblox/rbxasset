local run = require("@root/lib/run")

local foldersToAnalyze = {
	".lune",
	"src",
	"examples",
}

run("luau-lsp", { "analyze", `--ignore="**/pkg/**"`, "--platform=standard", table.unpack(foldersToAnalyze) })
