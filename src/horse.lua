local v2 = include("v2.lua")
local Spring = include("spring.lua")
local p8 = include("p8.lua")

local Horse = {}

Horse.BODY_RECT = v2.v2(90,32)
Horse.BACK_LEG_OFFSET = v2.v2(10,24)
Horse.FRONT_LEG_OFFSET = v2.v2(80,24)
Horse.SHOE_OFFSET = v2.v2(5,6)
Horse.LEG_HEIGHT = 20
Horse.LEG_WIDTH = 7
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

  o.body_spring = Spring:new{
    pos = o.pos,
    vel = v2.v2(0,0),
    damp = 0.9,
    strength = 0.1,
    target = o.pos,
  }
  o.body_spring:update()

  o.backhoof_pos = o.pos + Horse.BACK_LEG_OFFSET + v2.v2(0,Horse.LEG_HEIGHT)
  o.backhoof_spring = Spring:new{
    pos = o.backhoof_pos,
    vel = v2.v2(0,0),
    damp = 0.8,
    strength = 0.1,
    target = o.backhoof_pos,
  }
  o.backknee_spring = Spring:new{
    pos = o:backKneeTarget(),
    vel = v2.v2(0,0),
    damp = 0.7,
    strength = 0.2,
    target = o:backKneeTarget(),
  }
  o.fronthoof_pos = o.pos + Horse.FRONT_LEG_OFFSET + v2.v2(0,Horse.LEG_HEIGHT)
  o.fronthoof_spring = Spring:new{
    pos = o.fronthoof_pos,
    vel = v2.v2(0,0),
    damp = 0.8,
    strength = 0.1,
    target = o.fronthoof_pos,
  }
  o.frontknee_spring = Spring:new{
    pos = o:frontKneeTarget(),
    vel = v2.v2(0,0),
    damp = 0.7,
    strength = 0.2,
    target = o:frontKneeTarget(),
  }
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

function Horse:frontLegJoint()
  return self.body_spring:get_pos() + Horse.FRONT_LEG_OFFSET
end

function Horse:frontHoofJoint()
  return self.fronthoof_spring:get_pos() + v2.v2(4,0) + Horse.SHOE_OFFSET
end

function Horse:frontKneeTarget()
  return (self:frontLegJoint() + self:frontHoofJoint()) / 2 + v2.v2(4,0)
end

function Horse:drawFrontLeg()
  local hip = self:frontLegJoint()
  local knee = self.frontknee_spring:get_pos()
  local hoof = self:frontHoofJoint()
  for i=0,Horse.LEG_WIDTH do
    line(hip.x+i, hip.y, knee.x+i, knee.y, 4)
    line(hip.x+i, hip.y-1, knee.x+i, knee.y-1, 4)
  end
  for i=0,Horse.LEG_WIDTH do
    line(knee.x+i, knee.y, hoof.x+i, hoof.y, 4)
    line(knee.x+i, knee.y-1, hoof.x+i, hoof.y-1, 4)
  end
end

function Horse:backLegJoint()
  return self.body_spring:get_pos() + Horse.BACK_LEG_OFFSET
end

function Horse:backHoofJoint()
  return self.backhoof_spring:get_pos() + v2.v2(-4,0) + Horse.SHOE_OFFSET
end

function Horse:backKneeTarget()
  return (self:backLegJoint() + self:backHoofJoint()) / 2 + v2.v2(-7,0)
end

function Horse:drawBackLeg()
  local hip = self:backLegJoint()
  local knee = self.backknee_spring:get_pos()
  local hoof = self:backHoofJoint()
  for i=0,Horse.LEG_WIDTH do
    line(hip.x+i, hip.y, knee.x+i, knee.y, 4)
    line(hip.x+i, hip.y-1, knee.x+i, knee.y-1, 4)
  end
  for i=0,Horse.LEG_WIDTH do
    line(knee.x+i, knee.y, hoof.x+i, hoof.y, 4)
    line(knee.x+i, knee.y-1, hoof.x+i, hoof.y-1, 4)
  end
end

function Horse:draw()
  p8.p8spr(69, 3, 4, self.tail_spring:get_pos().x, self.tail_spring:get_pos().y)
  local body_pos = self.body_spring:get_pos()
  ovalfill(body_pos.x - 2, body_pos.y, body_pos.x + Horse.BODY_RECT.x, body_pos.y + Horse.BODY_RECT.y + 2, Horse.SHADOW_COLOR)
  ovalfill(body_pos.x, body_pos.y, body_pos.x + Horse.BODY_RECT.x, body_pos.y + Horse.BODY_RECT.y, Horse.COLOR)
  p8.p8spr(64, 5, 4, self.head_spring:get_pos().x, self.head_spring:get_pos().y)
  self:drawBackLeg()
  p8.p8spr(0x1a, 3, 2, self.backhoof_spring:get_pos().x - 4, self.backhoof_spring:get_pos().y)
  self:drawFrontLeg()
  p8.p8spr(0x30, 3, 2, self.fronthoof_spring:get_pos().x + 4, self.fronthoof_spring:get_pos().y)
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

  self.frontknee_spring:set_target(self:frontKneeTarget())
  self.frontknee_spring:update()
  self.backknee_spring:set_target(self:backKneeTarget())
  self.backknee_spring:update()
end

function Horse:set_back_hoof(new_x)
  self.backhoof_pos.x = new_x
end

function Horse:bump_back_hoof(amt)
  self.backhoof_spring:perturb(v2.v2(0, -amt))
end

function Horse:set_front_hoof(new_x)
  self.fronthoof_pos.x = new_x
end

function Horse:bump_front_hoof(amt)
  self.fronthoof_spring:perturb(v2.v2(0, -amt))
end

return Horse
