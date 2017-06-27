package.cpath = package.cpath .. ";./build/?.so"

local ltimer = require "ltimer"
local twheel = require "twheel"

local floor = math.floor 
local sfmt = string.format 

local function sleep(n) --n: 1 = 10ms
    local ti = n/100
    os.execute(sfmt("sleep %s",ti))
end

local TimerMgr = {}
TimerMgr.__index = TimerMgr

function TimerMgr:new(check_interval)
    local o = {}
    setmetatable(o, self)
    o:init(check_interval)
    return o
end

function TimerMgr:init(check_interval)
    self.timers = {}
    self.handle = 0
    self.check_interval = check_interval or 1 --1 = 10ms
    self.timestamp = self:get_realtime()
    self.cobj = ltimer.create()
end

function TimerMgr:__gc()
    ltimer.release(self.cobj)
end

-- ti: 1 = 10ms
function TimerMgr:add_timer(ti, func, count, delay)
    count = count or 0
    delay = delay or 0 --positive or negative
    local last_hdl = self.handle
    repeat
        self.handle = (self.handle + 1) & 0xffffffff -- c need 32bit
        assert(self.handle ~= last_hdl)
    until self.timers[handle] == nil
    local handle = self.handle
    local t = self:get_realtime() - self.timestamp + ti + delay
    ltimer.add(self.cobj, handle, t)
    self.timers[handle] = {
        count = count,
        func = func,
        interval = ti,
    }
    return handle
end

function TimerMgr:loop(ti, func, delay)
    return self:add_timer(ti, func, 0, delay)
end

function TimerMgr:timeout(ti, func)
    return self:add_timer(ti, func, 1)
end

function TimerMgr:get_timer(handle)
    return self.timers[handle]
end

function TimerMgr:remove_timer(handle)
    self.timers[handle] = nil
end

function TimerMgr:start()
    self.running = true
    while true do
        if not self.running then
            break
        end
        local elapse = self:get_realtime() - self.timestamp
        self:update(elapse)
        sleep(self.check_interval)
    end
end

function TimerMgr:stop()
    self.running = false
end

function TimerMgr:get_realtime() --1 = 10ms
    return floor(twheel.gettime()*100)
end

local tmp = {}
function TimerMgr:update(elapse)
    assert(elapse >= 0)
    local tick = elapse
    while tick > 0 do
        local n, e = ltimer.update(self.cobj, tick, tmp)
        tick = tick - e
        self.timestamp = self.timestamp + e
        for i=1,n do
            local handle = tmp[i]
            local t = self.timers[handle]
            if not t then
                goto continue
            end
            if t.count == 0 then --loop
                t.func()
                ltimer.add(self.cobj, handle, t.interval)
            else
                t.count = t.count - 1
                t.func()
                if t.count <= 0 then
                    self.timers[handle] = nil
                else
                    ltimer.add(self.cobj, handle, t.interval)
                end
            end
            ::continue::
        end
    end
end

return TimerMgr