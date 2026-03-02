local run = require("@root/lib/run")

local foldersToLint = {
	"examples",
	"scripts",
	"src",
}

run("selene", foldersToLint)

run("stylua", {
	"--check",
	table.unpack(foldersToLint),
})
