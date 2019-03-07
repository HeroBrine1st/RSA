local RSA_basic = require("RSA/RSAB")
local Long = require("metaint")
local serialization = require("serialization")
local typeof = type
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
      else
        local bitlen = type(filepath) == "number" and filepath or 8
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