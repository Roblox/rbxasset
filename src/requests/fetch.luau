local json = require("@lute/std/json")
local net = require("@lute/net")

local logging = require("@root/logging")

type HttpMethod = "GET" | "POST" | "PATCH"

type FetchOptions = {
	method: HttpMethod?,
	headers: { [string]: string }?,
	body: string?,
}

local function fetch(url: string, options: FetchOptions)
	local method: HttpMethod = options.method or "GET"

	logging.debug(`{method} {url}`)

	net.request(url)

	local res = net.request(url, {
		method = method :: string,
		headers = options.headers,
		body = options.body,
	})

	if res.ok then
		return res
	else
		-- TODO: This block might need to be revised to work with Lute

		-- FIXME: Narrow the return value of `json.deserialize` instead of casting to `any`
		local body: any = json.deserialize(res.body)

		local problems: { string } = {}
		if body.errors then
			for _, err in body.errors do
				table.insert(problems, err.message)
			end
		end

		error(
			`{res.status} {res.body} when attempting to {method} {url}`
				.. if #problems > 0 then `: {table.concat(problems, ", ")}` else "",
			2
		)
	end
end

return fetch
