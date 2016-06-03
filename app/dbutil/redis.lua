local redis = require("resty.redis")

local Redis = {}

function Redis:get_redis()
    local red = redis:new()
    red:select(1)
    local ok, err = red:connect("192.168.50.202", "6379")
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect:", err)
        return
    end
    return red
end

function Redis:set(k, v)
    local ok, err = self:get_redis():set("dog", "an animal")
    if not ok then
        ngx.log(ngx.ERR, "Failed to set:", k, err)
        return
    end
end

function Redis:get(k)
    local red = redis:new()
    local ok, err = red:connect("192.168.50.202", "6379")
    if not ok then
        ngx.log(ngx.ERR, "Failed to connect:", err)
        return
    end
    red:select(1)
    local result = red:get(k)
    return result
end

return Redis