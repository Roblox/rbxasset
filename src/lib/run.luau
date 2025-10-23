local process = require("@lute/process")

local logging = require("@root/logging")

type Options = {
	cwd: string?,
	env: { [string]: string }?,
}

local function run(program: string, params: { string }, options: Options?): string
	local command = `{program} {table.concat(params, " ")}`
	logging.debug(`RUN > {command}`)

	local result = process.run(command, {
		stdio = "inherit",
		shell = true,
		cwd = if options then options.cwd else nil,
		env = if options then options.env else nil,
	})

	if result.ok then
		local message = result.stdout:gsub("\n$", "")
		return message
	else
		error(result.stderr)
	end
end

return run
