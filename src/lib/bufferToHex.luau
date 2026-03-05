local function bufferToHex(buf: buffer): string
	local hex = ""
	for i = 0, buffer.len(buf) - 1 do
		hex ..= ("%02x"):format(buffer.readu8(buf, i))
	end
	return hex
end

return bufferToHex
