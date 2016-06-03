local ffi = require("ffi")

ffi.cdef[[
typedef struct zmq_msg_t {unsigned char _[32];} zmq_msg_t;
typedef struct {} zmq_ctx;
typedef struct {} zmq_sck;

int zmq_msg_init(zmq_msg_t *msg);
int zmq_msg_recv(zmq_msg_t *msg, void *s, int flags);
int zmq_msg_close(zmq_msg_t *msg);
void *zmq_msg_data(zmq_msg_t *msg);
size_t zmq_msg_size(zmq_msg_t *msg);

zmq_ctx *zmq_ctx_new(void);
int zmq_ctx_term(zmq_ctx *context);
int zmq_ctx_shutdown(zmq_ctx *ctx_);

zmq_sck *zmq_socket(zmq_ctx *, int type);

int zmq_close(void *s);
int zmq_setsockopt(void *s, int option, const void *optval, size_t optvallen);
int zmq_getsockopt(void *s, int option, void *optval, size_t *optvallen);
int zmq_bind(void *s, const char *addr);
int zmq_connect(void *s, const char *addr);
int zmq_unbind(void *s, const char *addr);
int zmq_disconnect(void *s, const char *addr);
int zmq_send(void *s, const void *buf, size_t len, int flags);
int zmq_recv(void *s, void *buf, size_t len, int flags);
int zmq_socket_monitor(void *s, const char *addr, int events);

int zmq_sendmsg(void *s, zmq_msg_t *msg, int flags);
int zmq_recvmsg(void *s, zmq_msg_t *msg, int flags);
]]

ZMQ_PAIR = 0
ZMQ_PUB = 1
ZMQ_SUB = 2
ZMQ_REQ = 3
ZMQ_REP = 4
ZMQ_DEALER = 5
ZMQ_ROUTER = 6
ZMQ_PULL = 7
ZMQ_PUSH = 8
ZMQ_XPUB = 9
ZMQ_XSUB = 10

ZMQ_DONTWAIT = 1
ZMQ_SENDMORE = 2

EAGAIN = 11

ZMQ_LINGER = 17

local libzmq = ffi.load("zmq")
local NULL = ffi.cast("void*", nil)

if (libzmq == nil) then
	error("load libzmq error")
end

local function NewZMQContext()
	local ctx = libzmq.zmq_ctx_new()
	return ctx
end

local function CloseContext(ctx)
	libzmq.zmq_ctx_shutdown(ctx)
	libzmq.zmq_ctx_term(ctx)
end

local function NewSocket(ctx, zmqtype)
	local socket = libzmq.zmq_socket(ctx, zmqtype)
	if (socket == NULL) then
		return nil
	end

	local param = ffi.new("int[1]");
	param[0] = 0;
	-- 设置ZMQ_LINGER为0否则当未连接上是zmq_ctx_term会挂起 
	libzmq.zmq_setsockopt(socket, ZMQ_LINGER, param, ffi.sizeof("int"))
	return socket
end

local function CloseSocket(socket)
	libzmq.zmq_close(socket)
end

local function Bind(socket, addr)
	return libzmq.zmq_bind(socket, addr)
end

local function Connect(socket, addr)
	return libzmq.zmq_connect(socket, addr)
end

local function Send(socket, buf)
	return libzmq.zmq_send(socket, buf, string.len(buf), ZMQ_DONTWAIT)
end

local function Recv(socket)
	local msg = ffi.new("zmq_msg_t")
	if (msg == NULL) then
		return -1
	end
	local buf
	libzmq.zmq_msg_init(msg)

	local n = libzmq.zmq_recvmsg(socket, msg, 0)
	if (n > 0) then
		buf = ffi.string(libzmq.zmq_msg_data(msg), libzmq.zmq_msg_size(msg))
	end
	libzmq.zmq_msg_close(msg)
	msg = nil
	return buf
end

local m = {
	NewZMQContext = NewZMQContext
}

local meta_ctx = {
	NewSocket = NewSocket,
	CloseContext = CloseContext
}

local meta_sck = {
	Send = Send,
	Recv = Recv,
	Connect = Connect,
	Bind = Bind,
	CloseSocket = CloseSocket
}

ffi.metatype('zmq_ctx', {__index = meta_ctx})
ffi.metatype('zmq_sck', {__index = meta_sck})

return m
