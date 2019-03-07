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
  local results = {}
  local count = 0
  local i = Long(1)
  repeat
    i = i + 1
    if i % p ~= 0 then
      table.insert(results, i:pow(p - 1, p) == Long(1))
      count = count + 1
    end
    dontLetTLWY()
  until count > 8
  for i = 1, #results do
    if not results[i] then
      return false
    end
  end
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

function RSA.getkey(L) -- Создание ключей
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
 
  while rsa_e == 0 do -- поиск открытой экспоненты
      local prime = Prime(math.floor(L/2))
      --print("RSA_E FINDING",prime,rsa_phi)
      if rsa_phi%prime > 0 then
          rsa_e = prime
      end
  end
  local i = Long(2)
  while i <= rsa_phi/2 do -- вычисление закрытой экспоненты
      i = i + 1
      local d_proto = ((i*rsa_phi)+1)
      local d_2 = d_proto%rsa_e
      dontLetTLWY()
      if d_2[1] == 0 and d_2[2] == nil then -- d_2 ~= 0
        rsa_d = d_proto/rsa_e
        --print(rsa_d)
        break
      end
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