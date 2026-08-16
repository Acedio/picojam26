local v2 = include("v2.lua")
local Spring = include("spring.lua")

local Horse = {}

Horse.BODY_RECT = v2.v2(90,32)
Horse.LEG_HEIGHT = 0
Horse.COLOR = 4
Horse.SHADOW_COLOR = 20
Horse.HOOF_COLOR = 2
Horse.HOOF_SIZE = 8
Horse.HEAD_OFFSET = v2.v2(45,-38)
Horse.TAIL_OFFSET = v2.v2(-40,0)
-- TODO: This should be based on body size.
Horse.SPLITS_MULTIPLIER = 0.25

function Horse:new(o)
  local o = o or {pos = v2.v2(0,0)}
  setmetatable(o, self)
  self.__index = self

  o.backhoof_pos = o.pos + v2.v2(0, Horse.BODY_RECT.y + Horse.LEG_HEIGHT)
  o.backhoof_spring = Spring:new{
    pos = o.backhoof_pos,
    vel = v2.v2(0,0),
    damp = 0.8,
    strength = 0.1,
    target = o.backhoof_pos,
  }
  o.fronthoof_pos = o.pos + Horse.BODY_RECT + v2.v2(0, Horse.LEG_HEIGHT)
  o.fronthoof_spring = Spring:new{
    pos = o.fronthoof_pos,
    vel = v2.v2(0,0),
    damp = 0.8,
    strength = 0.1,
    target = o.fronthoof_pos,
  }

  o.body_spring = Spring:new{
    pos = o.pos,
    vel = v2.v2(0,0),
    damp = 0.9,
    strength = 0.1,
    target = o.pos,
  }
  o.body_spring:update()
  local head_pos = o.body_spring:get_pos() + Horse.HEAD_OFFSET
  o.head_spring = Spring:new{
    pos = head_pos,
    vel = v2.v2(0,0),
    damp = 0.8,
    strength = 0.1,
    target = head_pos,
  }
  local tail_pos = o.body_spring:get_pos() + Horse.TAIL_OFFSET
  o.tail_spring = Spring:new{
    pos = tail_pos,
    vel = v2.v2(0,0),
    damp = 0.8,
    strength = 0.2,
    target = tail_pos,
  }

  return o
end

function p8spr(s, w, h, dx, dy)
  for xi=0,w-1 do
    for yi=0,h-1 do
      sspr(s + yi * 8 + xi, 0, 0, 16, 16, dx + xi * 16, dy + yi * 16)
    end
  end
end

function Horse:draw()
  p8spr(0x1a, 3, 2, self.backhoof_spring:get_pos().x - 2, self.backhoof_spring:get_pos().y)
  p8spr(69, 3, 4, self.tail_spring:get_pos().x, self.tail_spring:get_pos().y)
  local body_pos = self.body_spring:get_pos()
  ovalfill(body_pos.x - 2, body_pos.y, body_pos.x + Horse.BODY_RECT.x, body_pos.y + Horse.BODY_RECT.y + 2, Horse.SHADOW_COLOR)
  ovalfill(body_pos.x, body_pos.y, body_pos.x + Horse.BODY_RECT.x, body_pos.y + Horse.BODY_RECT.y, Horse.COLOR)
  p8spr(64, 5, 4, self.head_spring:get_pos().x, self.head_spring:get_pos().y)
  p8spr(0x30, 3, 2, self.fronthoof_spring:get_pos().x + 2, self.fronthoof_spring:get_pos().y)
end

function Horse:update()
  self.pos.x = (self.fronthoof_pos.x + self.backhoof_pos.x) / 2 - self.BODY_RECT.x / 2
  local target = self.pos:copy()
  target.y = self.pos.y + (self.fronthoof_pos.x - self.backhoof_pos.x) * Horse.SPLITS_MULTIPLIER
  self.body_spring:set_target(target)
  self.body_spring:update()
  self.head_spring:set_target(self.body_spring:get_pos() + Horse.HEAD_OFFSET)
  self.head_spring:update()
  self.tail_spring:set_target(self.body_spring:get_pos() + Horse.TAIL_OFFSET)
  self.tail_spring:update()

  self.fronthoof_spring:set_target(self.fronthoof_pos)
  self.fronthoof_spring:update()
  self.backhoof_spring:set_target(self.backhoof_pos)
  self.backhoof_spring:update()
end

function Horse:set_back_hoof(new_x)
  self.backhoof_pos.x = new_x
  self.backhoof_spring:perturb(v2.v2(0, -5))
end

function Horse:set_front_hoof(new_x)
  self.fronthoof_pos.x = new_x
  self.fronthoof_spring:perturb(v2.v2(0, -5))
end

return Horse
