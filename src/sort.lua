local Sort = {}

local function partition(tbl, left, right, compare)
  local pivot = right
  right -= 1

  next_low = left
  for i=left,right do
    if compare(tbl[i], tbl[pivot]) then
      local tmp = tbl[next_low]
      tbl[next_low] = tbl[i]
      tbl[i] = tmp
      next_low += 1
    end
  end

  local tmp = tbl[next_low]
  tbl[next_low] = tbl[pivot]
  tbl[pivot] = tmp

  return next_low
end

local function quicksort(tbl, left, right, compare)
  if left >= right then
    -- Nothing to sort.
    return
  end

  local p = partition(tbl, left, right, compare)
  
  quicksort(tbl, left, p - 1, compare)
  quicksort(tbl, p + 1, right, compare)
end

-- lmao there's no table.sort() in picotron for some reason, so here we go!
function Sort.sort(tbl, compare)
  quicksort(tbl, 1, #tbl, compare)
end

function Sort.test()
  local test = {rnd(), rnd(), rnd(), rnd(), rnd(), rnd()}
  Sort.sort(test, function(a,b)
    return a < b
  end)
  for i=1,#test do
    ?test[i]
  end
end

return Sort
