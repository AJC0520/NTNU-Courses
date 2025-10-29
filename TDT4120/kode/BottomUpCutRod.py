def BottomUpCutRod(p, n):
    r = [0] * n
    r[0] = 0
    
    for j in range(1, n + 1):
        q = float('-inf')
        for i in range(0, j + 1):
            q = max(q, p[i - 1] + r[j - 1])
        r[j] = q
    return r[n]

