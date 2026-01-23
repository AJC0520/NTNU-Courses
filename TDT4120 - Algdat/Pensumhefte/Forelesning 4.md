# Rangering i lineær tid
### D1 - Hvorfor sammenligningsbasert sortering har Ω(n log n)
- Nedre grense for alle sorteringsalgoritmer som kun sammenligner elementer.


1. Sortering betyr å finne riktig permutasjon
- Når man sorterer en liste med n ulike elementer, prøver man egentlig å finne ut hvilken av alle mulige rekkefølger som er den riktige. (n!)

2. Algoritmen lærer kun ved å sammenligne to elementer
	- Hver sammenligning gir maks to mulige svar (ja/nei) siden en sammenligngingsalgoritme får all informasjonen gjennom ja/nei spørsmål.

3. Hver serie av sammensetninger kan vises som et beslutningstre.
	- Vi kan representere en sorteringsalgoritme som et binært beslutningstre
	- Hver node er en sammenligning
	- Vesntre/høyre gren = resultatet av denne sammenligningen
	- Hvert blad = en konklusjon om hvilken permutasjon inputen er.
	- For å kunne sortere alle inputs, må treet ha minst n! blader (ett for hver permutasjon

4. Et binært tre med høyde h kan ha maks 2^h blad
- Men vi må kunne skille mellom n! permutasjoner
- Og derfor kreves:
	- 2^h >= n!
	- h >= log(n!)
	- log(n!) = n log n

![[Pasted image 20251123124618.png]]

### D2 - Hva er en stabil sorteringsalgoritme?
En sortering er stabil hvis elementer med lik verdi beholder sin relative rekkefølge fra input.

Hvis man feks har en sorter liste av navn, men vil heller sortere dem etter alder, men hvis to har samme alder, skal navnerekkefølgen bevares.

### D3 - Counting Sort
[[Algoritmer i pensum TDT4120]]

### D4 - Radix Sort
[[Algoritmer i pensum TDT4120]]

### D5 - Bucket sort
[[Algoritmer i pensum TDT4120]]

### D6 - Randomized select
Finner det k-te minste elementet i O(n) tid

Basically quicksort partisjonering, men i stedet for å sortere begge sider, sorterer vi kun den siden som inneholder svaret.

Forventet kjøretid er Theta(n) fordi vi i snitt tester en pivot som deler arrayet ganske greit. Worst case: O(n^2)

### D7 - Select
Deterministiske versjon
Bruker median-of-medians til å velge pivot som er garantert god nok
Worst case: O(n)
brukes for "finn de k minste elementene i O(n)"





