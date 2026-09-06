local Horse = include("horse.lua")
local v2 = include("v2.lua")
local p8 = include("p8.lua")
local Line = include("line.lua")

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

  FRAMES_PER_SECOND = 60,

  COUNTDOWN = 1,
  RACE = 2,

  COUNTDOWN_STAGES = 4,
  COUNTDOWN_STAGE_FRAMES = 60,

  COUNTDOWN_STRINGS = {
    "hormse.",
    "hormse..",
    "hormse...",
    "HORMSE!!!",
  },

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
    bottom_text = Line:new(Race.LINES[1].bot, Race.BOTTOM_COLOR, Race.UNTYPED_COLOR),
    top_text = Line:new(Race.LINES[1].top, Race.TOP_COLOR, Race.UNTYPED_COLOR),
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
    countdown_stage = 1,
    countdown_stage_frame = 0,
    state = Race.COUNTDOWN,
  }
  setmetatable(o, self)
  self.__index = self

  o.hormse:set_back_hoof(o.bottom_text.cursor * Line.CHAR_WIDTH_PX)
  o.hormse:set_front_hoof(o.top_text.cursor * Line.CHAR_WIDTH_PX)
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
  return self.top_text:complete() and self.bottom_text:complete()
end

function Race:next_stage()
  self.chars_so_far += #Race.LINES[self.stage].top
  self.stage += 1
  self.bottom_text = Line:new(Race.LINES[self.stage].bot, Race.BOTTOM_COLOR, Race.UNTYPED_COLOR)
  self.top_text = Line:new(Race.LINES[self.stage].top, Race.TOP_COLOR, Race.UNTYPED_COLOR)
  self.track_x_interpolate_from = self.track_x
  self.track_x_interpolate_t = 0
  self.track_x = self.chars_so_far * Line.CHAR_WIDTH_PX
end

function Race:update()
  -- Always update the countdown animation (it'll hide when it's done).
  local countdown_complete = self:countdown_update() 
  -- Also always animate hormse.
  self.hormse:update()
  self.top_text:update()
  self.bottom_text:update()
  if self.state == Race.COUNTDOWN then
    if countdown_complete then
      self.state = Race.RACE
      -- clear the input buffer, no false starts allowed hormse!
      readtext(true)
    end
    return nil
  elseif self.state == Race.RACE then
    return self:race_update()
  else
    assert(nil)
  end
end

function Race:countdown_update()
  self.countdown_stage_frame += 1
  if self.countdown_stage < Race.COUNTDOWN_STAGES and self.countdown_stage_frame >= Race.COUNTDOWN_STAGE_FRAMES then
    self.countdown_stage += 1
    self.countdown_stage_frame = 0
  end
  return self.countdown_stage >= Race.COUNTDOWN_STAGES
end

function Race:race_update()
  self.frame += 1

  if peektext() then
    local char = readtext()
    if self.top_text:next_char() == char then
      if self.top_text.cursor - self.bottom_text.cursor < 6 then
        self.top_text:move_next()
        self.hormse:set_front_hoof((self.chars_so_far + self.top_text.cursor) * Line.CHAR_WIDTH_PX)
        self.hormse:bump_front_hoof(5)
      else
        self.top_text:trigger_cant_move_animation()
        self.bottom_text:trigger_cant_move_animation()
      end
    end
    if self.bottom_text:next_char() == char then
      if self.bottom_text.cursor < self.top_text.cursor then
        self.bottom_text:move_next()
        self.hormse:set_back_hoof((self.chars_so_far + self.bottom_text.cursor) * Line.CHAR_WIDTH_PX)
        self.hormse:bump_back_hoof(5)
      else
        self.top_text:trigger_cant_move_animation()
        self.bottom_text:trigger_cant_move_animation()
      end
    end
  end

  if self:stage_complete() then
    if not self:is_last_level() then
      self:next_stage()
    end
  end
  self.track_x_interpolate_t += 1
  if self:is_last_level() and self:stage_complete() then
    if not self.hormse_finish_time then
      self.hormse_finish_time = self.frame / Race.FRAMES_PER_SECOND
    end
    local total_chars = self:total_chars()
    return {
      hormse_seconds = self.hormse_finish_time,
      opp_seconds = {
        total_chars / self.opponents[1].cps,
        total_chars / self.opponents[2].cps,
        total_chars / self.opponents[3].cps,
      },
    }
  end

  return nil
end

function Race:is_last_level()
  return self.stage == #Race.LINES
end

function Race:draw_finish_line()
  local x = self.track_x + #Race.LINES[self.stage].top * Line.CHAR_WIDTH_PX
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

function Race:draw_opponents()
  for i=1,#self.opponents do
    local opp = self.opponents[i]
    local x = (Line.CHAR_WIDTH_PX * opp.cps ) * self.frame / Race.FRAMES_PER_SECOND
    draw_opponent(opp, x + abs(5*sin(self.frame/30)), opp.y - abs(5*sin(self.frame/30)))
  end
end

function Race:draw_countdown_symbol(x, y)
  local str = Race.COUNTDOWN_STRINGS[self.countdown_stage]
  local centered_x = x - #str * 4
  printbg("\^w\^t" .. str, centered_x, y, 7, 0)
end

function Race:draw_countdown()
  local i = self.countdown_stage_frame / Race.COUNTDOWN_STAGE_FRAMES
  if i > 1 then
    return
  end
  -- Lerps in from the right and then out the left.
  local x = ( - (2 * i - 1)^5 + 0.5 ) * Race.SCREEN_WIDTH
  self:draw_countdown_symbol(x,50)
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
  self.top_text:draw(10, 232)
  self.bottom_text:draw(10,252)
  self:draw_countdown()
end

return Race
