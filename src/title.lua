local v2 = include("v2.lua")

local Title = {}

function Title:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
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
  if peektext() then
    readtext()
    return true
  end
  return false
end

function Title:draw()
  map(0,0)
end

return Title
