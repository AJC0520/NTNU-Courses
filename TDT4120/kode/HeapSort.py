import MaxHeap


def HeapSort(A, heap_size):
    heap_size = len(A)
    
    # Bygger en max heap
    MaxHeap.BuildMaxHeap(A) # Kjøretid O(n)
    
    #Går baklengs gjennom lista og flytter det største elementet til slutten for hver iterasjon
    for i in range(len(A) - 1, 0, -1): # Kjøretid n-1
        # Bytter plass på første (største) element og siste element i heapen
        A[0], A[i] = A[i], A[0]
        # Reduserer heap størrelsen med 1 siden siste element nå er riktig plassert
        heap_size -= 1
        
        # Siden vi har ødelagt heapify egenskapen må vi gjenopprette den.
        MaxHeap.MaxHeapify(A, 0, heap_size) # Kjøretid O(lg n)
        
# Kjøretid T(n) = O(n) + O(n lg n) = O(n lg n)

        