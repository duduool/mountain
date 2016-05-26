--
-- Created by IntelliJ IDEA.
-- User: qiaox
-- Date: 2016/5/26 0026
-- Time: 9:43
-- To change this template use File | Settings | File Templates.
--

local mysql = import "resty.mysql"

local MySQL = {}

function MySQL:getClient()
    if ngx.ctx[MySQL] then
        return ngx.ctx[MySQL]
    end
    
end