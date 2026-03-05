local run = require("@root/lib/run")

local foldersToLint = {
	"examples",
	".lute",
	"src",
}

run("selene", foldersToLint)

run("stylua", {
	"--check",
	table.unpack(foldersToLint),
})
