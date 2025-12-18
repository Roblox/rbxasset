local frktest = require("@pkg/frktest")
local test = frktest.test
local check = frktest.assert.check

local types = require("./types")

test.suite("validateManifest", function()
	test.case("accepts minimal manifest", function()
		local success = types.validateManifest({
			assets = {
				main = {
					name = "Asset Name",
					environment = "production",
					model = "asset.rbxm",
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = types.CreatorType.User,
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_true(success)
	end)

	test.case("accepts optional manifest values", function()
		local success = types.validateManifest({
			assets = {
				main = {
					name = "Asset Name",
					environment = "production",
					model = "asset.rbxm",
					description = "Asset description",
					icon = "icon.png",
					thumbnails = { "thumbnails/1.png" },
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = types.CreatorType.User,
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_true(success)
	end)

	test.case("denies empty assets object", function()
		local success, message = types.validateManifest({
			assets = {},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = types.CreatorType.User,
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
		check.equal(message, "at least one asset must be defined in the manifest")
	end)

	test.case("denies empty environments object", function()
		local success, message = types.validateManifest({
			assets = {
				main = {
					name = "Asset Name",
					description = "Asset description",
					icon = "icon.png",
					thumbnails = { "thumbnails/1.png" },
					environment = "does-not-exist",
					model = "asset.rbxm",
				},
			},
			environments = {},
		})

		check.is_false(success)
		check.equal(message, "at least one environment must be defined in the manifest")
	end)

	test.case("assets must map back to a valid environment", function()
		local success, message = types.validateManifest({
			assets = {
				main = {
					name = "Asset Name",
					description = "Asset description",
					icon = "icon.png",
					thumbnails = { "thumbnails/1.png" },
					environment = "does-not-exist",
					model = "asset.rbxm",
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = types.CreatorType.User,
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
		check.equal(message, `asset "main" attempts to use the environment "does-not-exist" which does not exist`)
	end)

	test.case("denies optional manifest values of the wrong type", function()
		local success = types.validateManifest({
			assets = {
				main = {
					name = "Asset Name",
					environment = "production",
					model = "asset.rbxm",
					description = 123456789,
					icon = false,
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = types.CreatorType.User,
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
	end)

	test.case("denies empty object", function()
		local success = types.validateManifest({})

		check.is_false(success)
	end)

	test.case("denies invalid types", function()
		local success = types.validateManifest({
			assets = {
				main = {
					name = false,
					environment = "production",
					model = "asset.rbxm",
				},
			},
			environments = {
				production = {
					creatorId = 1234567,
					creatorType = types.CreatorType.User,
					universeId = 10101010,
					placeId = 20202020,
				},
			},
		})

		check.is_false(success)
	end)
end)

test.suite("validateLockfile", function()
	test.case("must have an assetId", function()
		local success = types.validateLockfile({
			assets = {
				foo = {
					assetId = "123456789",
				},
			},
			images = {},
		})

		check.is_true(success)
	end)

	test.case("handles storing images", function()
		local success = types.validateLockfile({
			assets = {
				foo = {
					assetId = "123456789",
				},
			},
			images = {
				["icon.png"] = {
					assetId = "987654321",
					hash = "image-hash",
				},
			},
		})

		check.is_true(success)
	end)

	test.case("denies empty object", function()
		local success = types.validateLockfile({})

		check.is_false(success)
	end)
end)
