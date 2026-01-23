

# Insertion Sort
Ideen er at man bygger en sortert del av listen fra venstre mot høyre. Hvert nytt element settes inn på riktig plass blant de som allerede er sortert.

#### Hvordan den funker
Gitt listen A = [5,2,4,6,1,3]

1. Første element (5) er sortert.
2. Ta neste element (2), sett den på riktig plass.
	-> A = [2,5,4,6,1,3]
3. Ta neste element (4), sett den på riktig plass.
	-> A = [2,4,5,6,1,3]

osv osv

#### Hva den gjør
For hvert indeks i fra 2 til n:
- Lagre A[i] som key
- Gå bakover og flytt elementer som er større enn key ett hakk til høyre
- Sett key på første plass hvor det passer.

#### Kjøretid:
Best case: Ω(n) når listen allerede er sortert, den bruker bare ett steg per element og ingenting blir flyttet.

Worst case: O(n^2) når lista er i motsatt rekkeføgle. Hvert element må flyttes så langt som mulig (n plasser)

Average case: Θ(n²)

#### Egenskaper:
- In place, O(1) plass
- Stabil

# Merge Sort
Ideen er at man deler lista i to halvparter, sorterer hver del for seg selv, og slår dem sammen til en sortert liste. Den bruker splitt og hersk.

### Hvordan den funker:
Gitt listen A = [5,2,4,6,1,3]
1. Del A i to: [5,2,4] og [6,1,3]
2. Del igjen:
	1. [5,2,4] -> [5] og [2,4]
	2. [2,4] -> [2] og [4]
3. Sorter delene (en lengde er allerede sortert)
4. Merge de små listene sammen
5. Gjør det samme på høyre halvdel
6. Merge de to store delene

### Hva den gjør:
Del listen i to til du står igjen med lister av lengde 1
Merge to sorterte lister ved å ta minste elementet først
Fortsett å merge oppover til hele listen er sortert.


### Kjøretid
Best case: Omega(n log n)
Worst case: O(n log n)
Average case Θ(n log n)

Kostaden kommer fra merging som tar O(n) på hvert nivå av rekursjonen og det finnes log n nivåer

### Egenskaper:
- Ikke in-place, trenger O(n) ekstra plass
- Stabil (rekkefølgen på like elementer bevares)
- God for store datasett, jevn ytelse uansett input


# Quicksort
Ideen er å velge et pivot, og så omorganisere lista slik at alt som er mindre en pivot havner til venstre og alt som er større en pivot havner til høyre. Deretter gjør vi det samme rekursivt på venstre og høyre del.

### Hvordan den funker
Gitt listen A = [5,2,4,6,1,3]
1. Velg et pivot, feks siste element(3)
2. Partisjoner rundt 3.
	1. Flytt tall mindre enn 3 til venstre og større enn 3 til høyre
	2. A = [2,1,3,6,5,4]
	3. Nå står 3 på riktig plass
3. Kjør quicksort på venstre del [2,1]
	1. Velg pivot 1
	2. Partisjoner [1,2]
4. Kjør quicksort på høyre del [6,5,4]
	1. velg pivot 4
	2. partisjoner [4,5,6]
5. Sett sammen

### Hva den gjør
Rekursivt:
Hvis del-lista har 0 eller 1 element -> ferdig
Ellers:
	Velg pivot
	Partisjoner
	Kjør quicksort på venstre og høyre del

- Quicksort(A, p, r):
    hvis p < r:
        q = Partition(A, p, r)
        Quicksort(A, p, q−1)
        Quicksort(A, q+1, r)

### Kjøretid
Best case: Omega(n log n) hvis man har balanserte partisjoner hver gang
Average case: Θ(n log n)
Worst case: O(n^2) hvis lista allerede er sortert med dårlig pivotvalg.

### Egenskaper
- In-place, tar O(1) ekstra plass
- Ikke stabil
- Veldig rask i praksis ved grei input og ok pivotvalg.



# Randomized Quicksort
Ideen er samme som quicksort, men pivot velges tilfeldig. Det gjør at vi fjerner de verste worst-case scenarioene, og får god forventet kjøretid uansett rekkefølge på elementene.

