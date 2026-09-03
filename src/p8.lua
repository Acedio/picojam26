local P8 = {}

function P8.p8spr(s, w, h, dx, dy)
  for xi=0,w-1 do
    for yi=0,h-1 do
      sspr(s + yi * 8 + xi, 0, 0, 16, 16, dx + xi * 16, dy + yi * 16)
    end
  end
end

return P8
