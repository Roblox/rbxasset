local process = require("@std/process")

process.run({ "lute", "setup" }, { stdio = "inherit" })
process.run({ "lute", "pkg", "install" }, { stdio = "inherit" })
