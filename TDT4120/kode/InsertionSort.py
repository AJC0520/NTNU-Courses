def InsertionSort(A):
    # Gå gjennom listen fra element 2
    for i in range(1, len(A)):
        # Elementet som skal sorteres på riktig pos
        current = A[i]
        # Start med å sammenligne elementet rett før current
        j = i - 1
        
        # Elementer som er større enn current skal flyttes en opp
        while j >= 0 and A[j] > current:
            A[j + 1] = A[j] # Flytt elementet til høyre
            j -= 1 # Flytt til forrige element
        
        #current må plasseres på riktig plass
        A[j + 1] = current
        
    #Returnerer kun for bruk en annen plass, insertion-sort er in-place.
    return A

# Bra når:
# - Listen er liten
# - Listen allerede er nesten sortert
# - Stabil sortering er ønskelig
# - Enkel implementasjon er viktig

# Dårlig når:
# - Listen er stor (O(n²) i verste fall)
# - Dataene er tilfeldig eller omvendt sortert
# - Effektivitet på store datasett er viktig

            