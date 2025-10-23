local assert = require("@std/assert")
local test = require("@std/test")

local getOrCreateAssetLockfile = require("./getOrCreateAssetLockfile")

test.case("reads an asset lockfile from disk", function()
	local lockfile = getOrCreateAssetLockfile("examples/package")
	assert.eq(lockfile.assets["package"].assetId, "120786139379662")
end)

test.case("creates a blank asset lockfile when not found on disk", function()
	local lockfile = getOrCreateAssetLockfile("/nowhere")
	assert.tableeq(lockfile, {
		assets = {},
		images = {},
	})
end)
