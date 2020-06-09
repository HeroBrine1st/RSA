local Long = require("metaint")

local longTwo = Long(2)

local function binToDec(bin)
    -- преобразование из двоичной системы в десятеричную
    local dec = Long(0)
    for i = 1, #bin do
        dontLetTLWY()
        local bit = tonumber(bin:sub(i, i))
        local pos = #bin - i
        if bit > 0 then
            dec = dec + (longTwo ^ pos) * bit
        end
    end
    return dec
end

local function RandomNum(L)
    -- рандомное нечетное число заданной длины
    local bin = "1"
    for _ = 2, L - 1 do
        -- создание двоичного представления числа
        bin = bin .. (math.random() >= 0.5 and "1" or "0")
    end
    bin = bin .. "1"
    return binToDec(bin) -- преобразование
end

return RandomNum