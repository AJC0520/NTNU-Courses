def MergeSort(A, p, r):
    # Sjekk om delintervallet har mer enn ett element
    if(p < r):
        # Finn midtpunktet for å dele arrayet i to
        q = (p + r) // 2
        # Sorter venstre halvdel rekursivt
        MergeSort(A,p,q)
        # Sorter høyre halvdel rekursivt
        MergeSort(A,q+1, r)
        # Slå sammen de to sorterte halvdelene
        Merge(A, p, q, r)
        
def Merge(A, p, q, r):
    # Beregn lengden på de to delene som skal merges
    n1 = q - p + 1
    n2 = r - q

    # Lag hjelpelister for venstre og høyre del
    L = [A[p + i] for i in range(n1)]
    R = [A[q + 1 + j] for j in range(n2)]

    # Legg til "uendelig" på slutten av begge lister for å forenkle sammenligningen
    L.append(float('inf'))
    R.append(float('inf'))

    # Start-indekser for å traversere hjelpelistene
    i = 0
    j = 0

    # Gå gjennom hele intervallet og legg minste element tilbake i A
    for k in range(p, r+1):
        # Hvis elementet i venstre liste er mindre eller lik høyre
        if L[i] <= R[j]:
            A[k] = L[i]
            i += 1
        else:
            A[k] = R[j]
            j += 1
    
    
arr = [38, 27, 43, 3, 9, 82, 10]  # Eksempel-liste
print("Before sorting:", arr)      # Skriv ut listen før sortering
MergeSort(arr, 0, len(arr) - 1)   # Kall MergeSort på hele listen
print("After sorting: ", arr)      # Skriv ut listen etter sortering


# Bra når:
# - Store datasett
# - Ustabil eller skjev datafordeling
# - Når stabil sortering er ønskelig
# - Eksterne sorteringer / store filer
# - Konsekvent ytelse uavhengig av dataenes rekkefølge

# Dårlig når:
# - Minnebruk er kritisk (krever O(n) ekstra plass)
# - Små datasett (overhead gjør enklere algoritmer raskere)
# - In-place sortering er påkrevd

    
    
    
    
    