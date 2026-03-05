local expect = require("@std/test/assert")
local test = require("@std/test")

local getOrCreateAssetLockfile = require("./getOrCreateAssetLockfile")

test.case("reads an asset lockfile from disk", function()
	local lockfile = getOrCreateAssetLockfile("examples/package")
	expect.neq(lockfile.assets["package"].assetId, nil)
end)

test.case("creates a blank asset lockfile when not found on disk", function()
	local lockfile = getOrCreateAssetLockfile("/nowhere")
	expect.tableeq(lockfile :: { [unknown]: unknown }, {
		assets = {},
		images = {},
	})
end)
