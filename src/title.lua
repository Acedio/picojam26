local v2 = include("v2.lua")
local Horse = include("horse.lua")

include("texteffects.lua")

local Title = {
  HORMSE_START_X = -130,
  KEEP_TITLING = 0,
  VIEW_SCORES = 1,
  START_RACE = 2,
}

function Title:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.title = bubbletext("derpy derby", "\^w\^t", 10)
  o.anykey = bubbletext("press any key!", "", 8)
  o.fast_hormses = bubbletext("(or H for fast hormses)", "", 6)
  o.credits = bubbletext("by illuminesce, zep, acedio 2026", "", 5)
  -- Start hormse off a little ahead so they're on screen when the title fades
  -- in. We also adjust their initial pos back a bit so the hormse_x immediately
  -- starts getting them shuffling.
  o.hormse_x = Title.HORMSE_START_X + 70
  o.hormse = Horse:new{pos = v2.v2(o.hormse_x-20, 140)}
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
  self.fast_hormses:update()
  self.credits:update()
  self.hormse_x += 0.5
  if self.hormse_x > 620 then
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
    local text = readtext()
    if string.find(text, "h") then
      return Title.VIEW_SCORES
    else
      return Title.START_RACE
    end
  end
  return Title.KEEP_TITLING
end

function Title:draw()
  cls()
  map(0,0)
  self.hormse:draw()
  self.title:draw(v2.v2(nil, 50))
  self.anykey:draw(v2.v2(nil, 163))
  self.fast_hormses:draw(v2.v2(nil, 178))
  self.credits:draw(v2.v2(314, 250))
end

return Title
