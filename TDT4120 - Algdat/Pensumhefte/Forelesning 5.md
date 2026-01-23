# Rotfaste trestrukturer
### E1 - Heaps of prioritetskøer
En heap er ikke et søketre. Det er en komplett binæretre-struktur lagret i array.

To typer: MAx-heap og Min-heap

Haugegenskapen:
- I en max-heap:
	- Foreldrenes verdi er alltid større eller lik enn begge barna.
	- Dette gjelder rekursivt nedover hele treet.

Hvordan lagres heapen?
- Alt i ett array:
- Parent(i) = floor(i/2)
- Left(i) = 2i
- Right(i) = 2i+1

Dette gjør heapen ekstremt effektivt.

De viktigste operasjonene
- Max-Heapify(A,i)
	- Maintains max-heap egenskapen
	- Man antar an venstre og høyre barn av en node i allerede er heaps
	- i kan være mindre enn ett av barna (isåfall må vi gjøre noe)
	- ![[Pasted image 20251123142505.png]]- Siden som blir endret blir rekusrivt kalt
	- "Flyter ned"
	- O(log n), siden man kan kalle max-heapify for hver level (høyde av binært tre)
- Build-Max-Heap(A)
	- Wrapper funksjon for å kalle max-heapify
		-   O(n)
- Max-Heap-Insert
	- Setter inn nytt element og bobler det opp
	- O(log n)
	- Setter inn på slutten og bobler opp ved å sjekke om parent er større
- Extract-max
	Returner rota, flytt siste element til rota, heapify ned for å gjennopprette heapify egenskapen
	O(log n)

### E2 - HeapSort
[[Algoritmer i pensum TDT4120]]

### E3- Treimplementasjon med pekere
For generelle trær med mange barn kan man bruke firstchild/nextsibiling relasjonen
- Hver node har pointer til første barn og pointer til neste søsken. Det gjør at man kan representere et helt tre med kun to pekere per node

### E4 - Binære søketrær (BST)
BST Egenskapen:
For en node x:
	Alle i venstre deltre < x.key
	Alle i høyre deltre > x.key
	Gjelder for hvert deltre rekursivt

Dette gjør søking raskt

BST Operasjoner:

Tree-Search(x, k):
- Gå venstre hvis k < x.key
- Gå høyre hvis k > x.key
- Treff hvis k == key
- Tid = høyden på treet, h. O(h)

Tree-min og Tree-max
- Gå helt til venstre (min)
- Gå helt til høyre (max)
- O(h)

Tree-Succesor(x):
- Neste i inorder-rekkefølge
- Hvis høyre barn finnes -> min i høyre deltre
- Altså, gå til høyre 1 gang og deretter så langt til venstre som du kommer
- Treemin(x.right)

Tree-Insert
- Start i rota
- Gå til vesntre hvis minre, høyre hvis større
- Sett inn når du finner en tom plass
- Kjøretid = høyden av treet
	- O (log n ) balasnert
	- O (n) ubalansert

Tree-delete:
- Hvis node har to barn, bytt med succesor, slett succesor
- Hvis node har et barn, bytt og slett
- Hvis node har ingen barn, slett



### E5, E6, - Høydeanalyse

Tilfeldig BST:
Hvis du setter inn n nøkler i tilfeldig rekkefølge:
- Forventet høyde Theta(log n)
- Forventet søketid Theta(log n)

Sortert input:
tre blir som lenker
Høyde = n
søketid = n

Finnes BST med garanter høyde log n (AVL, Red-black)