### Hvordan den funker
Samme A = [5,2,4,6,1,3]
1. Velg pivot **tilfeldig** blant elementene, f.eks. 1
2. Bytt pivot til slutten (vanlig triks), partisjoner rundt 1:  
    → [1, …] hvor alt til høyre er ≥ 1
3. Rekursivt:
    - Randomized-Quicksort på venstre del (kan være tom)
    - Randomized-Quicksort på høyre del
4. Hver gang velges pivot **med random indeks**, så vi unngår systematisk dårlige splitt.

### Hva den gjør:
Funker likt som quicksort, bare pivotvalget er annerledes

### Kjøretid:
Forventet kjøretid: Θ(n log n)
Worst case er fortsatt O(n^2)

# Counting Sort
Counting Sort fungerer når elementene er heltall i et kjent intervall 0...k
I stedet for å sammenligne verdier, teller vi hvor mange ganger hver verdi forekommer, og bruker dette til å plassere elementene direkte på riktige posisjon i output-arrayet.

### Hvordan den funker
Gitt A = [4,1,3,4,3] og k = 4

1. Tell forekomster
	- Lag en tabell C[0...k], der C[v] = antall ganger verdien v finnes.
	- C = [0,1,0,2,2]
2. Kumulative summer
	- Gjør C om slik at C[v] = hvor mange elementer som er <= v.
	- C = [0,1,1,3,5]
	- Dette betyr: 
		- Det finnes 1 element mindre eller lik 1
		- Det finnes 3 elementer mindre eller lik 3
		- Det finnes 5 elementer mindre eller lik 4
3. Bygg output fra høyre mot venstre
	- Iterer gjennom A bakleng
	- For hvert element x:
		- C[x] forteller hvor x skal stå
		- Plasser x i output
		- Decrement C[x]
	- Dette bevarer også rekkefølgen på like elementer (stabil)

### Hvorfor er Counting Sort stabil?
Counting sort er stabil fordi vi går gjennom input-arrayet fra høyre mot venstre når vi fyller output-arrayet.

Når vi fyller output baklengs og vi har elementer med lik verdi vil derfor den siste av den verdien bli plassert sist i output. Counting sort er ikke stabil om man fyller fra venstre mot høyre, da får du snudd rekkefølge.


### Kjøretid
Θ(n + k)
Veldig bra når k er liten i forhold til n.


# Radix Sort
Radix sorterer tall siffer for siffer, typisk fra minst signifikante til største.

Eksempel: Sorter tall med 3 sifre
A = [329, 457, 657, 839, 436, 720, 355]

1. Sorter etter ener-plassen (stabilt)
	- [720, 355, 436, 457, 657, 329, 839]
2. Sorter resultatet etter tier-plassen (stabilt)
	- [720, 329, 436, 839, 355, 457, 657]
3. Sorter resultatet etter hundrer-plassen (stabilt)
	- [329, 355, 436, 457, 657, 720, 839]

Counting sort brukes vanligvis for hver sifferrunde.
Radixsort trenger en stabil subrutine fordi når vi sorterer etter et nytt siffer, må rekkefølgen mellom elementer med like sifre bevares fra forrige trinn. Hvis ikke ødelegger vi resultatet fra tidligere runder og sorteringen blir feil.

### Kjøretid for radix:
Counting sort tar Θ(n + k) tid
d = hvor mange ganger man må kjøre subrutinen (antall siffer)
Dermed blir totalen Θ(d * (n + k))

Radix sort er derfor bra å bruke når:
- k og d er små
- Når man sorterer mange tall med lik lengde (postnummer, personnummer, telefonnummer)

# Bucket Sort
Fungerer ved å dele input i flere "bøtter", der hver bøtte dekker et intervall av mulige verdier. Deretter sorteres hver bøtte individuelt (ofte med insertion sort), og så slås alle bøttene sammen i rekkefølge

### Hvordan den funker
Anta at A består av n reelle tall i intervallet [0,1).
Lag n bøtter, for hvert element x:
	- Finn hvilken bøtte det tilhører til: (bucket_index = florr(n * x))
	- Legg x inn i den bøtta
