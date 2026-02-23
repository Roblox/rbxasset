--!nonstrict

local expect = require("@std/test/assert")
local test = require("@std/test")

local toml = require("./toml")

test.case("should parse quoted keys with dots correctly", function()
	local input = [[
[assets.package]
assetId = "120786139379662"

[images."icon.png"]
assetId = "95124518202499"
hash = "fac185770cf5e824d4c0a9b59e547df42dc10011c5ad139bfc2c7e1507eef631"
]]

	local result = toml.deserialize(input)

	expect.neq(result.assets, nil)
	expect.neq(result.assets.package, nil)
	expect.eq(result.assets.package.assetId, "120786139379662")

	expect.neq(result.images, nil)
	expect.neq(result.images["icon.png"], nil)
	expect.eq(result.images["icon.png"].assetId, "95124518202499")
	expect.eq(result.images["icon.png"].hash, "fac185770cf5e824d4c0a9b59e547df42dc10011c5ad139bfc2c7e1507eef631")
end)

test.case("should handle multiple quoted keys in path", function()
	local input = [[
["outer.key"."inner.key"]
value = "test"
]]

	local result = toml.deserialize(input)

	expect.neq(result["outer.key"], nil)
	expect.neq(result["outer.key"]["inner.key"], nil)
	expect.eq(result["outer.key"]["inner.key"].value, "test")
end)

test.case("should handle mixed quoted and unquoted keys", function()
	local input = [[
[section."quoted.key".another]
value = "mixed"
]]

	local result = toml.deserialize(input)

	expect.neq(result.section, nil)
	expect.neq(result.section["quoted.key"], nil)
	expect.neq(result.section["quoted.key"].another, nil)
	expect.eq(result.section["quoted.key"].another.value, "mixed")
end)

test.case("should handle single-quoted keys", function()
	local input = [[
[images.'icon.png']
assetId = "123"
]]

	local result = toml.deserialize(input)

	expect.neq(result.images, nil)
	expect.neq(result.images["icon.png"], nil)
	expect.eq(result.images["icon.png"].assetId, "123")
end)
