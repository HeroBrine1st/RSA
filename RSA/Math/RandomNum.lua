local Long = require("metaint")

local longTwo = Long(2)
local cache = {} -- оптимизируем скорость создания рандомного числа засчет памяти. Не очень много должно занять

local function binToDec(bin) -- преобразование из двоичной системы в десятеричную
    local dec = Long(0)
    for i = 1, #bin do
        dontLetTLWY()
        local bit = tonumber(bin:sub(i,i))
        local pos = #bin - i
        if bit == 1 then
            local longTwoPowToPos
            if not cache[pos] then
                longTwoPowToPos = longTwo^pos
                cache[pos] = tostring(longTwoPowToPos)
            else
                longTwoPowToPos = Long(cache[pos])
            end
            dec = dec + longTwoPowToPos
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

return RandomNum