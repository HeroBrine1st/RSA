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

local function mulNum(op1,op2) -- костыль // применяем правила математики для обработки целых чисел поверх натуральных
  local inv1 = op1.inv
  local inv2 = op2.inv
  local res = op1*op2
  res.inv = inv1 ~= inv2
  return res
end

local function subNum(op1,op2) -- костыль // применяем правила математики для обработки целых чисел поверх натуральных
  local inv1 = op1.inv
  local inv2 = op2.inv
  if inv1 and inv2 then
    if op1 > op2 then
      local res = op1-op2
      res.inv = true
      return res
    else
      return op2-op1
    end
  elseif inv1 and not inv2 then
    local res = op1 + op2
    res.inv = true
    return res
  elseif not inv1 and inv2 then
    return op1 + op2
  elseif not inv1 and not inv2 then
    if op1 > op2 then
      return op1 - op2
    else
      local res = op2 - op1
      res.inv = true
      return res
    end
  end
end

local longOne = Long(1)
local longZero = Long(0)
local function extendedEuclideanAlgorithm(a,b)
  a,b = Long(a),Long(b)
  local x, xx, y, yy = longOne,longZero,longZero,longOne
  local q
  while b > 0 do
    q = a/b --metaint поддерживает только целочисленное деление
    a,b = b, a%b
    x, xx = xx, subNum(x,mulNum(xx,q))
    y, yy = yy, subNum(y,mulNum(yy,q))
  end
  return x,y,a
end

local function modular_inversion(a,m)
  local x,y,d = extendedEuclideanAlgorithm(a,m)
  if d == longOne then
    local m2 = Long(m)
    m2.inv = true
    return subNum(x,m2)%m
  end
  --print("D",x,y,d)
  return 0
end

local function keypairTest(private,public,rsa_phi)
  local rsa_d = private[1]
  local rsa_e = public[1]
  local rsa_n = public[2]
  return rsa_d*rsa_e%rsa_phi == longOne
end

function RSA.getkey(L) -- Создание ключей
  L = L or 8
  local rsa_e
  local rsa_p
  local rsa_q
  local rsa_phi
  local rsa_n
  local rsa_d
  rsa_e = 65537
  local function RSA_init()
    rsa_p = Prime(L)
    rsa_q = Prime(L)
    while rsa_q == rsa_p do -- недопущение равенства
        rsa_q = Prime(L)
    end
    rsa_n = rsa_p*rsa_q -- модуль RSA
    rsa_phi = (rsa_p-1)*(rsa_q-1) -- функция эйлера от модуля RSA
  end
  local function RSA_E_select()
    while true do -- поиск открытой экспоненты
      --print("RSA_E FINDING",prime,rsa_phi)
      if rsa_phi%rsa_e > 0 and rsa_e < rsa_phi then
          break
      else
        rsa_e = Prime(L/2)
      end
    end
  end
  RSA_init()
  RSA_E_select()
  -- local i = Long(2)
  -- while i <= rsa_phi/2 do -- вычисление закрытой экспоненты
  --     i = i + 1
  --     local d_proto = ((i*rsa_phi)+1)
  --     local d_2 = d_proto%rsa_e
  --     dontLetTLWY()
  --     --print("RSA_D FINDING",d_proto,d_2,i)
  --     if d_2[1] == 0 and d_2[2] == nil then -- d_2 ~= 0
  --       rsa_d = d_proto/rsa_e
  --       --print(rsa_d,i,rsa_phi,rsa_e)
  --       break
  --     end
  -- end

  --вычисление закрытой экспотенты с помощью расширенного алгоритма евклида и моих авторских костылей
  while true do --нахрен он нужен, но мало ли
    rsa_d = modular_inversion(rsa_e,rsa_phi)
    local keyTest = keypairTest({rsa_d,rsa_n},{rsa_e,rsa_n},rsa_phi)
    --print(rsa_d,rsa_e,rsa_n,rsa_phi,keyTest)
    if keyTest then
      break
    end
    RSA_init()
    RSA_E_select()
  end
  local public = {rsa_e,rsa_n}
  local private = {rsa_d,rsa_n}
  return private, public
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