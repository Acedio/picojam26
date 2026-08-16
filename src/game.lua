local Horse = include("horse.lua")
local v2 = include("v2.lua")

local intro = [[hello, and welcome to the derpy derby!
press any key to start tutorial.]]

local lines = {
  {
    top="move the front legs by typing on this line",
    bot="move the back legs by typing on this line",
  },
  {
    top="get to the finish line",
    bot="without falling apart",
  },
  {
    top="today i had an apple for breakfast",
    bot="gotta go fast today to win",
  },
  {
    top="the wind feels good on my face today",
    bot="if we win this race, we get a prize",
  },
  {
    top="A lovely bouquet!",
    bot="A pretty bouquet!",
  },
}

local stage = 1
local bottom_text = lines[stage].bot
local top_text = lines[stage].top
local bottom_cursor = 1
local top_cursor = 1
local bottom_color = 8
local top_color = 9
local untyped_color = 3

function _init()
  horse = Horse:new{pos = v2.v2(0, 30)}
  fetch("/system/fonts/lil_mono.font"):poke(0x4000)
  horse:set_back_hoof(bottom_cursor * 10)
  horse:set_front_hoof(top_cursor * 10)
end

function _update()
  if peektext() then
    local char = readtext()
    if sub(top_text, top_cursor, true) == char and top_cursor - bottom_cursor < 6 then
      top_cursor = top_cursor + 1
      horse:set_front_hoof(top_cursor * 10)
    end
    if sub(bottom_text, bottom_cursor, true) == char and bottom_cursor < top_cursor then
      bottom_cursor = bottom_cursor + 1
      horse:set_back_hoof(bottom_cursor * 10)
    end
  end
  horse:update()
end

function draw_cursor(cidx, x, y, col)
  local x = (cidx - 1) * 10 - 1 + x
  line(x, y, x, y + 16, col)
end

function draw_line(text, cursor, x, y, typed_col, untyped_col)
  local typed_text = sub(text, 1, cursor - 1)
  local untyped_text = sub(text, cursor)
  local dx = print("\^w\^t" .. typed_text, x, y, typed_col)
  dx = print("\^w\^t" .. untyped_text, dx, y, untyped_col)

  draw_cursor(cursor, x, y, typed_col)
end

function _draw()
  cls()
  map()
  draw_line(top_text, top_cursor, 10, 232, top_color, untyped_color)
  draw_line(bottom_text, bottom_cursor, 10, 252, bottom_color, untyped_color)
  horse:draw()
end
