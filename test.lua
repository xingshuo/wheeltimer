package.cpath = package.cpath .. ";./build/?.so"
local twheel = require "twheel"
local timer = require "src/timer"

local floor = math.floor 
local sfmt = string.format 

function get_time()
    return floor(twheel.gettime()*100)
end

function sleep(n) --n个10ms
    local ti = n/100
    os.execute(sfmt("sleep %s",ti))
end

local time_mgr = timer:new()

local begin_ti = get_time()
time_mgr:start(begin_ti)

time_mgr:timeout(100, function ( ... )
    print("i am 2222222")
end)

time_mgr:timeout(50, function ( ... )
    print("i am 1111111")
end)

local handle = time_mgr:loop(70, function ( ... )
    print("i am 33333333")
end)

print("execute start!!")

while true do
    sleep(50)
    local cur_time = get_time()
    local elapse = cur_time-time_mgr.timestamp
    print(sfmt("cur_time:%s elapse:%s",cur_time,elapse))
    time_mgr:update(elapse)
    if cur_time - begin_ti > 4*100 then
        time_mgr:remove_timer(handle)
        break
    end
end

print("execute middle!!")

time_mgr:loop(900, function ( ... )
    print("i am 4444444")
end)

time_mgr:timeout(500, function ( ... )
    print("i am 5555555")
end)

time_mgr:timeout(800, function ( ... )
    print("i am 6666666")
end)

time_mgr:timeout(1500, function ( ... )
    print("i am 7777777")
end)

begin_ti = get_time()

time_mgr:stop()

while true do
    sleep(200)
    local cur_time = get_time()
    local elapse = cur_time-time_mgr.timestamp
    print(sfmt("cur_time:%s elapse:%s",cur_time,elapse))
    time_mgr:update(elapse)
    if cur_time - begin_ti > 10*100 and not time_mgr.running then
        time_mgr:start()
    end
    if cur_time - begin_ti > 30*100 then
        break
    end
end

print("execute end!!")