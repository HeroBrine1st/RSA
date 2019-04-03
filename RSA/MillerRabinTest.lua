local Long = require("metaint")
local longOne = Long(1)
return function(n, k)
  if n == 2 or n == 3 then
    return true, 0
  end
  if n < 2 or n % 2 == 0 then
    return false, 1
  end
  local t = n - 1
  local s = 0
  while t % 2 == 0 do
    t = t / 2
    s = s + 1
  end
  for i = 1, k do
    local _continue_0 = false
    repeat
      dontLetTLWY()
      local a = n * math.floor(math.random() * 10 ^ 14)
      table.remove(a, 1)
      table.remove(a, 1)
      local x = a:pow(t, n)
      if x == longOne or x == n - 1 then
        _continue_0 = true
        break
      end
      for i = 1, s - 1 do
        dontLetTLWY()
        x = x:pow(2, n)
        if x == 1 then
          return false, 1
        end
        if x == n - 1 then
          break
        end
      end
      if x ~= n - 1 then
        return false, 1
      end
      _continue_0 = true
    until true
    if not _continue_0 then
      break
    end
  end
  return true, 4 ^ (-k)
end