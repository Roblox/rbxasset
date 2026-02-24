local fs = require("@lute/fs")
local path = require("@std/path")
local toml = require("@root/lib/toml")

local constants = require("@root/constants")
local logging = require("@root/logging")
local types = require("@root/types")

type Lockfile = types.Lockfile

local function writeLockfile(packagePath: path.pathlike, lockfile: Lockfile)
	local lockfilePath = path.join(packagePath, constants.ASSET_LOCKFILE_FILENAME)
	local handle = fs.open(tostring(lockfilePath), "w+")
	fs.write(handle, toml.serialize(lockfile))
	fs.close(handle)

	logging.debug(`wrote asset lockfile {lockfilePath}`)
end

return writeLockfile
