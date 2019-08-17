local skynet       = require "skynet"
local socket       = require "skynet.socket"
local sockethelper = require "http.sockethelper"
local httpd        = require "http.httpd"


local SSLCTX_SERVER = nil
local function gen_interface(protocol, fd)
    if protocol == "http" then
        return {
            init = nil,
            close = nil,
            read = sockethelper.readfunc(fd),
            write = sockethelper.writefunc(fd),
        }
    elseif protocol == "https" then
        local tls = require "http.tlshelper"
        if not SSLCTX_SERVER then
            SSLCTX_SERVER = tls.newctx()
            local certfile = skynet.getenv("certfile") or "./server-cert.pem"
            local keyfile  = skynet.getenv("keyfile") or "./server-key.pem"
            SSLCTX_SERVER:set_cert(certfile, keyfile)
        end
        local tls_ctx = tls.newtls("server", SSLCTX_SERVER)
        return {
            init = tls.init_responsefunc(fd, tls_ctx),
            close = tls.closefunc(tls_ctx),
            read = tls.readfunc(fd, tls_ctx),
            write = tls.writefunc(fd, tls_ctx),
        }
    else
        error(string.format("Invalid protocol: %s", protocol))
    end
end

local function do_response(fd, write, statuscode, bodyfunc, header)
    local ok, retval = httpd.write_response(write, statuscode, bodyfunc, header)
    if not ok then
        skynet.error(string.format("httpd.response(%d) : %s", fd, retval))
    end
end

local function do_request(fd, addr, protocol, handle)
    socket.start(fd)
    local interface = gen_interface(protocol, fd)
    if interface.init then
        interface.init()
    end
    local code, url, method, header, body = httpd.read_request(interface.read, 8192)
    if code then
        if code ~= 200 then
            do_response(fd, interface.write, code)
        else
            if header.upgrade == "websocket" and method:lower() ~= "get" then
                do_response(fd, interface.write, 400, "need GET method")
            else
                local ip = addr:match("([^:]+)")
                -- local ip, port = string.match(addr, "(.+):(%d+)")
                local req = {
                    fd       = fd,
                    protocol = protocol,
                    method   = method,
                    url      = url,
                    header   = header,
                    body     = body,
                    ip       = ip,
                }
                local res = {
                    interface = interface,
                    response = function(code, bodyfunc, header)
                        do_response(fd, interface.write, code, bodyfunc, header)
                    end
                }
                local ret = handle(header.upgrade == "websocket", req, res)
                if ret then
                    return
                end
            end
        end
    else
        if url == sockethelper.socket_error then
            skynet.error("httpd : socket closed!!!", url)
        else
            skynet.error("httpd : request failed!!!", url)
        end
    end
    socket.close(fd)
    if interface.close then
        interface.close()
    end
end

return do_request