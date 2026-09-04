-- Create with this function, then add update() and draw() to the respetive
-- sections.
function bubbletext(text, font, char_width)
  return {
    t=0,
    text=text,
    char_ticks=2,
    char_width=char_width,
    update=function(self)
      self.t += 1
      return self.t/self.char_ticks > #self.text
    end,
    draw=function(self, pos)
      -- Set pos.x to nil to center.
      if pos.x == nil then
        pos.x = 480/2 - self.char_width/2*#text
      end
      local dx,dy = 0,0
      last_char = flr(self.t/self.char_ticks)
      for i=1,#self.text do 
        if i > last_char then
          break
        end
        text_x = pos.x+dx
        text_y = pos.y+dy+2*cos((4*i+self.t*2)/80)
        printbg(font .. self.text[i], text_x, text_y, 7, 0)
        if self.text[i] == '\n' then
          dx = 0
          dy += 7
        else
          dx += self.char_width
        end
      end
    end,
  }
end

function printbg(text, x, y, fg, bg)
  print(text, x-1, y, bg)
  print(text, x+1, y, bg)
  print(text, x, y-1, bg)
  print(text, x, y+1, bg)
  print(text, x, y, fg)
end
