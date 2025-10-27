def QuickSort(A, p, r):
    # Sjekk om delintervallet har mer enn ett element
    if(p < r):
        # Finn posisjonen til pivot etter partisjonering
        q = Partition(A, p, r)
        # Sorter venstre del rekursivt
        QuickSort(A, p, q - 1)
        # Sorter høyre del rekursivt
        QuickSort(A, q + 1, r)
        
def Partition(A, p, r):
    # Velg siste element som pivot
    pivot = A[r]
    # i markerer grensen for elementer mindre eller lik pivot
    i = p - 1
    # Gå gjennom alle elementer fra p til r-1
    for j in range(p, r):
        # Hvis elementet er mindre eller lik pivot
        if(A[j] <= pivot):
            # Flytt grensen for små elementer til høyre
            i = i + 1
            # Bytt plass på A[i] og A[j] slik at små elementer samles til venstre
            A[i], A[j] = A[j], A[i]
    # Sett pivot på riktig plass (rett etter de små elementene)
    A[i + 1], A[r] = A[r], A[i + 1]
    # Returner ny posisjon til pivot
    return i + 1


if __name__ == "__main__":
    # Eksempler på lister som skal sorteres
    test_arrays = [ 
        [38, 27, 43, 3, 9, 82, 10],   # Tilfeldig rekkefølge
        [],                            # Tom liste
        [5],                           # Enkelt element
        [1, 2, 3, 4, 5],               # Allerede sortert
        [5, 4, 3, 2, 1],               # Omvendt sortert
        [3, 3, 2, 1, 4, 4]             # Duplicates
    ]

    # Gå gjennom alle testlister og sorter dem
    for arr in test_arrays:
        print("Før sortering:", arr)  # Skriv ut før sortering
        QuickSort(arr, 0, len(arr) - 1 if arr else -1)  # Sorter listen
        print("Etter sortering:", arr) # Skriv ut etter sortering
        print("-" * 30)                # Skillelinje