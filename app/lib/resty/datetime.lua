local _M = {}
_M.VERSION = "0.0.1"

--local mt = {__index = _M }
--ngx.tody()
--ngx.time()
--ngx.utctime()
--ngx.localtime()
--ngx.now()
--ngx.http_time()
--ngx.cookie_time()

function _M.new(self)
    local insance = {}

    --setmetatable(instance, mt)
    setmetatable(insance, {
        __index = self,
        __call = self.call
    })
    return insance
end

function _M.call(self)
    return ngx.today()
end

return _M