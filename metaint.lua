--by Zer0Galaxy
-- Метачисла позволяют оперировать огромными значениями. Например, посчитать факториал 300 или вычислить 2^2048 --
--        Выражаю признательность HeroBrine1st (http://computercraft.ru/profile/19680-herobrine1st/),           --
--              стараниями которого данная библиотека была доведена до логического завершения                   --

local metaint,m_table
local b=7
local base=10^b

local function div2(num) --целочисленное деление метачисла на 2
  local c=0
  for i=#num,1,-1 do
    num[i],c = math.floor((c*base+num[i])/2), num[i]%2
  end
  while num[#num]==0 and #num>1 do num[#num]=nil end
  return num
end

local function div( op1, op2 )
    if getmetatable(op2)~=m_table then op2=metaint(op2) end
    if op2[1]==0 and op2[2]==nil then error("Division by zero",2) end -- проверяем деление на ноль
    if getmetatable(op1)~=m_table then op1=metaint(op1) end
    local quotient=metaint(0)      -- частное
    local reminder=metaint(op1)    -- остаток
    local c = {} -- промежуточный множитель
      for i=1,#op1-#op2+1 do
        c[i]=op1[#op2-1+i]
      end
    setmetatable(c,m_table)
    local d
    while reminder >= op2 do
      d = c * op2 -- просто чтобы уйти от лишнего умножения
      if reminder >= d then 
        quotient = quotient + c -- увеличиваем частное
        reminder = reminder - d -- уменьшаем остаток
      else
        div2(c)                 -- или промежуточный множитель
      end
    end
    return quotient, reminder
end 

m_table={ --Метатаблица для работы с метачислами
  __index={ 
    tonumber=function(self)  --Преобразует метачисло в обычное число (возможна потеря точности)
	  return tonumber(tostring(self))
	end,

  pow=function(self,e,n)  --Возведение в степень e по модулю n
    local a = metaint(self)
    local p = metaint(e)
    local res=metaint(1)
    while (p[2] or p[1]~=0) do  -- p!=0
      if p[1]%2==1 then
        res=(res*a)%n
        p[1]=p[1]-1  -- быстрое вычитание единицы
      else
        a=(a*a)%n
        div2(p)
      end
    end
    return res
  end,

  sqrt=function(self)  -- извлечение квадратного корня (целочисленное)
    local n0
    local n1 = div2(self+1)
    repeat
      n0=n1
      n1=div2(n0+self/n0)
    until n1>=n0
    return n0
  end
  },

  __tostring=function(self)  --Преобразует метачисло в строку
    local res=""
	local r
	for i=1,#self do
	  r=tostring(math.floor(self[i]))
	  if i<#self then r=string.rep("0",b-#r)..r end
	  res=r..res
	end
	return res
  end,

  __add=function(op1,op2)  --Сложение
    if getmetatable(op1)~=m_table then op1=metaint(op1) end
    if getmetatable(op2)~=m_table then op2=metaint(op2) end
	local res={}
	local c=0
	for i=1,math.max(#op1,#op2) do
	  res[i]=(op1[i] or 0)+(op2[i] or 0)+c
	  if res[i]>=base then res[i]=res[i]-base c=1 else c=0 end
	end
	if c>0 then res[#res+1]=c end
	setmetatable(res,m_table)
	return res
  end,

  __sub=function(op1,op2)  --Вычитание
    if getmetatable(op1)~=m_table then op1=metaint(op1) end
    if getmetatable(op2)~=m_table then op2=metaint(op2) end
	local res={}
	local c=0
	for i=1,#op1 do
	  res[i]=op1[i]-(op2[i] or 0)-c
	  if res[i]<0 then res[i]=res[i]+base c=1 else c=0 end
	end
	while res[#res]==0 and #res>1 do res[#res]=nil end
	setmetatable(res,m_table)
	return res
  end,

  __mul=function(op1,op2)  --Умножение
    if getmetatable(op1)~=m_table then op1=metaint(op1) end
    if getmetatable(op2)~=m_table then op2=metaint(op2) end
	local res={}
	local c,k
	for i=1,#op1 do
	  c=0
	  for j=1,#op2 do
	    k=i+j-1
	    res[k]=(res[k] or 0)+op1[i]*op2[j]+c
		if res[k]>=base then
		  c=math.floor(res[k]/base)
		  res[k]=res[k]-c*base
		else c=0
		end
	  end
	  if c>0 then res[k+1]=(res[k+1] or 0) + c end
	end
  while res[#res]==0 and #res>1 do res[#res]=nil end
	setmetatable(res,m_table);
	return res
  end,

  __div=function(op1, op2)  --Целочисленное деление
    local res = div(op1, op2)
    return res
  end,

  __mod=function(op1, op2)  --Деление по модулю
    local _, res = div(op1, op2)
    return res
  end,

  __pow=function(op1,op2)  --Возведение в степень
    if op2<0 then return metaint(0) end
    if op2==0 then return metaint(1) end
    if op2==1 then return metaint(op1) end
	local res
	if op2%2==0 then res=op1^(op2/2) return res*res end
	res=op1^((op2-1)/2)
	return res*res*op1
  end,

  __eq=function(op1,op2)  --  ==
    if getmetatable(op1)~=m_table then op1=metaint(op1) end
    if getmetatable(op2)~=m_table then op2=metaint(op2) end
	for i=1,math.max(#op1,#op2) do
	  if (op1[i] or 0)~=(op2[i] or 0) then return false end
	end
	return true
  end,

  __lt=function(op1,op2)  --  <
    if getmetatable(op1)~=m_table then op1=metaint(op1) end
    if getmetatable(op2)~=m_table then op2=metaint(op2) end
	for i=math.max(#op1,#op2),1,-1 do
	  if (op1[i] or 0)<(op2[i] or 0) then return true end
	  if (op1[i] or 0)>(op2[i] or 0) then return false end
	end
	return false
  end,

  __le=function(op1,op2)  --  <=
    if getmetatable(op1)~=m_table then op1=metaint(op1) end
    if getmetatable(op2)~=m_table then op2=metaint(op2) end
	for i=math.max(#op1,#op2),1,-1 do
	  if (op1[i] or 0)<(op2[i] or 0) then return true end
	  if (op1[i] or 0)>(op2[i] or 0) then return false end
	end
	return true
  end,

  __concat=function(op1, op2)
    return tostring(op1)..tostring(op2)
  end
}

--Функция создает новое метачисло из числа, строки или другого метачисла
function metaint(num)
  if not num or num=="" then num="0" end
  local obj={}
  if type(num)=="number" then
    repeat
	  obj[#obj+1]=num % base
	  num=math.floor(num/base)
	until num==0
  elseif type(num)=="table" then
	for i=1,#num do obj[i]=num[i] end
  elseif type(num)=="string" then
    while num~="" do
	  obj[#obj+1]=tonumber(num:sub(-b))
      num=num:sub(1,-b-1)
	end
  end
  setmetatable(obj,m_table)
  return obj
end

return metaint
