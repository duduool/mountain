require("mobdebug").start('192.168.50.65')

local luazmq    = import "resty.lua_zmq"
local redis     = import "dbutil.redis"
local router    = import "router.router"
local datetime  = import "resty.datetime"
local cjson     = import "cjson"

local r = router:new()

local zmq = luazmq.NewZMQContext()
local socket = zmq:NewSocket(ZMQ_REQ)
socket:Connect("tcp://127.0.0.1:5555")


function zq_info(params)
    local k = params["key"] or "touch_score:zq:info:jczq_"
    local res = redis:get(k)
    local data = {
        ["status"] = "100",
        ["message"] = "OK",
        ["data"] = cjson.decode(res),
    }

    ngx.say(cjson.encode(data))
end

function zmq_client(params)
    socket:Send("hello server!")
end

r:match({
    GET = {
        ["/"]              = function(params) ngx.print("hello, world") end,
        ["/hello"]         = function(params) ngx.print("someone said hello") end,
        ["/hello/:name"]   = function(params) ngx.print("hello, " .. params.name) end,
        ["/score/zq/info"] = zq_info,
        ["/zmq"]           = zmq_client,
        ["/today"] = function(params)
            local today = datetime:new()
            ngx.say(today())
        end,
        ["/path"] = function(params)
            ngx.say("lua path: ", package.path)
            ngx.say("lua cpath: ", package.cpath)
        end,
        ["/pwd"] = function(params)
            local fname = "/tmp/pwd.out" assert(os.execute("pwd > " .. fname) == 0)
            local f = io.open(fname, "r") assert(f)
            local content = f:read("*a")
            f:close()

            ngx.say("pwd: ", content)
        end,

    },
    POST = {
        ["/app/:id/comments"] = function(params)
            -- ngx.print("comment" .. params.comment .. "created on app" .. params.id)
            ngx.say(params["comment"])
            ngx.req.read_body()
--            local data = ngx.req.get_body_data()
--            ngx.say(data)
            local file = ngx.req.get_body_file()
            ngx.say(file)
        end
    }
})

local ok, err = r:execute(
    ngx.var.request_method,
    ngx.var.uri,
    ngx.req.get_uri_args(),
    ngx.req.get_post_args(),
    {other_arg = 1}
)

if ok then
    --ngx.status = 200 -- 这个地方改状态貌似木有用
    --socket:CloseSocket()
    --zmq:CloseContext()
else
    -- ngx.status = 404
    ngx.say("Not Found!")
    ngx.log(ngx.ERR, err)
end
require("mobdebug").done()