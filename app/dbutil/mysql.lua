local mysql = import "resty.mysql"

local MySQL = {}


function MySQL:get_mysql()
    if ngx.ctx[MySQL] then
        return ngx.ctx[MySQL]
    end

    local conn, err = mysql:new()
    if not conn then
        ngx.log(ngx.ERR, "mysql.scoketFailed", err)
    end

    conn:set_timeout(3000)

    local result, err, errno, state = conn:connect({
        host = "192.168.50.202",
        port = 3306,
        user = "test",
        password = "123456",
        database = "test"
    })
    if not result then
        ngx.log(ngx.ERR, "mysql.cantConnect", err, errno, state)
    end

    ngx.ctx[MySQL] = client
    return ngx.ctx[MySQL]
end

function MySQL:query(query)
    local result, err, errno, state = self:get_mysql():query(query)
    if not result then
        ngx.log(ngx.ERR, "mysql.queryFailed", query, err, errno, state)
    end
    return result
end

function MySQL:close()
    if ngx.ctx[MySQL] then
        ngx.ctx[MySQL]:set_keeplive(0, 100)
        ngx.ctx[MySQL] = nil
    end
end

return MySQL