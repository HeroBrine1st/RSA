RSA_basic = require "RSA/Basic"
Long = require "metaint"
TextSupport = require "RSA/text_support"
RSA_math = require "RSA/Math"

import fast_EOS from RSA_math

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
            @metadata = data.metadata or {}
            for i = 1, 2 do
                @public_key[i] = Long(public_key[i])
                if private_key[i]
                    @private_key[i] = Long(private_key[i])
            for key, value in pairs @metadata
                @metadata[key] = Long(value)
        elseif typeof(filepath) == "table" then
            public_key = filepath.public_key
            private_key = filepath.private_key or {}
            @public_key = {}
            @private_key = {}
            @metadata = filepath.metadata or {}
            for i = 1, 2 do
                @public_key[i] = Long(public_key[i])
                if private_key[i]
                    @private_key[i] = Long(private_key[i])
            for key, value in pairs @metadata
                @metadata[key] = Long(value)
        else
            bitlen = type(filepath) == "number" and filepath or 32
            if bitlen < 32 then --только попробуй сменить - шифрование текста станет недоступно. Алгоритмически.
                bitlen = 32
            private,public,metadata = RSA_basic.getkey(bitlen)
            @public_key = public
            @private_key = private
            @metadata = metadata
    save: (filepath) =>
        file = {
            public_key:{},
            private_key:{},
        }
        for i = 1,2 do
            file.public_key[i] = tostring(@public_key[i])
            if @private_key[i]
                file.private_key[i] = tostring(@private_key[i])
        if @metadata then
            file.metadata = {}
            for key, value in pairs @metadata
                file.metadata[key] = tostring(value)
        file_data = serialization.serialize(file)
        f = io.open(filepath,"w")
        f\write(file_data)
        f\close()
    sign: (number) =>
        if @private_key[1] then
            -- if @metadata then
            --     return fast_EOS(number,@private_key[1],@metadata.P,@metadata.Q,@metadata.Dp,@metadata.Dq,@metadata.Qinv)
            -- else
            return RSA_basic.sign(number,@private_key[1],@private_key[2])
        else
            error("No private key",2)
    verify: (num,signedNum) =>
        unsignedNum = RSA_basic.verify(signedNum,@public_key[1],@public_key[2])
        testNum = Long(num)
        return unsignedNum == testNum, unsignedNum
    encrypt: (num) =>
        return RSA_basic.encrypt(num,@public_key[1],@public_key[2])
    decrypt: (cryptNum) =>
        if @private_key[1] then
            if @metadata then
                return fast_EOS(cryptNum,@private_key[1],@metadata.P,@metadata.Q,@metadata.Dp,@metadata.Dq,@metadata.Qinv)
            else
                return RSA_basic.decrypt(cryptNum,@private_key[1],@private_key[2])
        else
            error("No private key",2)
    textEncrypt: (text,saltLen) =>
        saltLen = saltLen or 4
        if type(saltLen) == "string"
            saltLen = #saltLen
        salt = ""
        for i = 1, saltLen do
            salt = salt .. string.char(math.random(0,255))
        blocks = TextSupport.textToBlocks(salt..text,@public_key[2])
        result = {}
        for i = 1, #blocks do
            dontLetTLWY()
            result[i] = RSA_basic.encrypt(blocks[i],@public_key[1],@public_key[2])
        return result
    textDecrypt: (result,saltLen) =>
        saltLen = saltLen or 4
        if not @private_key[1] then
            error("No private key",2)
        blocks = {}
        if @metadata then
            for i = 1, #result do
                dontLetTLWY()
                blocks[i] = fast_EOS(result[i],@private_key[1],@metadata.P,@metadata.Q,@metadata.Dp,@metadata.Dq,@metadata.Qinv)
        else
            for i = 1, #result do
                dontLetTLWY()
                blocks[i] = RSA_basic.decrypt(result[i],@private_key[1],@private_key[2])
        text = TextSupport.blocksToText(blocks,@public_key[2])
        return text\sub(saltLen+1)
    textSign: (text) =>
        if not @private_key[1] then
            error("No private key",2)
        blocks = TextSupport.textToBlocks(text,@public_key[2])
        result = {}
        -- if @metadata then
        --     for i = 1, #blocks do
        --         dontLetTLWY()
        --         result[i] = fast_EOS(blocks[i],@private_key[1],@metadata.P,@metadata.Q,@metadata.Dp,@metadata.Dq,@metadata.Qinv)
        -- else
        for i = 1, #blocks do
            dontLetTLWY()
            result[i] = RSA_basic.sign(blocks[i],@private_key[1],@private_key[2])
        return result
    textVerify: (text,signedBlocks) =>
        blocks = {}
        for i = 1, #signedBlocks do
            dontLetTLWY()
            blocks[i] = RSA_basic.verify(signedBlocks[i],@public_key[1],@public_key[2])
        signedText = TextSupport.blocksToText(blocks,@public_key[2])\match("(%Z*)")
        return text == signedText,signedText