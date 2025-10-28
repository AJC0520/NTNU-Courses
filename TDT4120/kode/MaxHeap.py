import math
# Max-Heap
# Heaps er ofte en tabell og nodene er indekserte.

# Returnerer indeks til forelder
def Parent(i):
    return math.floor(i/2)

# Returnerer indeks til venstre barn
def Left(i):
    return 2*i

# Returnerer indeks til høyre barn
def Right(i):
    return 2*i+1

# Max-Heapify brukes til vedlikehold (ett element på feil plass)
# og for å bygge max-heaps. Den bytter ut tallet med det største av sine barn helt til
# den står på rett plass.
def MaxHeapify(A, i, heap_size):
    # finn indeksen til venstre og høyre barn
    l = Left(i)
    r = Right(i)
    
    #setter forelder som høyeste inntil videre for sammenlikning
    largest = i
    
    # Sjekk om venstre barn eksisterer og om den er større en forelder
    if l < heap_size and A[l] > A[largest]:
        largest = l
        
    # Sjekk om høyre barn eksisterer og om den er hittil største
    if r < heap_size and A[r] > A[largest]:
        largest = r
        
    # Hvis ett av barna er større en forelder, bytt plass
    if largest != i:
        A[i], A[largest] = A[largest], A[i]
        
        # Kall på funksjonen på nytt på det subtreet som ble endret.
        MaxHeapify(A, largest, heap_size)
        
        
#Testkode for Max-Heapify
A = [4, 10, 3, 5, 1]
heap_size = len(A)
print("Før Max-Heapify: " + A)
MaxHeapify(A, 0, heap_size)
print("Etter Max-Heapify: " + A)


# HeapExtractMax Henter ut første element (største element)
def HeapExtractMax(A, heap_size):
    
    # Sjekk om heapen er tom
    if heap_size < 1:
        print("underflow")
        return
    
    #Det største elementet skal alltid ligge på toppen i en korrekt heap
    # Lagres i maximum
    maximum = A[0]
    
    # Flytt siste element fra heapen opp til toppen
    A[0] = A[heap_size - 1]
    
    #Siden vi fjerner ett element blir heap_size 1 mindre
    heap_size -= 1
    
    #Kjør MaxHeapify på det feilplasserte elementet på toppen av heapen, for å gjenopprette heap egeneskapen
    MaxHeapify(A, 0, heap_size)
    return maximum, heap_size


# Øker verdien til en node og flytter den oppover om nødvendig
def HeapIncreaseKey(A, i, key):
    # Sjekk om nye verdi faktisk er større
    if key < A[i]:
        print("new key is smaller than current key")
        return
    
    # Oppdater verdien på node i
    A[i] = key
    
    # Flytt noden oppover så lenge heap egenskapen er brutt
    # (forelder er mindre enn barnet)
    while i > 0 and A[Parent(i)] < A[i]:
        # Bytt forelder og barn
        A[i], A[Parent(i)] = A[Parent(i)], A[i]
        # Flytt opp til foreldrenes posisjon
        i = Parent(i)
    
    
# Setter inn et nytt element i maks-heapen. Kjøretid O(lg n)
def MaxHeapInsert(A, key, heap_size):
    # Øk heap-størrelsen
    heap_size += 1
    
    # Legg til en dummyverdi som er veldig liten slik at HeapIncreaseKey alltid vil øke keyen.
    A.append(float('-inf'))
    
    # Øk verdien til korrekt key
    HeapIncreaseKey(A, heap_size - 1, key)
    
    return heap_size


# Bygge en heap fra en usortert liste
def BuildMaxHeap(A):
    heap_size = len(A)
    
    #Start fra siste interne node og gå opp til roten
    # Alle noder etter heap_size//2 er bladnoder og trenger ikke heapify
    for i in range (heap_size//2 - 1, -1, -1):
        MaxHeapify(A, i, heap_size)
        
    return heap_size
    
    