Sorter hver bøtte
Skriv ut elementene ved å traversere bøttene fra venstre mot høyre

### Intuisjon
Tanken er hvis tallene er jevnt fordelt, vil hver bøtte få veldig få elementer, ofte 0 eller 1. Da blir sorteringen per bøtte ekstremt billig.

### Kjøretid:
Best/average
Når data er jevnt fordelt
- Fordeling i bøtter Theta(n)
- Sortering inne i bøtter Theta(n)
- Slå sammen Theta(n)
- Theta(n)

Worst:
Hvis alle verdiene havner i samme bøtte
- Sorter bøtta med feks insertion sort Theta(n^2)

Bucket sort er effektiv fordi den forutsetter jevn fordeling av data og fordi hver bøtte da blir svært liten

I praksis er bucket sort best når dataene kommer fra en uniform fordeling.

### Egenskaper:
- Kan være lineær
- Ikke basert på sammenligninger
- Bruker ekstra minne til bøttene
- Stavil hvis subrutinen inne i hver bøtte er stabil
- Krever at data kan mappes jevnt til bøttene

# Heap Sort
Ideen er å gjøre lista om til en maks-heap, slik at det største elementet alltid ligger i rota. Deretter bytter man roten med siste element, heapify resten og gjenta til hele lista er sortert.

### Hvordan den funker
Gitt listen A = [5,2,4,6,1,3]
1. Bygg en maks-heap
	- Rota er største element (6)
2. Bytt A[1] og A[n]
	- 6 plasseres bakerst
3. Heapify på den reduserte heapen
4. Gjenta til alle elementer et flyttet ut bakfra.

Hele prosessen trekker ut største element én etter én, men i in-place form.

- In place
- ikke stabil



# Kruskal
Kruskal finner et MST ved å:
- Sortere alle kanter etter vekt (lettest først)
- Gå gjennom kantene i denne rekkefølgen
- Legge til en kant hvis den ikke lager en sykel
- Stoppe når du har V-1 kanter i treet.

Bruker disjoint-set / union-find for å sjekke om to noder er i samme komponent.

Kruskal fungerer fordi den alltid velger den tryggeste kanten (letteste kanten som forbinder to ulike kompponenter), noe som igjen er garantert riktig pga cut property.

Kjøretiden domineres av:
- Sortering av kanter O(E log E) = O(E log V)
- Total: O(E log V)

- Finner alltid MST
- Funker for både koblet og ukoblet graf (gir da en skog)
- Passer bra når grafen er sparsommelig (få kanter)

# Prim
Bygger en MST ved å velge en valgfri node og derfra velge den letteste kanten som går fra treet til en node utenfor treet.

"voksende tre" og du kobler på den billigste kanten som utvider treet.
Cut property

Kjøretid:
Med en min heap + adjacency list:
- Hver edge kan gi en update (relax): O( E log V)
- Hver node trekkes ut av heap: O(V log V)
Total: O( E log V)

# Bellman-Ford
Finner korteste vei fra en startnode til alle, i grafer der kantvekter kan være negative, så lenge det ikke finnes en negativ sykel.

Den forbedrer distansen til hver node gradvis, ved å relaxe alle kanter mange ganger.

Den kjører n-1 runder, fordi en simple math kan ha maks n-1 kanter.
Hvis du har funnet korteste stier med mindre enn n-1 kanter, så har man funnet alle mulige simples tier.

Hvis man kjører en ekstra runde og den fortsatt kan relaxes, finnes det en negative sykel.

Kjøretid: O(VE), går gjennom alle kanter n-1 runder

Brukes:
- Når man har negative kantvekter
- Når man trenger å oppdage negative sykler

# DAG-shortest path
Det finnes ingen negative sykler i DAG
Negative kanter går fint

1. Topologisk sorter grafen (DFS)
2. Sett dist[start] = 0 og dist[andre] = uendelig
3. Gå gjennom alle nodene i topologisk rekkefølge, og relax alle utgående kanter akkurat en gang.
4. Fordi grafen er rettet fremover, har man allerede funnet dens endelige korteste distanse når du behandler den.

