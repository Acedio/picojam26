local v2 = include("v2.lua")

local Spring = {}

function Spring:new(o)
  local o = o or {
    pos = v2.v2(0,0),
    vel = v2.v2(0,0),
    damp = 1,
    strength = 0,
    target = v2.v2(0,0),
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function Spring:set_target(target)
  self.target = target
end

function Spring:perturb(v)
  self.vel += v
end

function Spring:update()
  local force = (self.target - self.pos) * self.strength
  self.vel = (self.vel + force) * self.damp
  self.pos = self.pos + self.vel
end

function Spring:get_pos()
  return self.pos
end

return Spring
