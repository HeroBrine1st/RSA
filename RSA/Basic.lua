-- Выражаю благодарность Zer0Galaxy (http://computercraft.ru/profile/7-zer0galaxy/) за помощь с длинной арифметикой
-- Закрытый ключ - как ключ от вашей квартиры. Не показывайте его всем и не передавайте незнакомым лицам.

local RSA = {}
local Long = require("metaint")
local RSA_math = require("RSA/Math")
function dontLetTLWY()
  if os.sleep then
    return os.sleep(0)
  end
end
function RSA.getkey(L,debug) -- Создание ключей
  L = L or 8
  local rsa_e
  local rsa_p
  local rsa_q
  local rsa_phi
  local rsa_n
  local rsa_d
  rsa_e = 65537
  rsa_p = RSA_math.generate_prime(L/2,debug)
  rsa_q = RSA_math.generate_prime(L/2,debug)
  while rsa_q == rsa_p do -- недопущение равенства
      rsa_q = RSA_math.generate_prime(L/2,debug)
  end
  rsa_n = rsa_p*rsa_q -- модуль RSA
  rsa_phi = (rsa_p-1)*(rsa_q-1) -- функция эйлера от модуля RSA
  while true do -- поиск открытой экспоненты
    if rsa_phi%rsa_e > 0 and rsa_e < rsa_phi then
        break
    else
      rsa_e = RSA_math.generate_prime(L/4)
    end
  end
  --вычисление закрытой экспотенты с помощью расширенного алгоритма евклида и моих авторских костылей
  rsa_d = RSA_math.modular_inversion(rsa_e,rsa_phi)
  --local keyTest = keypairTest({rsa_d,rsa_n},{rsa_e,rsa_n},rsa_phi)
  local public = {rsa_e,rsa_n}
  local private = {rsa_d,rsa_n}
  --вычисление частей D и обратного к Q, требуется для использования китайской теоремы об остаках
  local dp = rsa_d%(rsa_p-1)
  local dq = rsa_d%(rsa_q-1)
  local qinv = RSA_math.modular_inversion(rsa_q,rsa_p)
  --как и это
  local meta = {
    E = rsa_e,
    D = rsa_d,
    N = rsa_n,
    P = rsa_p,
    Q = rsa_q,
    phi = rsa_phi,
    Dp = dp,
    Dq = dq,
    Qinv = qinv,
  }
  return private, public, meta
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