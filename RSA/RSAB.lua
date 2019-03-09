-- RSA - криптосистема с открытым ключом
-- Выражаю благодарность Zer0Galaxy (http://computercraft.ru/profile/7-zer0galaxy/) за помощь с длинной арифметикой
-- Закрытый ключ - как ключ от вашей квартиры. Не показывайте его всем и не передавайте незнакомым лицам.

local RSA = {}
local Long = require("metaint")

local function dontLetTLWY()
  if os.sleep then
    return os.sleep(0)
  end
end

local function fermaTest(p) --тест ферма над числом 8 раз 
  local count = 0
  local i = Long(1)
  repeat
    i = i + 1
    if i % p ~= 0 then
      local res = i:pow(p - 1, p) == Long(1)
      if res == false then return false end
      count = count + 1
    end
    dontLetTLWY()
  until count > 8
  return true
end


local function binToDec(bin) -- преобразование из двоичной системы в десятеричную
  local dec = Long(0)
  for i = 1, #bin do
    local bit = Long(bin:sub(i,i))
    local pos = #bin - i
    dec = dec + bit * (Long(2)^pos)
  end
  return dec
end

local function RandomNum(L) -- рандомное число заданной длины
  local bin = "1"
  for i = 2, L do -- создание двоичного представления числа
    bin = bin .. (math.random() >= 0.5 and "1" or "0")
  end
  return binToDec(bin) -- преобразование
end

local function Prime(L) -- поиск простого числа среди множества чисел длиной L
  local prime
  repeat
    prime = RandomNum(L)
    --print("PRIME FINDING",prime)
  until fermaTest(prime)
  return prime
end

-- local longOne = Long(1)
-- local longZero = Long(0)
-- local function extendedEuclideanAlgorithm(a,b)
--   a,b = Long(a),Long(b)
--   local x, xx, y, yy = longOne,longZero,longZero,longOne
--   local q
--   while b > 0 do
--     q = a/b --metaint поддерживает только целочисленное деление
--     a,b = b, a%b
--     x, xx = xx, x - xx*q
--     y, yy = yy, y - yy*q
--   end
--   return x,y,a
-- end

-- local function modular_inversion(a,m)
--   local x,y,d = extendedEuclideanAlgorithm(a,m)
--   if d == Long(1) then return x end
--   print("D",x,y,d)
--   return 0
-- end

local function getkey(L) -- Создание ключей
  L = L or 8
  local rsa_e = 0
  local rsa_p
  local rsa_q
  local rsa_phi
  local rsa_n
  local rsa_d
  rsa_p = Prime(L)
  rsa_q = Prime(L)
  while rsa_q == rsa_p do -- недопущение равенства
      rsa_q = Prime(L)
  end
  rsa_n = rsa_p*rsa_q -- модуль RSA
  rsa_phi = (rsa_p-1)*(rsa_q-1) -- функция эйлера от модуля RSA
  while true do -- поиск открытой экспоненты
      local prime = Prime(math.floor(L/2))
      --print("RSA_E FINDING",prime,rsa_phi)
      if rsa_phi%prime > 0 then
          rsa_e = prime
          break
      end
  end
  local i = Long(2)
  while i <= rsa_phi/2 do -- вычисление закрытой экспоненты
      i = i + 1
      local d_proto = ((i*rsa_phi)+1)
      local d_2 = d_proto%rsa_e
      dontLetTLWY()
      --print("RSA_D FINDING",d_proto,d_2,i)
      if d_2[1] == 0 and d_2[2] == nil then -- d_2 ~= 0
        rsa_d = d_proto/rsa_e
        --print(rsa_d,i,rsa_phi,rsa_e)
        break
      end
  end
  -- вычисление закрытой экспотенты с помощью расширенного алгоритма евклида
  -- print("EXTENDED EUCLIDEAN ALGORITHM AND MODULAR INVERSION")
  -- rsa_d = modular_inversion(rsa_e,rsa_phi)
  -- print(rsa_d,modular_inversion(rsa_phi,rsa_e))
  -- if not rsa_d then print("reverse") rsa_d = modular_inversion(rsa_phi,rsa_e) end
  -- print(rsa_d)
  local public = {rsa_e,rsa_n}
  local private = {rsa_d,rsa_n}
  return private, public
end

function RSA.getkey(L)
  local anyPrime = Prime(L)
  while true do
    --print("iteration")
    local private,public = getkey(L)
    local crypted = RSA.encrypt(anyPrime,public[1],public[2])
    local decrypted = RSA.decrypt(crypted,private[1],private[2])
    if anyPrime == decrypted then
      return private,public
    end
  end
end

local function universal(num0,num1,num2)
  return Long(num0):pow(num1,num2)
end

RSA.encrypt = universal
RSA.decrypt = universal
RSA.sign = universal
RSA.verify = universal
RSA.universal = universal

return RSA