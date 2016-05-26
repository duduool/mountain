local fname = "/tmp/pwd.out" assert(os.execute("pwd > " .. fname) == 0)
local f = io.open(fname, "r") assert(f)
local content = f:read("*a")
ngx.say("pwd: ", content)
f:close()

local router = import "router.router"
local r = router.new()

r:match({
    GET = {
        ["/hello"]       = function(params) ngx.print("someone said hello") end,
        ["/hello/:name"] = function(params) ngx.print("hello, " .. params.name) end
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
    ngx.var.request_uri,
    ngx.req.get_uri_args(),
    ngx.req.get_post_args(),
    {other_arg = 1}
)

if ok then
    -- ngx.status = 200 -- 这个地方改状态貌似木有用
else
    -- ngx.status = 404
    ngx.say("Not Found!")
    ngx.log(ngx.ERR, err)
end