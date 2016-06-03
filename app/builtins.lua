require("mobdebug").start('192.168.50.65')

local cjson = import "cjson"
local http = import "resty.http"
local mysql = import "resty.mysql"

-- http://www.example.com/get/info?name=qiaox&age=22

function ngx_var()
    --ngx.say(ngx.var.uri)              --/get/info
    --ngx.say(ngx.var.request_uri)      --/get/info?name=qiaox&age=22
    --ngx.say(ngx.var.arg_name)         --qiaox
    --ngx.say(ngx.var.args)             --"name=qiaox&age=22"

    --ngx.req.read_body()
    --ngx.say(ngx.req.get_uri_args())   --{name="qiaox", age="22"}
    --ngx.say(ngx.req.get_post_args())
    ngx.say(ngx.var.host)
    ngx.say(ngx.var.hostname)
    ngx.say(ngx.var.request)
    ngx.say(ngx.var.remote_addr)
    ngx.say(ngx.var.request_body)
    ngx.say(ngx.var.server_name)
end

function tjson()
    ngx.say(cjson.encode({name="qiaox", age=22}))
    --local s = "{'cat': 'mimi', 'dog': 'wangwang'}"
    --local r = cjson.decode(s)
    --ngx.say(type(r))
end

function thttp()
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
end

function tmysql()
    local db = mysql:new()
    db:set_timeout(3000)
    db:connect({
        host = "192.168.50.202",
        port = 3306,
        user = "test",
        password = "123456",
        database = "test",
        max_packet_size = 1024 * 1024
    })
    local res = db:query("SELECT * FROM people", 10) -- 此处res类型 {{f_id=..}, {f_id=..}, {}}
    for k, v in pairs(res[1]) do
        ngx.say(k, ": ", v)
    end

    ngx.say(cjson.encode(res))
    db:set_keepalive(10000, 100)
    db:close()
end

thttp()

require("mobdebug").done()
