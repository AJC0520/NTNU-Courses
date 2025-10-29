
def MemoizedCutRod(p, n):
    r = [float('-inf')] * (n + 1)
    return MemoizedCutRodAux(p, n, r)

def MemoizedCutRodAux(p, n, r):
    if r[n] >= 0:
        return r[n]
    
    if n == 0:
        q = 0
    
    else:
        q = float('-inf')
        for i in range(1, n + 1):
            q = max(q, p[i - 1] + MemoizedCutRodAux(p, n - i, r))
    
    r[n] = q
    return q


prices = [1, 5, 8, 9, 10, 17, 17, 20]
n = 8
print(MemoizedCutRod(prices, n))  # Output: 22

# Kjørteid: Theta(N^2)

    