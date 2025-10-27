import InsertionSort
import math

def BucketSort(A):
    # Sortert liste
    A_sorted = []
    # Lengden av lista A
    n = len(A)
    # Lag n tomme "buckets" (lister)
    B = [ [] for x in range(n) ]
    
    # Flytt elementer inn i riktig bucket
    for i in range(n):
        # Mapper elementet til riktig bucket
        B[math.floor(n * A[i])].append(A[i])
        
    for j in range(n):
        #Sorter hver enkel bucket ved bruk av insertion sort
        # Insertion sort er optimal fordi den er rask med korte lister
        InsertionSort(B[j])
    
    # Kombiner til en liste
    for list in B:
        for elem in list:
            A_sorted.append(elem)
    
    # Returnerer den sorterte listen
    return A_sorted

# Bra når:
# - Tallene er jevnt (uniformt) fordelt over et kjent intervall, f.eks. [0,1)
# - Antall elementer er stort nok til at fordelene med bøtter gjør sorteringen rask
# - Subsorteringsalgoritmen (f.eks. Insertion Sort) er rask på små lister
# - Stabil sortering er ønskelig

# Dårlig når:
# - Tallene er skjevt fordelt eller klumpet i noen få intervaller
# - Elementene ikke er numeriske eller kan ikke normaliseres til et kjent intervall
# - Antall elementer per bøtte varierer mye, noe som gjør subsorteringen tung
# - Data inneholder ekstreme verdier som kan skape indeksfeil eller ubalanserte bøtter

            
            
            
    
    
        
    
    
    