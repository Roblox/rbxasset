local path = require("@std/path")
local stdfs = require("@std/fs")
local toml = require("@root/lib/toml")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Lockfile = types.Lockfile

local function writeLockfile(packagePath: path.pathlike, lockfile: Lockfile)
	local lockfilePath = path.join(packagePath, constants.ASSET_LOCKFILE_FILENAME)
	stdfs.writestringtofile(lockfilePath, toml.serialize(lockfile :: { [unknown]: unknown }))
	logging.debug(`wrote asset lockfile {lockfilePath}`)
end

return writeLockfile
