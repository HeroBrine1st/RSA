local RSA_basic = require("RSA/RSAB")
local Long = require("metaint")
local TextSupport = require("RSA/text_support")
local serialization = require("serialization")
local typeof = type
local dontLetTLWY
dontLetTLWY = function()
  return os.sleep(0)
end
local RSA
do
  local _class_0
  local _base_0 = {
    save = function(self, filepath)
      local file = {
        public_key = { },
        private_key = { }
      }
      for i = 1, 2 do
        file.public_key[i] = tostring(self.public_key[i])
        if self.private_key[i] then
          file.private_key[i] = tostring(self.private_key[i])
        end
      end
      local file_data = serialization.serialize(file)
      local f = io.open(filepath, "w")
      f:write(file_data)
      return f:close()
    end,
    sign = function(self, number)
      if self.private_key[1] then
        return RSA_basic.sign(number, self.private_key[1], self.private_key[2])
      else
        return error("No private key", 2)
      end
    end,
    verify = function(self, num, signedNum)
      return RSA_basic.verify(signedNum, self.public_key[1], self.public_key[2]) == Long(num)
    end,
    encrypt = function(self, num)
      return RSA_basic.encrypt(num, self.public_key[1], self.public_key[2])
    end,
    decrypt = function(self, cryptNum)
      if self.private_key[1] then
        return RSA_basic.decrypt(cryptNum, self.private_key[1], self.private_key[2])
      else
        return error("No private key", 2)
      end
    end,
    textEncrypt = function(self, text, saltLen)
      saltLen = saltLen or 4
      if type(saltLen) == "string" then
        saltLen = #saltLen
      end
      local salt = ""
      for i = 1, saltLen do
        salt = salt .. string.char(math.random(0, 255))
      end
      local blocks = TextSupport.textToBlocks(salt .. text, self.public_key[2])
      local result = { }
      for i = 1, #blocks do
        dontLetTLWY()
        result[i] = RSA_basic.encrypt(blocks[i], self.public_key[1], self.public_key[2])
      end
      return result
    end,
    textDecrypt = function(self, result, saltLen)
      saltLen = saltLen or 4
      if not self.private_key[1] then
        error("No private key", 2)
      end
      local blocks = { }
      for i = 1, #result do
        dontLetTLWY()
        blocks[i] = RSA_basic.decrypt(result[i], self.private_key[1], self.private_key[2])
      end
      local text = TextSupport.blocksToText(blocks, self.public_key[2])
      return text:sub(saltLen + 1)
    end,
    textSign = function(self, text)
      if not self.private_key[1] then
        error("No private key", 2)
      end
      local blocks = TextSupport.textToBlocks(text, self.public_key[2])
      local result = { }
      for i = 1, #blocks do
        dontLetTLWY()
        result[i] = RSA_basic.sign(blocks[i], self.private_key[1], self.private_key[2])
      end
      return result
    end,
    textVerify = function(self, text, signedBlocks)
      local blocks = { }
      for i = 1, #signedBlocks do
        dontLetTLWY()
        blocks[i] = RSA_basic.verify(signedBlocks[i], self.public_key[1], self.public_key[2])
      end
      local signedText = TextSupport.blocksToText(blocks, self.public_key[2])
      return text == signedText
    end
  }
  _base_0.__index = _base_0
  _class_0 = setmetatable({
    __init = function(self, filepath)
      if typeof(filepath) == "string" then
        local f, r = io.open(filepath)
        if not f then
          error(r)
        end
        local data, reason = f:read("*a")
        if not data then
          error(reason)
        end
        data = assert(load("return " .. data))()
        local public_key = data.public_key
        local private_key = data.private_key or { }
        self.public_key = { }
        self.private_key = { }
        for i = 1, 2 do
          self.public_key[i] = Long(public_key[i])
          if private_key[i] then
            self.private_key[i] = Long(private_key[i])
          end
        end
      elseif typeof(filepath) == "table" then
        local public_key = filepath.public_key
        local private_key = filepath.private_key or { }
        self.public_key = { }
        self.private_key = { }
        for i = 1, 2 do
          self.public_key[i] = Long(public_key[i])
          if private_key[i] then
            self.private_key[i] = Long(private_key[i])
          end
        end
      else
        local bitlen = type(filepath) == "number" and filepath or 16
        if bitlen < 16 then
          bitlen = 16
        end
        local private, public = RSA_basic.getkey(bitlen)
        self.public_key = public
        self.private_key = private
      end
    end,
    __base = _base_0,
    __name = "RSA"
  }, {
    __index = _base_0,
    __call = function(cls, ...)
      local _self_0 = setmetatable({}, _base_0)
      cls.__init(_self_0, ...)
      return _self_0
    end
  })
  _base_0.__class = _class_0
  RSA = _class_0
  return _class_0
end