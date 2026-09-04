local v2 = include("v2.lua")
local p8 = include("p8.lua")
local Sort = include("sort.lua")
local Horse = include("horse.lua")

include("texteffects.lua")

local End = {
  FRAMES_PER_SECOND = 60,
  SCREEN_WIDTH = 480,
  HORMSE_START_X = 480 + 70,
  HORMSE_MIN_X = -170,
  MIN_FRAMES_BEFORE_SKIP = 60,
}

local function opp_horse(seconds, num)
  return {
    sprite = 152 + (num - 1) * 2,
    seconds = seconds,
    is_hormse = false,  -- impostors!
  }
end

local function hormse(seconds)
  return {
    sprite = 158,
    seconds = seconds,
    is_hormse = true,  -- so true
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
    hormse_x = End.HORMSE_START_X,
  }
  o.hormse = Horse:new{pos = v2.v2(o.hormse_x, 140)}
  o.hormse_boast = bubbletext("for to winnnn!", "", 5)

  setmetatable(o, self)
  self.__index = self

  o.time_str = bubbletext(string.format("wow! hormse ran %0.2fs fast!", hormse_seconds), "\^w\^t", 10)
  o.any_key_str = bubbletext("press any key...", "", 5)

  o:init()
  return o
end

function End:can_skip()
  return self.frame >= End.MIN_FRAMES_BEFORE_SKIP 
end

function End:init()
  fetch("/system/fonts/lil_mono.font"):poke(0x4000)
end

function End:update()
  self.frame += 1
  self.time_str:update()

  self.hormse_x -= 0.5
  if self.hormse_x < End.HORMSE_MIN_X then
    self.hormse_x = End.HORMSE_START_X
    self.hormse = Horse:new{pos = v2.v2(self.hormse_x, 140)}
  end
  if self.hormse_x + 50 < (flr(self.hormse.fronthoof_pos.x / 11) * 11) then
    self.hormse:set_front_hoof(self.hormse_x + 50)
    self.hormse:bump_front_hoof(3)
  end
  if self.hormse_x < (flr(self.hormse.backhoof_pos.x / 13) * 13) then
    self.hormse:set_back_hoof(self.hormse_x)
    self.hormse:bump_back_hoof(3)
  end
  self.hormse:update()
  self.hormse_boast:update()

  if self:can_skip() then
    self.any_key_str:update()
    if peektext() then
      readtext()
      return true
    end
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
  local podium_positions = {
    v2.v2(podium_x + 2 * 16, podium_y - 25),
    v2.v2(podium_x         , podium_y - 17),
    v2.v2(podium_x + 4 * 16, podium_y - 2),
  }
  local hormse_won = self.podium_horses[1].is_hormse
  for i=1,3 do
    if not hormse_won or not self.podium_horses[i].is_hormse then
      -- hormse does a victory lap if they win
      local pos = podium_positions[i]
      p8.p8spr(self.podium_horses[i].sprite, 2, 2, pos.x, pos.y)
    end
  end
  if self.podium_horses[4].is_hormse then
    -- hormse encourage!
    local hormse_pos = v2.v2(podium_x + 5 * 16, podium_y + 2 * 16)
    p8.p8spr(self.podium_horses[4].sprite, 2, 2, hormse_pos.x, hormse_pos.y)
    printbg("wow horse is fast!", hormse_pos.x + 20, hormse_pos.y - 10, 7, 0)
  end
  -- Extra 1st podium section to cover 3rd.
  p8.p8spr(134, 1, 3, podium_x + 16 * 4, podium_y)

  if hormse_won then
    self.hormse:draw()
    self.hormse_boast:draw(v2.v2(self.hormse_x + 100, 130))
  end

  self.time_str:draw(v2.v2(nil, 50))

  if self:can_skip() then
    self.any_key_str:draw(v2.v2(380, 250))
  end
end

return End
