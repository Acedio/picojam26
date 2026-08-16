local v2 = include("v2.lua")
local Spring = include("spring.lua")

local Horse = {}

Horse.BODY_RECT = v2.v2(40,20)
Horse.LEG_HEIGHT = 10
Horse.COLOR = 1
Horse.HOOF_COLOR = 2
Horse.HOOF_SIZE = 8
-- TODO: This should be based on body size.
Horse.SPLITS_MULTIPLIER = 0.25

function Horse:new(o)
  local o = o or {pos = v2.v2(0,0)}
  setmetatable(o, self)
  self.__index = self

  o.backhoof_pos = o.pos + v2.v2(0, Horse.BODY_RECT.y + Horse.LEG_HEIGHT)
  o.fronthoof_pos = o.pos + Horse.BODY_RECT + v2.v2(0, Horse.LEG_HEIGHT)
  o.body_spring = Spring:new{
    pos = o.pos,
    vel = v2.v2(0,0),
    damp = 0.8,
    strength = 0.1,
    target = o.pos,
  }

  return o
end

function Horse:draw()
  local body_pos = self.body_spring:get_pos()
  oval(body_pos.x, body_pos.y, body_pos.x + Horse.BODY_RECT.x, body_pos.y + Horse.BODY_RECT.y, Horse.COLOR)
  rect(self.backhoof_pos.x, self.backhoof_pos.y, self.backhoof_pos.x + Horse.HOOF_SIZE, self.backhoof_pos.y + Horse.HOOF_SIZE, Horse.HOOF_COLOR)
  rect(self.fronthoof_pos.x, self.fronthoof_pos.y, self.fronthoof_pos.x + Horse.HOOF_SIZE, self.fronthoof_pos.y + Horse.HOOF_SIZE, Horse.HOOF_COLOR)
end

function Horse:update()
  self.pos.x = (self.fronthoof_pos.x + self.backhoof_pos.x) / 2 - self.BODY_RECT.x / 2
  local target = self.pos:copy()
  target.y = self.pos.y + (self.fronthoof_pos.x - self.backhoof_pos.x) * Horse.SPLITS_MULTIPLIER
  self.body_spring:set_target(target)
  self.body_spring:update()
end

function Horse:set_back_hoof(new_x)
  self.backhoof_pos.x = new_x
end

function Horse:set_front_hoof(new_x)
  self.fronthoof_pos.x = new_x
end

return Horse
