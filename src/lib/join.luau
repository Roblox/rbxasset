-- upstream: https://github.com/cxmeel/sift/blob/3f2a0f435965bddca008e620f8bdddb655e84ea7/src/Dictionary/merge.lua

local function join<T>(...: any): T
	local result = {}

	for dictionaryIndex = 1, select("#", ...) do
		local dictionary = select(dictionaryIndex, ...)

		if type(dictionary) ~= "table" then
			continue
		end

		for key, value in dictionary do
			result[key] = value
		end
	end

	return (result :: any) :: T
end

return join
