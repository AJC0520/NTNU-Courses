# Splitt og hersk
### C[1] - Splitt og hersk
Oppskriften er:
1. Divide - del problemet inn i mindre biter
2. Conquer - løs delproblemene rekursivt
3. Combine - kombiner løsningen

For eksempel MergeSort:
	T(n) = 2T(n/2) + O(n)

Splitt i to -> sorter rekursivt -> slå sammen

###  C[2] - Bisect og Bisect'
Handler om å dele en mengde i to deler:
- Bisect
	- Del i to delmengder som er så like store som mulig
	- (n/2 og n/2 eller n/2 og n/2+1)
- Bisect'
	- Del i en fast størrelse og resten
	- 1 og n-1

Bisect'
- Quicksort hvis pivot alltid ender opp som det minste elementet (1, n-1)

Forskjellen er viktig fordi den gir ulike rekurrenser:
Bisect -> T(n) = 2T(n/2) + O(n)
Bisect' -> T(n) = T(1) + T(n-1) + O(n)

### C[3] - MergeSort
[[Algoritmer i pensum TDT4120]]

### C[4] - QuickSort & Randomized Quicksort

