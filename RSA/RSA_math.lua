local Long = require("metaint")
local MillerRabinTest = require("RSA/MillerRabinTest")


local function mulNum(op1,op2) -- костыль // применяем правила умножения для обработки целых чисел поверх натуральных
	local inv1 = op1.inv
	local inv2 = op2.inv
	local res = op1*op2
	res.inv = inv1 ~= inv2
	return res
end

local function subNum(op1,op2) -- костыль // применяем правила вычитания для обработки целых чисел поверх натуральных
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
local longTwo = Long(2)
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

local function fermaTest(p) --тест ферма над числом 8 раз 
	local count = 0
	local i = Long(1)
	repeat
	  i = i + 1
	  if i % p ~= 0 then
		local res = i:pow(p - 1, p) == Long(1)
		if res == false then return false,count end
		  count = count + 1
	  end
	  dontLetTLWY()
	until count > 8
	return true
end



local function binToDec(bin) -- преобразование из двоичной системы в десятеричную
  local dec = Long(0)
  for i = 1, #bin do
    local bit = tonumber(bin:sub(i,i))
    local pos = #bin - i
    if bit > 0 then
      dec = dec + (longTwo^pos)*bit
    end
  end
  return dec
end

local function RandomNum(L) -- рандомное нечетное число заданной длины
  local bin = "1"
  for i = 2, L-1 do -- создание двоичного представления числа
    bin = bin .. (math.random() >= 0.5 and "1" or "0")
  end
  bin = bin .. "1"
  return binToDec(bin) -- преобразование
end

local function Prime(L,debug) -- поиск простого числа среди множества чисел длиной L
  local prime
  repeat
    prime = RandomNum(L)
    --local result,count = fermaTest(prime)
    local result, chance = MillerRabinTest(prime,L)
    local accuracy = chance
    if result then accuracy = 1-accuracy end
    if debug then
      print("PRIME FINDING",prime,result,tostring(accuracy*100) .. "% accuracy")
    end
  until result
  return prime
end

return {
	modular_inversion = modular_inversion,
	generate_prime = Prime,
}