RSA_basic = require "RSA/RSAB"
Long = require "metaint"
serialization = require "serialization"
typeof = type
class RSA
    new: (filepath) =>
        if typeof filepath == "string"
            local f,r = io.open(filepath)
            if not f
                error(r)
            local data, reason = f\read("*a")
            if not data
                error(reason)
            data = assert(load("return " .. data))()
            local public_key = data.public_key
            local private_key = data.private_key or {}
            @public_key = {}
            @private_key = {}
            for i = 1, 2
                @public_key[i] = Long(public_key[i])
                @private_key[i] = Long(private_key[i])
        elseif typeof filepath == "number"
            local private,public = RSA_basic.getkey(filepath)
            @public_key = public
            @private_key = private
        else
            error("No arguments")
    save: (filepath) =>
        local file = {
            public_key:{},
            private_key:{},
        }
        for i = 1,2 do 
            file.public_key[i] = tostring(@public_key[i])
            if @private_key[i]
                file.private_key[i] = tostring(@private_key[i])
        local file_data = serialization.serialize(file)
        local f = io.open(filepath,"w")
        f\write(file_data)
        f\close()
    sign: (number) =>
        if @private_key[1]
            return RSA_basic.sign(number,@private_key[1],@private_key[2])
        else
            error("No private key")
    verify: (num,signedNum) =>
        return RSA_basic.verify(signedNum,@public_key[1],@public_key[2]) == Long(num)
    encrypt: (num) =>
        reutrn RSA_basic.encrypt(num,@public_key[1],@public_key[2])
    decrypt: (cryptNum) =>
        if @private_key[1]
            return RSA_basic.decrypt(cryptNum,@private_key[1],@private_key[2])
        else
            error("No private key")