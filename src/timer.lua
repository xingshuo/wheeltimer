package.cpath = package.cpath .. ";./build/?.so"

local ltimer = require "ltimer"

local TimerMgr = {}
TimerMgr.__index = TimerMgr

function TimerMgr:new()
    local o = {}
    setmetatable(o, self)
    o:init()
    return o
end

function TimerMgr:init()
    self.timestamp = 0 --precision: 10ms
    self.timers = {}
    self.handle = 0
    self.cobj = ltimer.create()
    self.running = false
end

function TimerMgr:__gc()
    ltimer.release(self.cobj)
end

function TimerMgr:add_timer(ti, func, count)
    count = count or 0
    local last_hdl = self.handle
    while self.timers[self.handle] do
        self.handle = (self.handle + 1) & 0xffffffff -- c need 32bit
        assert(self.handle ~= last_hdl)
    end
    handle = self.handle
    ltimer.add(self.cobj, handle, ti)
    self.timers[handle] = {
        count = count,
        func = func,
        interval = ti,
    }
    return handle
end

function TimerMgr:loop(ti, func)
    return self:add_timer(ti, func, 0)
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

function TimerMgr:start(curtime)
    self.running = true
    if curtime then
        self.timestamp = curtime
    end
end

function TimerMgr:stop()
    self.running = false
end

local tmp = {}
function TimerMgr:update(elapse)
    if not self.running then
        return
    end
    assert(elapse >= 0)
    local tick = elapse
    while tick > 0 do
        local n, e = ltimer.update(self.cobj, tick, tmp)
        tick = tick - e
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
                end
            end
            ::continue::
        end
    end
    self.timestamp = self.timestamp + elapse
end

return TimerMgr