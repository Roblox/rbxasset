local frktest = require("@pkg/frktest")
local test = frktest.test
local check = frktest.assert.check

local createFormData = require("./createFormData")

local function assertStringsMatch(base: string, expected: string)
	local baseLines = {}
	for line in base:gmatch("[^\r\n]+") do
		table.insert(baseLines, line)
	end

	local expectedLines: { string } = {}
	for line in expected:gmatch("[^\r\n]+") do
		table.insert(expectedLines, line)
	end

	for index, baseLine in baseLines do
		local expectedLine = expectedLines[index]
		if baseLine ~= expectedLine then
			error(`strings do not match at line {index}\n- base: "{baseLine}"\n- expected: "{expectedLine}"`, 2)
		end
	end
end

test.case("automatically converts objects to json", function()
	local formData = createFormData({
		foo = {
			value = {
				bar = true,
				baz = "str",
			},
			contentType = "application/json",
		},
	})

	local match = formData.body:match('{"bar":true,"baz":"str"}')

	check.not_nil(match)
end)

test.case("body supports multiple parts", function()
	local formData = createFormData({
		request = {
			value = {
				assetType = "Image",
				displayName = "Display Name",
				creationContext = {
					creator = {
						userId = 12345678,
					},
				},
			},
			contentType = "application/json",
		},
		fileContent = {
			value = "image bytes go here",
			contentType = "image/png",
		},
	})

	local expected = table.concat({
		`--{formData.boundary}`,
		`Content-Disposition: form-data; name="request"`,
		"Content-Type: application/json",
		"",
		'{"assetType":"Image","creationContext":{"creator":{"userId":12345678}},"displayName":"Display Name"}',
		`--{formData.boundary}`,
		"",
		'Content-Disposition: form-data; name="fileContent"',
		"Content-Type: image/png",
		"",
		"image bytes go here",
		`--{formData.boundary}--`,
	}, "\r\n")

	assertStringsMatch(formData.body, expected)
end)

test.case("the boundary contains LuauFormBoundary", function()
	local formData = createFormData({
		foo = {
			value = "bar",
			contentType = "text/plain",
		},
	})
	local match = formData.boundary:match("LuauFormBoundary")
	check.not_nil(match)
end)
