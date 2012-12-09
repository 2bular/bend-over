-- The BENDOVER Reference Implementation
-- 
-- Of course, the name of this language is a pun, both on the primary data mani-
-- pulation mechanism, and the prison-rape-esque feeling of coding in such a
-- language. That in mind, let's BEND OVER and take this piercing blow together!
-- 
-- Current gotchas:
--   - numeric implemented as Lua numerics (double-precision)

EOL = "\n" -- preferred local end-of-line character(s)

maxn = table.maxn or function (t)
  local x = 0
  for k in pairs(t) do
    if x < k then x = k end
  end
  return x
end

function char_iter (s, n)
  local n = n + 1
  if n > #s then return nil end
  return n, string.sub(s, n, n)
end

function chars (s)
  return char_iter, s, 0
end

function initialize (s)
  local a, ab = {}, ""
  for i,c in chars(s) do
    if not a[c] then ab = ab .. c end
    a[c] = true
  end
  
  local tape = {
    x = { [0] = 0, 1, 2 },
    y = { [0] = 0, 0, 0 },
    v = { [0] = 0, 1, ab .. "\n" },
    n = 2,
    p = 0
  }
  
  return setmetatable(tape, { __index = _G })
end

function nextset (tape, val)
  local n = tape.n
  tape.x[n+1] = 2 * tape.x[n] - tape.x[n-1]
  tape.y[n+1] = 2 * tape.y[n] - tape.y[n-1]
  tape.v[n+1] = val or 0
  tape.n = tape.n + 1
  return get(tape, n + 1)
end

function get (tape, num)
  local num = num or tape.n
  while num > tape.n then nextset(tape) end
  return tape.x[num], tape.y[num], tape.v[num], num
end

function insert (tape, num, val1, val2)
  local dx = tape.x[num] - tape.x[num-1]
  local dy = tape.y[num] - tape.y[num-1]
  for i=num,tape.n do
    tape.x[i] = tape.x[i] + dx
    tape.y[i] = tape.y[i] + dy
  end
  tape.v[num] = val2 or tape.v[num]
  table.insert(tape, num, val1 or tape.v[num])
  return tape
end

function remove (tape, num)
  local dx = tape.x[num] - tape.x[num-1]
  local dy = tape.y[num] - tape.y[num-1]
  for i=num,tape.n do
    tape.x[i] = tape.x[i] - dx
    tape.y[i] = tape.y[i] - dy
  end
  table.remove(tape, num)
  return tape
end

-- function clone (tape, num) return table.insert(tape, num, tape.v[num]) end

function bendl (tape, num)
  -- bend left at num
  local rx, ry = tape.x[num], tape.y[num]
  local rs, rd = rx + ry, ry - rx
  for i=num+1,tape.n do
    tape.x[i] = rs - tape.x[i]
    tape.y[i] = rd + tape.y[i]
  end
  return tape
end

function bendr (tape, num)
  -- bend right at num
  local rx, ry = tape.x[num], tape.y[num]
  local rs, rd = rx + ry, rx - ry
  for i=num+1,tape.n do
    tape.x[i] = rd + tape.x[i]
    tape.y[i] = rs - tape.y[i]
  end
  return tape
end

function evaluate (tape, func, ...)
  local char = func(...)
  -- evaluation step
  -- return evaluate(tape, func, ...)
end

evaluate(initialize(io.read('*l')))