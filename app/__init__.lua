--PUT THIS FILE INTO /usr/local/openresty/luainit/init.lua or OTHER PATH, BUT
--REMEMBER TO MODIFIY THE CONF FILE `init_by_lua_file` WHERE YOU JUST PUT IT,
--THUS YOU CAN USE `import "xxx"` WHEREVER IT IS in SYSTEM PATH or USER PATH
--ESPECIALLY IN USER `lib` DIRECTORY YOU CAN IGNORE ADD IT AS A PREFIX
--eg: import "lib.resty.xxx" NEVER USE AS THIS
--    import "resty.xxx"     RIGHT WAY
--IF THE FILE IS NOT IN `lib` DIRECTORY, YOU SHOULD ADD THE DIR AS PREFIX
--eg: import "router.router" RIGHT WAY
_G.NULL = ngx.null

local __loadedMods = {}

_G.import = function(namespace)
    local module = __loadedMods[namespace]

    if module then
        return module
    end
    
    local pNamespace = ngx.var.SERVER_DIR .. "." .. namespace
    local pModule = __loadedMods[pNamespace]

    if pModule then
        return pModule
    end
   
    local libNamespace = ngx.var.SERVER_DIR .. ".lib." .. namespace
    local libModule = __loadedMods[libNamespace]

    if libModule then
        return libModule
    end
 
    local ok, module = pcall(require, libNamespace)
    if ok then
        __loadedMods[libNamespace] = module
        return module
    end

    local ok, module = pcall(require, pNamespace)
    if ok then
        __loadedMods[pNamespace] = module
        return module
    end

    local ok, module = pcall(require, namespace)
    if ok then
        __loadedMods[namespace] = module
        return module
    end

    error(module, 2)
end