local cli = require("@pkg/cli")

export type Subcommand = {
	parser: cli.Parser,
	run: () -> (),

	help: string?,
}

return nil
