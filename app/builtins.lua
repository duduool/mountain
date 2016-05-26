require("mobdebug").start('192.168.50.65')

--ngx.say(ngx.var.uri)
--ngx.say(ngx.var.request_uri)
--ngx.say(ngx.var.arg_a)
--ngx.say(ngx.var.args)

--ngx.req.read_body()
--local a = ngx.req.get_uri_args()
--local b = ngx.req.get_post_args()

local cjson = import "cjson"

ngx.say(ngx.var.host)
ngx.say(ngx.var.hostname)
ngx.say(ngx.var.request)
ngx.say(ngx.var.remote_addr)
ngx.say(ngx.var.request_body)
ngx.say(ngx.var.server_name)

ngx.say(cjson.encode({name="qiaox", age=22}))
--local s = "{'cat': 'mimi', 'dog': 'wangwang'}"
--local r = cjson.decode(s)
--ngx.say(type(r))

local http = import "resty.http"
local cli = http.new()

local res, err = cli:request_uri("http://httpbin.org/post", {
    method = "POST",
    body = "a=1&b=2",
    headers = {
        ["Content-Type"] = "application/x-www-form-urlencoded"
    }
})

if not res then
    ngx.say("failed to request: ", err)
    return
end

ngx.status = res.status

for k, v in pairs(res.headers) do
end

ngx.say(res.body)

require("mobdebug").done()
