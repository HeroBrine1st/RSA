Long = require("metaint")

longOne = Long(1)

(n,k) ->
    if n == 2 or n == 3
        return true, 0
    if n < 2 or n % 2 == 0
        return false, 1
    t = n - 1
    s = 0
    while t%2 == 0
        t /= 2
        s += 1
    for i = 1, k
        dontLetTLWY()
        a = n*math.floor(math.random()*10^14)
        table.remove(a,1)
        table.remove(a,1) -- division by 10^14
        x = a\pow(t,n)
        if x == longOne or x == n - 1 then
            continue
        for i = 1, s-1
            dontLetTLWY()
            x = x\pow(2,n)
            if x == 1
                return false, 1
            if x == n - 1
                break
        if x ~= n - 1
            return false, 1
    return true, 4^(-k)