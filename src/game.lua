local Horse = include("horse.lua")
local v2 = include("v2.lua")

local left_text = "the quick brown fox jumped over the lazy dog"
local right_text = "the quick brown fox jumped over the lazy dog"
-- local left_text = "rearrests secret fever basseted crazes"
-- local right_text = "polynyi junky jinni poilu jin um"
local left_cursor = 2
local right_cursor = 3
local left_color = 1
local right_color = 2
local untyped_color = 3

function _init()
  horse = Horse:new{pos = v2.v2(0, 30)}
  fetch("/system/fonts/lil_mono.font"):poke(0x4000)
  horse:update_back_hoof(left_cursor * 10)
  horse:update_front_hoof(right_cursor * 10)
end

function _update()
  if peektext() then
    local char = readtext()
    if sub(left_text, left_cursor, true) == char and left_cursor + 1 < right_cursor then
      left_cursor = left_cursor + 1
      horse:update_back_hoof(left_cursor * 10)
    end
    if sub(right_text, right_cursor, true) == char and right_cursor - left_cursor < 6 then
      right_cursor = right_cursor + 1
      horse:update_front_hoof(right_cursor * 10)
    end
  end
end

function draw_cursor(cidx, x, y, col)
  local x = (cidx - 1) * 5 - 1 + x
  line(x, y, x, y + 8, col)
end

function draw_line(text, cursor, x, y, typed_col, untyped_col)
  local typed_text = sub(text, 1, cursor - 1)
  local untyped_text = sub(text, cursor)
  local dx = print(typed_text, x, y, typed_col)
  dx = print(untyped_text, dx, y, untyped_col)

  draw_cursor(cursor, x, y, typed_col)
end

function _draw()
  cls()
  draw_line(left_text, left_cursor, 0, 130, left_color, untyped_color)
  draw_line(right_text, right_cursor, 0, 140, right_color, untyped_color)
  horse:draw()
end
