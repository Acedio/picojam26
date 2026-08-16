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
    bot="gotta go fast today to winnn",
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
local bottom_color = 18
local top_color = 24
local untyped_color = 3
-- Accumulate characters across lines.
local chars_so_far = 0
local track_x = 0
local track_x_interpolate_from = 0
local track_x_interpolate_t = 100
local TRACK_X_INTERPOLATE_FRAMES = 20

local SCREEN_WIDTH = 480
local CHAR_WIDTH_PX = 10

function _init()
  fetch("podnet://1/jam/mfh.sfx"):poke(0x30000)
  music()
  -- Our heroooo, Hormse
  hormse = Horse:new{pos = v2.v2(0, 140)}
  fetch("/system/fonts/lil_mono.font"):poke(0x4000)
  hormse:set_back_hoof(bottom_cursor * CHAR_WIDTH_PX)
  hormse:set_front_hoof(top_cursor * CHAR_WIDTH_PX)
end

function lines_complete()
  return top_cursor > #lines[stage].top and bottom_cursor > #lines[stage].bot
end

function next_stage()
  chars_so_far += #lines[stage].top
  stage += 1
  top_cursor = 1
  bottom_cursor = 1
  bottom_text = lines[stage].bot
  top_text = lines[stage].top
  -- TODO: interpolate to this.
  track_x_interpolate_from = track_x
  track_x_interpolate_t = 0
  track_x = chars_so_far * CHAR_WIDTH_PX
end

function _update()
  if peektext() then
    local char = readtext()
    if sub(top_text, top_cursor, true) == char and top_cursor - bottom_cursor < 6 then
      top_cursor = top_cursor + 1
      hormse:set_front_hoof((chars_so_far + top_cursor) * CHAR_WIDTH_PX)
    end
    if sub(bottom_text, bottom_cursor, true) == char and bottom_cursor < top_cursor then
      bottom_cursor = bottom_cursor + 1
      hormse:set_back_hoof((chars_so_far + bottom_cursor) * CHAR_WIDTH_PX)
    end
  end

  if lines_complete() then
    if not is_last_level() then
      next_stage()
    else
      -- win!
    end
  end
  track_x_interpolate_t += 1
  hormse:update()
end

function draw_cursor(cidx, x, y, col)
  local x = (cidx - 1) * CHAR_WIDTH_PX - 1 + x
  line(x, y, x, y + 16, col)
end

function draw_line(text, cursor, x, y, typed_col, untyped_col)
  local typed_text = sub(text, 1, cursor - 1)
  local untyped_text = sub(text, cursor)
  local dx = print("\^w\^t" .. typed_text, x, y, typed_col)
  dx = print("\^w\^t" .. untyped_text, dx, y, untyped_col)

  draw_cursor(cursor, x, y, typed_col)
end

function is_last_level()
  return stage == #lines
end

function draw_finish_line()
  local x = track_x + #lines[stage].top * CHAR_WIDTH_PX
  map(30,0,x,0)
end

function draw_course(left_x)
  local first_x = flr(left_x / SCREEN_WIDTH) * SCREEN_WIDTH
  map(0,0,first_x,0)
  map(0,0,first_x + SCREEN_WIDTH,0)
  if is_last_level() then
    draw_finish_line()
  end
end

function serp(t)
  return (1 + sin(0.25 + 0.5*t))/2
end

function _draw()
  cls()
  local left_x = track_x
  if track_x_interpolate_t < TRACK_X_INTERPOLATE_FRAMES then
    left_x = track_x_interpolate_from + (track_x - track_x_interpolate_from) * serp(track_x_interpolate_t / TRACK_X_INTERPOLATE_FRAMES)
  end
  camera(left_x,0)
  draw_course(left_x)
  hormse:draw()
  camera(0,0)
  draw_line(top_text, top_cursor, 10, 232, top_color, untyped_color)
  draw_line(bottom_text, bottom_cursor, 10, 252, bottom_color, untyped_color)
end
