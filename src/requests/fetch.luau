local json = require("@std/json")
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

	local res = net.request(url, {
		method = method,
		headers = options.headers,
		body = options.body,
	})

	if res.ok then
		return res
	else
		-- FIXME: Narrow the return value of `json.deserialize` instead of
		-- casting to `any`
		local body: any = json.deserialize(res.body)

		local problems: { string } = {}
		if body.errors then
			for _, err in body.errors do
				table.insert(problems, err.message :: string)
			end
		elseif body.message then
			table.insert(problems, body.message :: string)
		end

		error(
			`{res.status} {res.body} when attempting to {method} {url}`
				.. if #problems > 0 then `: {table.concat(problems, ", ")}` else "",
			2
		)
	end
end

return fetch
