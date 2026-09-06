include("texteffects.lua")

local Line = {
  TEXT_ANIM_FRAMES = 20,
  CANT_MOVE_ANIM_FRAMES = 8,
  CHAR_WIDTH_PX = 10,
}

function Line:new(text, typed_color, untyped_color)
  local o = {
    text = text,
    cursor = 1,
    typed_color = typed_color,
    untyped_color = untyped_color,
    text_anim_frame = {},
    cant_move_anim_frame = Line.CANT_MOVE_ANIM_FRAMES,
  }
  for i=1,#o.text do
    o.text_anim_frame[i] = Line.TEXT_ANIM_FRAMES
  end
  setmetatable(o, self)
  self.__index = self

  return o
end

function Line:next_char()
  return sub(self.text, self.cursor, true)
end

function Line:move_next()
  self.text_anim_frame[self.cursor] = 0
  -- Clear the cant move animation, if active.
  self.cant_move_anim_frame = Line.CANT_MOVE_ANIM_FRAMES
  self.cursor += 1
end

function Line:complete()
  return self.cursor > #self.text
end

function Line:trigger_cant_move_animation()
  self.cant_move_anim_frame = 0
end

function Line:update()
  self.cant_move_anim_frame += 1
  for i=1,#self.text do
    if self.text_anim_frame[i] < Line.TEXT_ANIM_FRAMES then
      self.text_anim_frame[i] += 1
    end
  end
end

-- Ranges betwen 0 and 0.5.
function Line:cant_move_offset()
  local t = max(0, min(1, self.cant_move_anim_frame / Line.CANT_MOVE_ANIM_FRAMES))
  local i = 1 - (2 * t - 1)^2
  return 8 * i
end

function draw_cursor(cidx, x, y, col)
  local x = (cidx - 1) * Line.CHAR_WIDTH_PX - 1 + x
  line(x, y, x, y + 16, col)
end

local function anim_offset(frame)
  local t = frame / Line.TEXT_ANIM_FRAMES
  local i = 1 - (2 * t - 1)^2
  return 6 * i
end

function Line:draw(x, y)
  local dx = x
  for i=1,self.cursor-1 do
    local offset = anim_offset(self.text_anim_frame[i])
    printbg("\^w\^t" .. sub(self.text, i, i), dx + offset / 2, y - offset, self.typed_color, 7)
    dx += 10
  end
  local untyped_text = sub(self.text, self.cursor)
  dx = printbg("\^w\^t" .. untyped_text, dx, y, self.untyped_color, 7)

  draw_cursor(self.cursor, x + self:cant_move_offset(), y, self.typed_color)
end

return Line
