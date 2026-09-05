local v2 = include("v2.lua")

local Transition = {
  TILE_SIZE = 32,
  FRAMES_PER_SECOND = 60,
  SCREEN_WIDTH = 480,
  SCREEN_HEIGHT = 270,
  ENTER_TRANSITION = 1,
  EXIT_TRANSITION = 2,
}

function Transition:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o:init()
  return o
end

function Transition:init()
  self.frame = 0
  self.t = 0
  self.shift = 0
  self.shifted_tiles = 0
  self.state = Transition.ENTER_TRANSITION
end

function Transition:update()
  self.frame += 1
  self.t = self.frame / Transition.FRAMES_PER_SECOND
  self.shift = flr(self.t * Transition.TILE_SIZE) % Transition.TILE_SIZE
  self.shifted_tiles = flr(flr(self.t * Transition.TILE_SIZE) / Transition.TILE_SIZE)
  if self.state == Transition.ENTER_TRANSITION and self.shifted_tiles >= 1 then
    self.frame = 0
    self.t = 0
    self.shift = 0
    self.shifted_tiles = 0
    self.state = Transition.EXIT_TRANSITION
  end
  return self.state == Transition.EXIT_TRANSITION
end

function Transition:tile_width(tx, ty)
  local tt = 8 * self.t + tx / 8 + ty / 4 - 4
  if self.state == Transition.ENTER_TRANSITION then
    local width = min(Transition.TILE_SIZE/2, 8 * tt)
    return width
  elseif self.state == Transition.EXIT_TRANSITION then
    local width = min(Transition.TILE_SIZE/2, Transition.TILE_SIZE/2 - 8 * tt)
    return width
  end
end

function Transition:draw()
  for y=0,2+Transition.SCREEN_HEIGHT/Transition.TILE_SIZE do
    local ty = flr(y) + self.shifted_tiles
    for x=0,2+Transition.SCREEN_WIDTH/Transition.TILE_SIZE do
      local tx = flr(x) + self.shifted_tiles
      local width = self:tile_width(tx, ty)
      if width > 0 then
        local color = 7
        if (tx + ty) % 2 == 0 then
          color = 3
        end
        rectfill(
          Transition.TILE_SIZE*x + Transition.TILE_SIZE/2 - width - self.shift,
          Transition.TILE_SIZE*y + Transition.TILE_SIZE/2 - width - self.shift,
          Transition.TILE_SIZE*x + Transition.TILE_SIZE/2 + width - self.shift,
          Transition.TILE_SIZE*y + Transition.TILE_SIZE/2 + width - self.shift,color)
      end
    end
  end
end

return Transition