Funker fordi det ikke finnes noe vei tilbake, kan kun oppdatere fremover en gang.

Kjøretid:
Topologisk sortering O(V + E)
Relaxering gjennom alle kanter: O(E)
O(V + E)

Brukes når grafen er:
- rettet
- uten sykler (DAG)
- kan ha negative vekter

# Dijkstra
Korteste vei fra en til alle, med kun positive kantvekter


1. Fra start node, finn distansen til alle noder som er koblet til, alle andre er uendelig.
2. Loop:
	- Velg korteste vei
	- Relax på valgte node

Den funker  fordi når du velger den neste noden med lavest distanse, så er dens distanse endelig og optimal (siden det ikke er negative kanter) Derfor kan du låse den og trenger ikke å oppdatere den.

Kjøretid:
O(V^2) with simple array
O (E log V)
O(E + V log V) for fib


# Floyd-Warshall
Finner korteste avstand mellom alle par av noder i en graf.
Løser APSP.
Tåler negative kanter, men ikke negative sykler

### Hva den gjør:
Bygger opp en løsning gradvis:
" Hva hvis jeg får lov å bruke node 1 som mellomstasjon?"
" Hva hvis jeg får lov å bruke node 2 som mellomstasjon?"
" Hva hvis jeg får lov å bruke node k som mellomstasjon?"

til slutt har alle noder lov til å være mellomstasjoner, og da har du korteste vei mellom alle par.

`dist[i][j] = min( dist[i][j], dist[i][k] + dist[k][j] )`

Hvis det er kortere å reise i -> k -> j, enn å direkte gå i -> j, oppdaterer man matrisen. Dette gjøres for alle i, j, k

Kjøretid:
Tre løkker over n noder
O(n^3)
Passer for grafer med opptil et par tusen noder.

![[Pasted image 20251126103857.png]]

Forgjenger tabellen oppdateres også samtidig.

# Ford-Fulkerson
Finner maks-flyt i et nettverk ved å finne en forøkende sti i residualgrafen, sender så mye flyt som mulig langs den, oppdaterer residualgrafen, og gjentar til ingen forøkende sti finnes.

### Hvordan den funker:
1. Sett all flyt til 0
2. Bygg residualgrafen
	- Hvor det fortsatt finnes kapasitet (fremoverkanter)
	- hvor vi kan angre flyt (bakoverkanter)
3. Finn en augmenting path s -> t
	En sti hvor alle residualkapasiteter > 0
	Hvis en slik sti ikke finnes -> ferdig
4. Finn "bottleneck" på stien
5. Send flyt langs stien
	 - Øk flyt på alle fremoverkanter
	 - Reduser flyt på alle bakoverkanter
	 - Oppdater residualgrafen
6. Gjenta til ingen forøkende sti finnes

### Kjøretid:
Den grunnleggende er O(E * |f*| ) hvor |f*| er verdien av maksimal flyt.
DFS
Gjør den veldig dårlig om f er stor

# Edmonds-Karp
Ford-fulkerson + BFS

### Hvordan den funker
1. Starter med flyt = 0
2. Lag residualgrafen (fremover + bakoverkanter)
3. Finn en augmenting path fra s til t med BFS
	- Stien med færrest kanter
4. Finn bottleneck på stien
5. Send så mye flyt du kan
6. Oppdater residualgrafen
7. Gjenta til BFS ikke finner noe sti.

Man bruker BFS fordi den velger korteste forøkende sti i antall kanter.
Det gjør:
1. Unngår dårlige valg som gir alt for mange iterasjoner
2. Gir polynomisk kjøretid

I ford-fulkerson kan man være uheldig og gjøre mange små forbedringer -> treg


### Kjøretid:
BFS for å finne forøkende sti O(E)
Maks antall forøkninger: O(VE)

Total kjøretid: O(V E^2)

Edmon karp er ikke basert på input verdier, noe som gjør den bedre

BFS

Max flow med edmon-karp er summen av bottlenecksa fra hver iterasjon, kan også finnes med å summe sammen incoming flow til drain
