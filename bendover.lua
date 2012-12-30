-- The BENDOVER Reference Implementation
-- 
-- Of course, the name of this language is a pun, both on the primary data mani-
-- pulation mechanism, and the prison-rape-esque feeling of coding in such a
-- language. That in mind, let's BEND OVER and take this piercing blow together!
-- 
-- Current gotchas:
--   - numeric implemented as Lua numerics (double-precision)
--
-- Tape = {
--   x, y = coordinates of keyed cell
--   v = value at keyed cell
--   n = maximum cell made
--   p = position of pointer
-- }

EOL = "\n" -- preferred local end-of-line character(s)

maxn = table.maxn or function (t)
  local x = 0
  for k in pairs(t) do
    if x < k then x = k end
  end
  return x
end

-- increase values of all arguments
function incr (p, n, ...)
  if not n then return end
  return n + 1, incr(p, ...)
end

function chars (s)
  -- create a closure over s
  local function iter (_, arg)
    if arg then
      s = string.sub(s, 2)
    elseif s == "" then
      return nil
    end
    return string.sub(s, 1, 1)
  end
  
  return iter, nil, false -- arg is false first time
end

-- function old_char_iter (s, n)
--   local n = n + 1
--   if n > #s then return nil end
--   return n, string.sub(s, n, n)
-- end

function initialize (s)
  -- construct alphabet from s
  local a, ab = {}, ""
  for c in chars(s) do
    if not a[c] then ab = ab .. c end -- lol
    a[c] = true
  end
  
  -- prep the tape
  local tape = {
    x = { [0] = 0, 1, 2 },
    y = { [0] = 0, 0, 0 },
    v = { [0] = 0, 1, ab .. "\n" },
    n = 2, p = 0
  }
  
  return setmetatable(tape, { __index = _G })
end

function nextset (tape, val)
  local n = tape.n
  
  -- previous value + change from last to next-to-last
  tape.x[n+1] = 2 * tape.x[n] - tape.x[n-1]
  tape.y[n+1] = 2 * tape.y[n] - tape.y[n-1]
  
  tape.v[n+1] = val or 0 -- set a value optionally
  tape.n = n + 1 -- obv max is raised
  
  return get(tape) -- tail call
end

function get (tape, num)
  local num = num or tape.n
  
  while num > tape.n then nextset(tape) end
  -- tail call from nextset is killed because num
  -- defaults to tape.n, whose entries necessarily
  -- exist because nextset created them already
  
  return tape.x[num], tape.y[num], tape.v[num], num
end

function insert (tape, num, val1, val2)
-- val1 is what to change the original tape value to
-- val2 is the newly created value
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

function flatten (tape, oper)
  local crd, val = {}, tape.v
  for i,v in ipairs(val) do
    local s = tostring(tape.x[i]) .. ' ' .. tostring(tape.y[i])
    if crd[s] then
      val[crd[s]] = oper(val[crd[s]], v, tape)
      val[i] = 0
    else
      crd[s] = i
    end
  end
end

function flat_add (a, b)
  local ta, tb = type(a), type(b)
  
  if a == 0 then
    return b
  elseif b == 0 then
    return a
  elseif ta == "number" and tb == "string" then
    a, b, ta, tb = b, a, tb, ta
  end
  
  if tb == "number" then
    return a + b
  elseif tb == "string" then
    return a .. b
  end
  
  return string.char(incr(b, string.byte(a, 1, #a)))
end

function flat_mult (a, b)
  local ta, tb, = type(a), type(b)
  
  if a == 0 or b == 0 then
    return 0
  elseif ta == "number" and tb == "string" then
    a, b, ta, tb = b, a, tb, ta
  end
  
  if tb == "number" then
    return a * b
  elseif tb == "string" then
    return a == b
  end
  
  return evaluate(makefunc(string.rep(a, b)))
end

function evaluate (tape, func, ...)
  local char = func(...)
  -- evaluation step
  -- return evaluate(tape, func, ...)
end

evaluate(initialize(io.read('*l')))

--[[

+ N e S
N N N
e N e S
S   S S

x N e S
N N e
e e e e
S   e =

( e
    ; )
( e