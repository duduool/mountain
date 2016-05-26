require("mobdebug").start('192.168.50.65')
local package = package
local md5 = import "md5"

ngx.say(md5.sumhexa("hi"))

local function tcp()
    local sock = ngx.socket.tcp()
    local ok, err = sock:connect("120.24.63.99", 80)
    if not ok then
        ngx.say("Failed to connect to baidu: ", err)
        return
    end

    local req_data = "GET / HTTP/1.1\r\nHost: www.baidu.com\r\n\r\n"
    local bytes, err = sock:send(req_data)
    if err then
        ngx.say("Failed to send to baidu: ", err)
        return
    end

    local data, err, partial = sock:receive()
    if err then
        ngx.say("Failed to receive to baidu: ", err)
        return
    end

    sock:close()
    ngx.say("Successfully talk to baidu! response first line: ", data)
end

local function ws()
    local server = require("resty.websocket.server")
    local ws, err = server:new{
        timeout = 5000,
        max_payload_len = 65535
    }

    if not ws then
        ngx.log(ngx.ERR, "failed to new websocket: ", err)
        return ngx.exit(444)
    end
    while true do
        local data, typ, err = ws:recv_frame()
        if ws.fatal then
            ngx.log(ngx.ERR, "failed to receive frame: ", err)
            return ngx.exit(444)
        end
        if not data then
            local bytes, err = ws:send_ping()
        elseif typ == "close" then break
        elseif typ == "ping" then
            local bytes, err = ws:send_pong()
        elseif typ == "pong" then
            ngx.log(ngx.INFO, "client ponged")
        elseif typ == "text" then
            local bytes, err = ws:send_text("resp: "..data)
        end
    end
    ws:send_close()
end
require("mobdebug").start('192.168.50.65')
ws()
--tcp()
require("mobdebug").done()