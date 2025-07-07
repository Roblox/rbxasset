local run = require("@root/lib/run")

local foldersToAnalyze = {
	".lune",
	"src",
	"examples",
}

run("luau-lsp", { "analyze", "--ignore=**/pkg/**", table.unpack(foldersToAnalyze) })
