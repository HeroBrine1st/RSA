local bit = require("bit32")
local Long = require("metaint")
local function StrToInt(str)
    local int = 0
    local byte
    while #str < 4 do
        str = str .. "\0"
    end
    for i = 0, 3 do
        byte=str:sub(1,1)
        str=str:sub(2)
        int=bit.lshift(int,8)+(string.byte(byte) or 0)
    end
    return int, str
end

local function IntToStr(int)
    local str = ""
    local char
    for i = 0, 3 do
        char=bit.band(bit.rshift(int, 24), 255)
        int=bit.lshift(int,8)
        str=str..string.char(char)
    end
    return str
end

local function blocksFromText(text)
    local blocks = {}
    for i = 1, #text, 4 do
        local text_block = text:sub(i,i+3)
        blocks[math.ceil(i/4)] = StrToInt(text_block)
    end
    return blocks
end

local function textFromBlocks(blocks)
    local text = ""
    for i = 1, #blocks do
        local text_block = IntToStr(tonumber(tostring(blocks[i])))
        text = text .. text_block
    end
    return text
end

local function blocksMove(blocks,module)
    local function transformBlock(prev,current)
        return Long(prev+current)%module
    end
    local result = {blocks[1]}
    for i = 2, #blocks do
        result[i] = transformBlock(result[i-1],blocks[i])
    end
    return result
end

local function blocksReturn(blocks,module)
    local function transformBlock(prev,current)
        local result = Long(current-prev)%module
        if result < 0 then result = module-result end
        return result
    end
    local result = {blocks[1]}
    for i = 2, #blocks do
        result[i] = transformBlock(blocks[i-1],blocks[i])
    end
    return result  
end

return {
    textToBlocks = function(text,module)
        local blocks = blocksFromText(text)
        return blocksMove(blocks,module)
    end,
    blocksToText = function(blocks,module)
        local blocks2 = blocksReturn(blocks,module)
        return textFromBlocks(blocks2)
    end,
    blocksReturn = blocksReturn,
    blocksMove = blocksMove,
    blocksFromText = blocksFromText,
    textFromBlocks = textFromBlocks,
    IntToStr = IntToStr,
    StrToInt = StrToInt,
}