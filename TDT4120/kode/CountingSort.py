def CountSort(A, B, k): # k= største element
    # Sette opp teller array
    C = [0 for x in range(k + 1)]
    
    # Gå gjennom listen A
    for j in range(len(A)):
        # Elementet på plass A[j] er indeks i C med en teller som element
        C[A[j]] += 1
    
    # Gå gjennom listen C
    for i in range(1, k + 1):
        # Øk hver verdi med verdi + verdi fra forrige indeks
        # Dette gjøres for å vite hvor i den sorterte listen hvert element skal plasseres.
        C[i] = C[i] + C[i-1]
        
    for j in range(len(A) - 1, -1, -1):
        B[C[A[j]] - 1] = A[j]
        C[A[j]] -= 1
        
        
A = [4, 2, 2, 8, 3, 3, 1]
B = [0] * len(A)
CountSort(A, B, max(A))
print(B)

        
        
        
        