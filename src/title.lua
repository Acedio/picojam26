local v2 = include("v2.lua")
local Horse = include("horse.lua")

include("texteffects.lua")

local Title = {
  HORMSE_START_X = -130,
}

function Title:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.title = bubbletext("derpy derby", "\^w\^t", 10)
  o.anykey = bubbletext("press any key!", "", 8)
  o.credits = bubbletext("by illuminesce, zep, acedio 2026", "", 5)
  o.hormse_x = Title.HORMSE_START_X
  o.hormse = Horse:new{pos = v2.v2(o.hormse_x, 140)}
  o:init()
  return o
end

local intro = [[hello, and welcome to the derpy derby!
press any key to start the race.]]

function Title:init()
  -- Clear the input buffer in case any text was waiting.
  readtext(true)
end

function Title:update()
  self.title:update()
  self.anykey:update()
  self.credits:update()
  self.hormse_x += 0.5
  if self.hormse_x > 640 then
    self.hormse_x = Title.HORMSE_START_X
    self.hormse = Horse:new{pos = v2.v2(self.hormse_x, 140)}
  end
  if self.hormse_x + 50 > ((flr(self.hormse.fronthoof_pos.x / 11) + 1) * 11) then
    self.hormse:set_front_hoof(self.hormse_x + 50)
    self.hormse:bump_front_hoof(3)
  end
  if self.hormse_x > ((flr(self.hormse.backhoof_pos.x / 13) + 1) * 13) then
    self.hormse:set_back_hoof(self.hormse_x)
    self.hormse:bump_back_hoof(3)
  end
  self.hormse:update()
  if peektext() then
    readtext()
    return true
  end
  return false
end

function Title:draw()
  cls()
  map(0,0)
  self.hormse:draw()
  self.title:draw(v2.v2(nil, 50))
  self.anykey:draw(v2.v2(nil, 170))
  self.credits:draw(v2.v2(314, 250))
end

return Title
