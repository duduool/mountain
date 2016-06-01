local mysql = import "resty.mysql"

local MySQL = {}

function error(...)
    ngx.log(ngx.INFO, ...)
end

function MySQL:getClient()
    if ngx.ctx[MySQL] then
        return ngx.ctx[MySQL]
    end

    local client, err = mysql:new()
    if not client then
        error("mysql.scoketFailed", err)
    end

    client:set_timeout(3000)

    local result, err, errno, state = client:connect({
        host = "192.168.50.202",
        port = 3306,
        user = "test",
        password = "123456",
        database = "test"
    })
    if not result then
        error("mysql.cantConnect", err, errno, state)
    end

    ngx.ctx[MySQL] = client
    return ngx.ctx[MySQL]
end


function MySQL:close()
   if ngx.ctx[MySQL] then
       ngx.ctx[MySQL]:set_keeplive(0, 100)
       ngx.ctx[MySQL] = nil
   end
end

function MySQL:query(query)
    local result, err, errno, state = self:getClient():query(query)
    if not result then
        error("mysql.queryFailed", query, err, errno, state)
    end
    return result
end

return MySQL