local fs = require("@lune/fs")
local serde = require("@lune/serde")

local constants = require("@root/constants")
local join = require("@root/lib/join")
local logging = require("@root/logging")
local types = require("@root/types")

type Lockfile = types.Lockfile

local function getOrCreateAssetLockfile(packagePath: string): Lockfile
	local lockfilePath = `{packagePath}/{constants.ASSET_LOCKFILE_FILENAME}`

	-- It's expected that the lockfile won't exist in certain situations, like
	-- on the first upload of the asset. So we just catch any error here
	local content: string
	local success = pcall(function()
		content = fs.readFile(lockfilePath)
	end)

	local parsedLockfile = if success then serde.decode("toml", content) else nil
	local lockfile: Lockfile = join({
		assets = {},
		images = {},
	}, parsedLockfile)

	local isLockfileValid, message = types.validateLockfile(lockfile)
	assert(isLockfileValid, `failed to parse asset lockfile at {lockfilePath}: {message}`)

	logging.debug(`loaded asset lockfile {lockfile}`)

	return lockfile
end

return getOrCreateAssetLockfile
