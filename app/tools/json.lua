local json = require("cjson")
local str = [[ {
					"name": "qiaox",
					"age": "22"
				} ]]

local t = json.decode(str)
ngx.say("-->", type(t))
for k, v in pairs(t) do
    ngx.say(k, v)
end
ngx.print("Hello, world")

