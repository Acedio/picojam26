local v2 = include("v2.lua")

include("texteffects.lua")

local Title = {}

function Title:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.title = bubbletext("derpy derby", "\^w\^t", {x=nil, y=50})
  o.anykey = bubbletext("press any key!", "", {x=nil, y=170})
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
  if peektext() then
    readtext()
    return true
  end
  return false
end

function Title:draw()
  cls()
  map(0,0)
  self.title:draw()
  self.anykey:draw()
end

return Title
