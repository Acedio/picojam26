local v2 = include("v2.lua")
local Horse = include("horse.lua")

include("texteffects.lua")

local Title = {}

function Title:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.title = bubbletext("derpy derby", "\^w\^t", {x=nil, y=50})
  o.anykey = bubbletext("press any key!", "", {x=nil, y=170})
  o.hormse = Horse:new{pos = v2.v2(0, 140)}
  o.hormse_x = -80
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
  self.hormse_x += 1
  if self.hormse_x > (flr(self.hormse_x / 20) * 20) then
    self.hormse:set_front_hoof(self.hormse_x)
  end
  if self.hormse_x - 50 > (flr((self.hormse_x - 50) / 20) * 20) then
    self.hormse:set_back_hoof(self.hormse_x - 50)
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
  self.title:draw()
  self.anykey:draw()
end

return Title
