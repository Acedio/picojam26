local text = "the quick brown fox jumped over the lazy dog"
local left_cursor = 3
local right_cursor = 6
local left_color = 1
local right_color = 2
local untyped_color = 3

function _init()
  fetch("/system/fonts/lil_mono.font"):poke(0x4000)
end

function _update()
  if peektext() then
    local char = readtext()
    if sub(text, left_cursor, true) == char and left_cursor + 1 < right_cursor then
      left_cursor = left_cursor + 1
    end
    if sub(text, right_cursor, true) == char and right_cursor - left_cursor < 6 then
      right_cursor = right_cursor + 1
    end
  end
end

function draw_cursor(cidx, col)
  local x = (cidx - 1) * 5 - 1
  line(x, 0, x, 8, col)
end

function _draw()
  cls()
  local left_text = sub(text, 1, left_cursor - 1)
  local right_text = sub(text, left_cursor, right_cursor - 1)
  local untyped_text = sub(text, right_cursor)
  local x = print(left_text, 0, 0, left_color)
  x = print(right_text, x, 0, right_color)
  x = print(untyped_text, x, 0, untyped_color)

  draw_cursor(left_cursor, left_color)
  draw_cursor(right_cursor, right_color)
end
