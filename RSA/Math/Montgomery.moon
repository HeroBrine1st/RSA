euclidean_ext = (a, b) ->
    x, xx, y, yy = 1, 0, 0, 1
    while b > 0
        q = a // b
        a, b = b, a % b
        x, xx = xx, x - xx * q
        y, yy = yy, y - yy * q
    return x, y, a


get_bit = (num, pos) ->
    return (num & (1 << pos)) >> pos -- Требуется помощь с длинными битовыми операциями (Напоминаю, что тут числа могут быть больше 2^2048)

bit_length = (num) ->
    return 0 -- Тут тоже бы не отказался от помощи (хотя вроде все просто - делать сдвиг вправо, пока число не станет равно нулю)

class Montgomery
    new: (n, k) =>
        @n = n
        @k = k
        @r = 2 ^ k
        @r_inv, @n_inv, gcd = euclidean_ext(@r, @n)
        @n_inv = -@n_inv  -- Иначе не пройдет проверку
        if gcd ~= 1
            error("gcd(r,n) must be 1")
        if @r * @r_inv - @n * @n_inv != 1
            error("For (#{self.r} that created from #{2} ^ #{k},#{n}) doesn't exists diophantine equation decision")
        @r_inv = @r_inv % @n

    reminder: (a) =>
        return a * @r % @n

    transform: (a) =>
        return a * @r_inv % @n

    mon_pro: (a_n, b_n) =>
        t = a_n * b_n
        u = (t + (t * @n_inv % @r) * @n) >> @k
        if u > @n
            u -= @n
        return u

    mon_exp: (a, e, n) =>
        a = a * @r % n
        x = @r % n
        -- for i in reversed(range(0, bit_length(e))):
        for i = bit_length(e)-1, 0, -1
            x = @mon_pro(x, x)
            if get_bit(e, i) == 1
                x = @mon_pro(x, a)
        return @mon_pro(x, 1)
