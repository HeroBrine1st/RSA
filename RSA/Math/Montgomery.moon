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
        self.n = n
        self.k = k
        self.r = 2 ^ k
        self.r_inv, self.n_inv, gcd = euclidean_ext(self.r, self.n)
        self.n_inv = -self.n_inv  -- Иначе не пройдет проверку
        if gcd ~= 1
            error("gcd(r,n) must be 1")
        if self.r * self.r_inv - self.n * self.n_inv != 1
            error(
                "For (#{self.r} that created from #{2} ^ #{k},#{n}) doesn't exists diophantine equation decision"
            )
        self.r_inv = self.r_inv % self.n

    reminder: (self, a) =>
        return a * self.r % self.n

    transform: (self, a) =>
        return a * self.r_inv % self.n

    mon_pro: (self, a_n, b_n) =>
        t = a_n * b_n
        u = (t + (t * self.n_inv % self.r) * self.n) >> self.k
        if u > self.n
            u -= self.n
        return u

    mon_exp: (self, a, e, n) =>
        a = a * self.r % n
        x = self.r % n
        -- for i in reversed(range(0, bit_length(e))):
        for i = bit_length(e)-1, 0, -1
            x = self.mon_pro(x, x)
            if get_bit(e, i) == 1
                x = self.mon_pro(x, a)
        return self.mon_pro(x, 1)
