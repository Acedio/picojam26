local Horse = include("horse.lua")
local v2 = include("v2.lua")

local Race = {
  TRACK_X_INTERPOLATE_FRAMES = 20,

  BOTTOM_COLOR = 18,
  TOP_COLOR = 24,
  UNTYPED_COLOR = 3,

  SCREEN_WIDTH = 480,
  CHAR_WIDTH_PX = 10,

  LINES = {
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
  },
}

function Race:new()
  local o = {
    hormse = Horse:new{pos = v2.v2(0, 140)},
    stage = 1,
    bottom_text = Race.LINES[1].bot,
    top_text = Race.LINES[1].top,
    bottom_cursor = 1,
    top_cursor = 1,
    -- Accumulate characters across Race.LINES.
    chars_so_far = 0,
    track_x = 0,
    track_x_interpolate_from = 0,
    track_x_interpolate_t = 100,
  }
  setmetatable(o, self)
  self.__index = self

  o.hormse:set_back_hoof(o.bottom_cursor * Race.CHAR_WIDTH_PX)
  o.hormse:set_front_hoof(o.top_cursor * Race.CHAR_WIDTH_PX)
  o:init()
  return o
end

function Race:init()
  -- Our heroooo, Hormse
  fetch("/system/fonts/lil_mono.font"):poke(0x4000)
end

function Race:stage_complete()
  return self.top_cursor > #Race.LINES[self.stage].top and self.bottom_cursor > #Race.LINES[self.stage].bot
end

function Race:next_stage()
  self.chars_so_far += #Race.LINES[self.stage].top
  self.stage += 1
  self.top_cursor = 1
  self.bottom_cursor = 1
  self.bottom_text = Race.LINES[self.stage].bot
  self.top_text = Race.LINES[self.stage].top
  self.track_x_interpolate_from = self.track_x
  self.track_x_interpolate_t = 0
  self.track_x = self.chars_so_far * Race.CHAR_WIDTH_PX
end

function Race:update()
  if peektext() then
    local char = readtext()
    if sub(self.top_text, self.top_cursor, true) == char and self.top_cursor - self.bottom_cursor < 6 then
      self.top_cursor = self.top_cursor + 1
      self.hormse:set_front_hoof((self.chars_so_far + self.top_cursor) * Race.CHAR_WIDTH_PX)
    end
    if sub(self.bottom_text, self.bottom_cursor, true) == char and self.bottom_cursor < self.top_cursor then
      self.bottom_cursor = self.bottom_cursor + 1
      self.hormse:set_back_hoof((self.chars_so_far + self.bottom_cursor) * Race.CHAR_WIDTH_PX)
    end
  end

  if self:stage_complete() then
    if not self:is_last_level() then
      self:next_stage()
    end
  end
  self.track_x_interpolate_t += 1
  self.hormse:update()
  return self:is_last_level() and self:stage_complete()
end

function draw_cursor(cidx, x, y, col)
  local x = (cidx - 1) * Race.CHAR_WIDTH_PX - 1 + x
  line(x, y, x, y + 16, col)
end

function Race:is_last_level()
  return self.stage == #Race.LINES
end

function Race:draw_finish_line()
  local x = self.track_x + #Race.LINES[self.stage].top * Race.CHAR_WIDTH_PX
  map(30,0,x,0)
end

function Race:draw_course(left_x)
  local first_x = flr(left_x / Race.SCREEN_WIDTH) * Race.SCREEN_WIDTH
  map(0,0,first_x,0)
  map(0,0,first_x + Race.SCREEN_WIDTH,0)
  if self:is_last_level() then
    self:draw_finish_line()
  end
end

function serp(t)
  return (1 + sin(0.25 + 0.5*t))/2
end

function draw_line(text, cursor, x, y, typed_col, untyped_col)
  local typed_text = sub(text, 1, cursor - 1)
  local untyped_text = sub(text, cursor)
  local dx = print("\^w\^t" .. typed_text, x, y, typed_col)
  dx = print("\^w\^t" .. untyped_text, dx, y, untyped_col)

  draw_cursor(cursor, x, y, typed_col)
end

function Race:draw()
  cls()
  local left_x = self.track_x
  if self.track_x_interpolate_t < Race.TRACK_X_INTERPOLATE_FRAMES then
    left_x = self.track_x_interpolate_from + (self.track_x - self.track_x_interpolate_from) * serp(self.track_x_interpolate_t / Race.TRACK_X_INTERPOLATE_FRAMES)
  end
  camera(left_x,0)
  self:draw_course(left_x)
  self.hormse:draw()
  camera(0,0)
  draw_line(self.top_text, self.top_cursor, 10, 232, Race.TOP_COLOR, Race.UNTYPED_COLOR)
  draw_line(self.bottom_text, self.bottom_cursor, 10, 252, Race.BOTTOM_COLOR, Race.UNTYPED_COLOR)
end

return Race
