local Horse = include("horse.lua")
local v2 = include("v2.lua")
local p8 = include("p8.lua")

-- cps = characters per second
function make_opponent(y, cps, body, hair, shadow, saddle, trim)
  return {
    y = y,
    cps = cps,
    body = body,
    hair = hair,
    shadow = shadow,
    saddle = saddle,
    trim = trim,
  }
end

-- x, y in map space, not screen space
function draw_opponent(opp, x, y)
  pal(6, opp.body)
  pal(7, opp.hair)
  pal(22, opp.shadow)
  pal(16, opp.saddle)
  pal(1, opp.trim)

  p8.p8spr(104, 5, 3, x, y)

  pal()
end

local Race = {
  TRACK_X_INTERPOLATE_FRAMES = 20,

  BOTTOM_COLOR = 18,
  TOP_COLOR = 24,
  UNTYPED_COLOR = 3,

  SCREEN_WIDTH = 480,
  CHAR_WIDTH_PX = 10,

  FRAMES_PER_SECOND = 60,

  CANT_MOVE_ANIM_FRAMES = 10,

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
    opponents = {
      make_opponent(97, 1.5, 16, 17,  1,  9, 25),
      make_opponent(110, 2.2, 20, 31, 21, 23, 14),
      make_opponent(127, 2.7,  6,  7, 22, 16, 1),
    },
    frame = 0,
    cant_move_anim_frames = Race.CANT_MOVE_ANIM_FRAMES,
  }
  setmetatable(o, self)
  self.__index = self

  o.hormse:set_back_hoof(o.bottom_cursor * Race.CHAR_WIDTH_PX)
  o.hormse:set_front_hoof(o.top_cursor * Race.CHAR_WIDTH_PX)
  o:init()
  return o
end

function Race:total_chars()
  local chars = 0
  for i=1,#Race.LINES do
    -- Top lines are always longer than bottom lines.
    chars += #Race.LINES[i].top
  end
  return chars
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
  self.frame += 1
  self.cant_move_anim_frames += 1

  if peektext() then
    local char = readtext()
    if sub(self.top_text, self.top_cursor, true) == char then
      if self.top_cursor - self.bottom_cursor < 6 then
        self.top_cursor = self.top_cursor + 1
        -- Clear the cant move animation, if active.
        cant_move_anim_frames = Race.CANT_MOVE_ANIM_FRAMES
        self.hormse:set_front_hoof((self.chars_so_far + self.top_cursor) * Race.CHAR_WIDTH_PX)
        self.hormse:bump_front_hoof(5)
      else
        self.cant_move_anim_frames = 0
      end
    end
    if sub(self.bottom_text, self.bottom_cursor, true) == char then
      if self.bottom_cursor < self.top_cursor then
        -- Clear the cant move animation, if active.
        cant_move_anim_frames = Race.CANT_MOVE_ANIM_FRAMES
        self.bottom_cursor = self.bottom_cursor + 1
        self.hormse:set_back_hoof((self.chars_so_far + self.bottom_cursor) * Race.CHAR_WIDTH_PX)
        self.hormse:bump_back_hoof(5)
      else
        self.cant_move_anim_frames = 0
      end
    end
  end

  if self:stage_complete() then
    if not self:is_last_level() then
      self:next_stage()
    end
  end
  self.track_x_interpolate_t += 1
  self.hormse:update()
  if self:is_last_level() and self:stage_complete() then
    if not self.hormse_time then
      self.hormse_time = self.frame / Race.FRAMES_PER_SECOND
    end
    local total_chars = self:total_chars()
    return {
      hormse_seconds = self.hormse_time,
      opp_seconds = {
        total_chars / self.opponents[1].cps,
        total_chars / self.opponents[2].cps,
        total_chars / self.opponents[3].cps,
      },
    }
  end
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

function Race:draw_line(text, cursor, x, y, typed_col, untyped_col)
  local typed_text = sub(text, 1, cursor - 1)
  local untyped_text = sub(text, cursor)
  local dx = print("\^w\^t" .. typed_text, x, y, typed_col)
  dx = print("\^w\^t" .. untyped_text, dx, y, untyped_col)

  draw_cursor(cursor, x + self:cant_move_offset(), y, typed_col)
end

function Race:draw_opponents()
  for i=1,#self.opponents do
    local opp = self.opponents[i]
    local x = (Race.CHAR_WIDTH_PX * opp.cps ) * self.frame / Race.FRAMES_PER_SECOND
    draw_opponent(opp, x + abs(5*sin(self.frame/30)), opp.y - abs(5*sin(self.frame/30)))
  end
end

-- Ranges betwen 0 and 0.5.
function Race:cant_move_offset()
  return max(0, Race.CANT_MOVE_ANIM_FRAMES / 2 - abs(Race.CANT_MOVE_ANIM_FRAMES / 2 - self.cant_move_anim_frames))
end

function Race:draw()
  cls()
  local left_x = self.track_x
  if self.track_x_interpolate_t < Race.TRACK_X_INTERPOLATE_FRAMES then
    left_x = self.track_x_interpolate_from + (self.track_x - self.track_x_interpolate_from) * serp(self.track_x_interpolate_t / Race.TRACK_X_INTERPOLATE_FRAMES)
  end
  camera(left_x,0)
  self:draw_course(left_x)
  self:draw_opponents()
  self.hormse:draw()
  camera(0,0)
  self:draw_line(self.top_text, self.top_cursor, 10, 232, Race.TOP_COLOR, Race.UNTYPED_COLOR)
  self:draw_line(self.bottom_text, self.bottom_cursor, 10, 252, Race.BOTTOM_COLOR, Race.UNTYPED_COLOR)
end

return Race
