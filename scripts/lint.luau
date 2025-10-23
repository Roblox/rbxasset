local run = require("@root/lib/run")

local foldersToLint = {
	".lune",
	"src",
	"examples",
}

run("selene", foldersToLint)

run("stylua", {
	"--check",
	table.unpack(foldersToLint),
})
