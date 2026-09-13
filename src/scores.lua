local v2 = include("v2.lua")
local Horse = include("horse.lua")

include("texteffects.lua")

local Scores = {
  HORMSE_START_X = -130,
  SCORE_TABLE_NAME = "highscores",
}

local function fake_scores()
  local scores = {}
  for i=1,64 do
    table.insert(scores, {
      score = -12.2,
      username = "testingasdlkfa sdlf!",
    })
  end
  scores[3].user_id = stat(64)
  return scores
end

function Scores:new()
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.heading = bubbletext("fast hormses", "\^w\^t", 10)
  o.any_key_str = bubbletext("press any key...", "", 5)
  -- Start hormse off a little ahead so they're on screen when the title fades
  -- in. We also adjust their initial pos back a bit so the hormse_x immediately
  -- starts getting them shuffling.
  o.hormse_x = Scores.HORMSE_START_X + 70
  o.hormse = Horse:new{pos = v2.v2(o.hormse_x-20, 140)}
  o.scores = nil
  -- o.scores = fake_scores()
  o.score_anim_frame = 0
  o:init()
  return o
end

function Scores:init()
  -- Clear the input buffer in case any text was waiting.
  readtext(true)
end

function Scores:update_hormse()
  self.hormse_x += 0.5
  if self.hormse_x > 620 then
    self.hormse_x = Scores.HORMSE_START_X
    self.hormse = Horse:new{pos = v2.v2(self.hormse_x, 140)}
  end
  if self.hormse_x + 50 > ((flr(self.hormse.fronthoof_pos.x / 11) + 1) * 11) then
    self.hormse:set_front_hoof(self.hormse_x + 50)
    self.hormse:bump_front_hoof(3)
  end
  if self.hormse_x > ((flr(self.hormse.backhoof_pos.x / 13) + 1) * 13) then
    self.hormse:set_back_hoof(self.hormse_x)
    self.hormse:bump_back_hoof(3)
  end
  self.hormse:update()
end

function Scores:update()
  self.heading:update()
  self.any_key_str:update()
  self:update_hormse()

  if self.scores then
    self.score_anim_frame += 1
  else
    -- Waiting on scores.
    local scores = scoresub(Scores.SCORE_TABLE_NAME)
    if not scores.connecting then
      self.scores = scores
    end
  end

  if peektext() then
    readtext()
    return true
  end

  return false
end

function Scores:draw_score(score, index)
  local is_meeee = stat(64) == score.user_id
  local row = (index - 1) % 8
  local y_base = 90 + row * 18
  local x = -30 * index + self.score_anim_frame - 100
  local x_waver = sin((index * 40 + self.score_anim_frame)/470) * 30
  local gallop = abs(6*sin(x/40))

  if x < -240 or x > 510 then
    return x
  end

  local clipped_username = string.sub(score.username, 1, 16)
  local color = 7
  local border = 0
  if is_meeee then
    color = 10
    border = 9
  end
  printbg("\^w\^t" .. clipped_username, x + 10 + x_waver + gallop / 2, y_base - gallop, color, border)
  local str = string.format("#%d  %0.2fs", index, -score.score, clipped_username)
  printbg(str, x, y_base - 4, 7, 3)
  return x
end

function Scores:draw_scores()
  if not self.scores then
    print("connecting...", 100, 100)
    return
  end
  if #self.scores < 1 then
    print("no fast hormses!", 100, 100)
    return
  end

  local x
  for i=1,#self.scores do
    x = self:draw_score(self.scores[i], i)
  end
  -- If the last score has gone off screen, restart.
  if x > 510 then
    self.score_anim_frame = 0
  end
end

function Scores:draw()
  cls()
  map(0,0)
  self.hormse:draw()
  self.heading:draw(v2.v2(nil, 20))
  self.any_key_str:draw(v2.v2(380, 250))
  self:draw_scores()
end

return Scores
