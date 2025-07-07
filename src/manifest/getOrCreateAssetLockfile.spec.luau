local frktest = require("@pkg/frktest")
local test = frktest.test
local check = frktest.assert.check

local getOrCreateAssetLockfile = require("./getOrCreateAssetLockfile")

test.case("reads an asset lockfile from disk", function()
	local lockfile = getOrCreateAssetLockfile("examples/package")
	check.equal(lockfile.assets["package"].assetId, "120786139379662")
end)

test.case("creates a blank asset lockfile when not found on disk", function()
	local lockfile = getOrCreateAssetLockfile("/nowhere")
	check.table.equal(lockfile, {
		assets = {},
		images = {},
	})
end)
