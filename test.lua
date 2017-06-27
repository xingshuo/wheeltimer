package.cpath = package.cpath .. ";./build/?.so"
local twheel = require "twheel"
local timer = require "src/timer"

local floor = math.floor 
local sfmt = string.format 

function sleep(n) --n个10ms
    local ti = n/100
    os.execute(sfmt("sleep %s",ti))
end

local time_mgr = timer:new(1)
print(sfmt("execute start!! %sM time:%s",collectgarbage("count"),time_mgr:get_realtime()))

time_mgr:timeout(100, function ( ... )
    print("i am 3333333",time_mgr:get_realtime())
end)

time_mgr:timeout(50, function ( ... )
    print("i am 1111111",time_mgr:get_realtime())
end)

local handle
local cnt = 0
handle = time_mgr:loop(70, function ( ... )
    print("i am 2222222",time_mgr:get_realtime())
    cnt = cnt + 1
    if cnt > 3 then
        print("remove timer 2222222")
        time_mgr:remove_timer(handle)
        time_mgr:timeout(300, function ( ... )
            print("stop wheel timer",time_mgr:get_realtime())
            time_mgr:stop()
        end)
    end
end, -10)

time_mgr:start()

local cnt = 0
time_mgr:loop(900, function ( ... )
    print("i am 66666666",time_mgr:get_realtime())
    cnt = cnt + 1
    if cnt > 3 then
        print("stop wheel timer")
        time_mgr:stop()
    end
end)

time_mgr:timeout(500, function ( ... )
    print("i am 44444444",time_mgr:get_realtime())
end)

time_mgr:timeout(800, function ( ... )
    print("i am 55555555",time_mgr:get_realtime())
    print("snowslide test")
    sleep(1000)
end)

time_mgr:timeout(1400, function ( ... )
    print("i am 7777777",time_mgr:get_realtime())
end)

time_mgr:timeout(1500, function ( ... )
    print("i am 8888888",time_mgr:get_realtime())
end)


time_mgr:timeout(1900, function ( ... )
    print("i am 99999999",time_mgr:get_realtime())
end)

print("restart wheel timer!!")
time_mgr:start()
local endtime = time_mgr:get_realtime()
time_mgr = nil
collectgarbage("collect")
print(sfmt("execute end!! %sM time:%s",collectgarbage("count"),endtime))