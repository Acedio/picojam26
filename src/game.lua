local Race = include("race.lua")
local Title = include("title.lua")
local End = include("end.lua")

local States = {
  TITLE = 1,
  RACE = 2,
  END = 3,
}
local state = States.TITLE

function _init()
  fetch("mfh.sfx"):poke(0x30000)
  music()
  current = Title:new()
end

function _update()
  local ret = current:update()
  if state == States.TITLE and ret then
    state = States.RACE
    current = Race:new()
  elseif state == States.RACE and ret ~= nil then
    state = States.END
    current = End:new(ret.hormse_seconds, ret.opp_seconds)
  elseif state == States.END and ret then
    state = States.TITLE
    current = Title:new()
  end
end

function _draw()
  current:draw()
end
