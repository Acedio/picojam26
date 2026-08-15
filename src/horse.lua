local v2 = include("v2.lua")

local Horse = {}

Horse.BODY_RECT = v2.v2(40,20)
Horse.LEG_HEIGHT = 10
Horse.COLOR = 1
Horse.HOOF_COLOR = 2
Horse.HOOF_SIZE = 8

function Horse:new(o)
  local o = o or {pos = v2.v2(0,0)}
  self.backhoof_pos = o.pos + v2.v2(0, Horse.BODY_RECT.y + Horse.LEG_HEIGHT)
  self.fronthoof_pos = o.pos + Horse.BODY_RECT + v2.v2(0, Horse.LEG_HEIGHT)
  setmetatable(o, self)
  self.__index = self
  return o
end

function Horse:draw()
  oval(self.pos.x, self.pos.y, self.pos.x + Horse.BODY_RECT.x, self.pos.y + Horse.BODY_RECT.y, Horse.COLOR)
  rect(self.backhoof_pos.x, self.backhoof_pos.y, self.backhoof_pos.x + Horse.HOOF_SIZE, self.backhoof_pos.y + Horse.HOOF_SIZE, Horse.HOOF_COLOR)
  rect(self.fronthoof_pos.x, self.fronthoof_pos.y, self.fronthoof_pos.x + Horse.HOOF_SIZE, self.fronthoof_pos.y + Horse.HOOF_SIZE, Horse.HOOF_COLOR)
end

function Horse:update_back_hoof(new_x)
  self.backhoof_pos.x = new_x
  self.pos.x = (self.fronthoof_pos.x + self.backhoof_pos.x) / 2 - self.BODY_RECT.x / 2
end

function Horse:update_front_hoof(new_x)
  self.fronthoof_pos.x = new_x
  self.pos.x = (self.fronthoof_pos.x + self.backhoof_pos.x) / 2 - self.BODY_RECT.x / 2
end

return Horse
