local v2 = include("v2.lua")
local p8 = include("p8.lua")
local Sort = include("sort.lua")

include("texteffects.lua")

local End = {
  FRAMES_PER_SECOND = 60,
  SCREEN_WIDTH = 480,
}

local function opp_horse(seconds, num)
  return {
    sprite = 152 + (num - 1) * 2,
    seconds = seconds,
  }
end

local function hormse(seconds)
  return {
    sprite = 158,
    seconds = seconds,
  }
end

function End:new(hormse_seconds, opp_seconds)
  local podium_horses = {
    hormse(hormse_seconds),
    opp_horse(opp_seconds[1], 1),
    opp_horse(opp_seconds[2], 2),
    opp_horse(opp_seconds[3], 3),
  }
  Sort.sort(podium_horses, function(a, b)
    return a.seconds < b.seconds
  end)
  local o = {
    frame = 0,
    podium_horses = podium_horses,
  }
  setmetatable(o, self)
  self.__index = self

  o.time_str = bubbletext(string.format("wow! hormse took %0.2f seconds!", hormse_seconds), "\^w\^t", 10, {x=nil, y=50})

  o:init()
  return o
end

function End:init()
  fetch("/system/fonts/lil_mono.font"):poke(0x4000)
end

function End:update()
  self.frame += 1
  self.time_str:update()
  if peektext() then
    readtext()
    return true
  end
  return false
end

function End:draw()
  camera(0,0)
  cls()
  map(0,0,0,0)
  local podium_x = (End.SCREEN_WIDTH - 6 * 16) / 2
  local podium_y = 110
  p8.p8spr(128, 6, 3, podium_x, podium_y)
  p8.p8spr(self.podium_horses[1].sprite, 2, 2, podium_x + 2 * 16, podium_y - 25)
  p8.p8spr(self.podium_horses[2].sprite, 2, 2, podium_x         , podium_y - 15)
  p8.p8spr(self.podium_horses[3].sprite, 2, 2, podium_x + 4 * 16, podium_y - 4)
  -- Extra 1st podium section to cover 3rd.
  p8.p8spr(134, 1, 3, podium_x + 16 * 4, podium_y)

  self.time_str:draw()
end

return End
