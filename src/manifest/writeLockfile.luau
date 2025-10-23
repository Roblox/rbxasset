local fs = require("@lute/fs")
local toml = require("@pkg/toml")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Lockfile = types.Lockfile

local function writeLockfile(packagePath: string, lockfile: Lockfile)
	local lockfilePath = `{packagePath}/{constants.ASSET_LOCKFILE_FILENAME}`
	fs.writestringtofile(lockfilePath, toml.serialize(lockfile))

	logging.debug(`wrote asset lockfile {lockfilePath}`)
end

return writeLockfile
