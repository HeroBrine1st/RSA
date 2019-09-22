local Long = require("metaint")
local MillerRabinTest = require("RSA/Math/MillerRabinTest")
local RandomNum = require("RSA/Math/RandomNum")
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

local function addNum(op1,op2) --костыль // применяем a + b = a - (-b) для обработки целых чисел поверх натуральных
	local op2b = Long(op2)
	op2b.inv = not op2.inv
	return subNum(op1,op2b)
end

local longOne = Long(1)
local longZero = Long(0)
local longTwo = Long(2)
local function extendedEuclideanAlgorithm(a,b)
	a,b = Long(a),Long(b)
	local x, xx, y, yy = longOne,longZero,longZero,longOne
	local q
	while b > 0 do
		dontLetTLWY()
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
		if x.inv then
			return addNum(x, m)
		end
		return x
	end
	return 0
end

local function Prime(L,debug) -- поиск простого числа среди множества чисел длиной L
  local prime
  repeat
    prime = RandomNum(L)
	--local result,count = fermaTest(prime)
	dontLetTLWY()
    local result, chance = MillerRabinTest(prime,L)
    local accuracy = chance
    if result then accuracy = 1-accuracy end
    if debug then
      print("PRIME FINDING",prime,result,tostring(accuracy*100) .. "% accuracy")
    end
  until result
  return prime
end

local function fastEncodeOrSign(C,d,p,q,dp,dq,qinv)
	C = Long(C)
	if not qinv then
		dp = d%(p-1)
		dq = d%(q-1)
		qinv = modular_inversion(q,p)
	end
	local m1 = C:pow(dp,p)
	local m2 = C:pow(dq,q)
	local h = (mulNum(subNum(m1,m2),qinv))%p
	return m2 + h*q
end

return {
	modular_inversion = modular_inversion,
	generate_prime = Prime,
	fast_EOS = fastEncodeOrSign,
}