RSA_basic = require "RSA/RSAB"
Long = require "metaint"
TextSupport = require "RSA/text_support"
serialization = require "serialization"
typeof = type

dontLetTLWY = () ->
    os.sleep(0)

class RSA
    new: (filepath) =>
        if typeof(filepath) == "string"
            f,r = io.open(filepath)
            if not f then
                error(r)
            data, reason = f\read("*a")
            if not data then 
                error(reason)
            data = assert(load("return " .. data))()
            public_key = data.public_key
            private_key = data.private_key or {}
            @public_key = {}
            @private_key = {}
            for i = 1, 2 do
                @public_key[i] = Long(public_key[i])
                if private_key[i]
                    @private_key[i] = Long(private_key[i])
        elseif typeof(filepath) == "table" then
            public_key = filepath.public_key
            private_key = filepath.private_key or {}
            @public_key = {}
            @private_key = {}
            for i = 1, 2 do
                @public_key[i] = Long(public_key[i])
                if private_key[i]
                    @private_key[i] = Long(private_key[i])
        else
            bitlen = type(filepath) == "number" and filepath or 16
            if bitLen < 16 then --только попробуй сменить - шифрование текста станет недоступно. Алгоритмически.
                bitLen = 16
            private,public = RSA_basic.getkey(bitlen)
            @public_key = public
            @private_key = private
    save: (filepath) =>
        file = {
            public_key:{},
            private_key:{},
        }
        for i = 1,2 do 
            file.public_key[i] = tostring(@public_key[i])
            if @private_key[i]
                file.private_key[i] = tostring(@private_key[i])
        file_data = serialization.serialize(file)
        f = io.open(filepath,"w")
        f\write(file_data)
        f\close()
    sign: (number) =>
        if @private_key[1] then
            return RSA_basic.sign(number,@private_key[1],@private_key[2])
        else
            error("No private key",2)
    verify: (num,signedNum) =>
        return RSA_basic.verify(signedNum,@public_key[1],@public_key[2]) == Long(num)
    encrypt: (num) =>
        return RSA_basic.encrypt(num,@public_key[1],@public_key[2])
    decrypt: (cryptNum) =>
        if @private_key[1] then
            return RSA_basic.decrypt(cryptNum,@private_key[1],@private_key[2])
        else
            error("No private key",2)
    textEncrypt: (text,salt) =>
        salt = salt or ""
        blocks = TextSupport.textToBlocks(salt..text)
        result = {}
        for i = 1, blocks do
            dontLetTLWY()
            result[i] = RSA_Basic.encrypt(blocks[i],@public_key[1],@public_key[2])
        return result
    textDecrypt: (result,salt) =>
        if not @private_key[1] then
            error("No private key",2)
        saltLen = #salt
        blocks = {}
        for i = 1, #result do
            dontLetTLWY()
            blocks[i] = RSA_basic.decrypt(result[i],@private_key[i],@public_key[i])
        text = TextSupport.blocksToText(blocks)
        return text\sub(saltLen+1)