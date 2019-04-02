Long = require("metaint")

longOne = Long(1)

(n,L) ->
    if n == 2 or n == 3
        return true, 1
    if n < 2 or n % 2 == 0
        return false, 1
    k = L
    t = n - 1
    s = 0
    while t%2 == 0
        t /= 2
        s += 1
    for i = 1, k
        a = n*(math.random()*10^14)/10^14
        x = a\mod(t,n)
        if x == longOne or x == n - 1 then
            continue
        for i = 1, s-1
            x = x\pow(2,n)
            if x == 1
                return false, 1
            if x == n - 1
                break
        if x ~= n - 1
            return false, 1
    return true, 4^(-k)