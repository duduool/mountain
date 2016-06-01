local redis = require("resty.redis")

function get_redis()
    local cache = redis:new()
    local ok, err = cache:connect("127.0.0.1", "6379")

    ok, err = cache:set("dog", "an animal")
    if not ok then
        ngx.say("Failed to set dog:", err)
        return
    end
    ngx.say("Set result:", ok)
end

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
