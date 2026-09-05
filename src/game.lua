local Race = include("race.lua")
local Title = include("title.lua")
local End = include("end.lua")
local Transition = include("transition.lua")

local States = {
  TRANSITION_FROM_BLACK = 0,
  TITLE = 1,
  TRANSITION_TO_RACE = 2,
  RACE = 3,
  TRANSITION_TO_END = 4,
  END = 5,
  TRANSITION_TO_TITLE = 6,
}
local state = States.TRANSITION_FROM_BLACK

function _init()
  fetch("mfh.sfx"):poke(0x30000)
  -- Just a blank screen initially.
  current = {
    update = function(self)
      return true
    end,
    draw = function(self)
      cls()
    end,
  }
  transition = Transition:new()
end

function _update()
  local transition_covering = transition:update()
  local ret = current:update()
  if state == States.TRANSITION_FROM_BLACK and transition_covering then
    state = States.TITLE
    music()
    current = Title:new()
  elseif state == States.TITLE and ret then
    state = States.TRANSITION_TO_RACE
    transition = Transition:new()
  elseif state == States.TRANSITION_TO_RACE and transition_covering then
    state = States.RACE
    current = Race:new()
  elseif state == States.RACE and ret ~= nil then
    state = States.TRANSITION_TO_END
    transition = Transition:new()
  elseif state == States.TRANSITION_TO_END and transition_covering then
    state = States.END
    current = End:new(ret.hormse_seconds, ret.opp_seconds)
  elseif state == States.END and ret then
    state = States.TRANSITION_TO_TITLE
    transition = Transition:new()
  elseif state == States.TRANSITION_TO_TITLE and transition_covering then
    state = States.TITLE
    current = Title:new()
  end
end

function _draw()
  current:draw()
  transition:draw()
  --print(string.format("fps: %d", stat(7)), 0, 0, 7)
  --print(string.format("cpu: %f", stat(1)), 0, 8, 7)
end
