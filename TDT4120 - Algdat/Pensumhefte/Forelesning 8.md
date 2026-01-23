# Traversering av grafer

### H1 - Implementering av grafer

Adjacency list - best for de fleste algoritmer
- For hver node lagrer man en liste over naboer
- 1: 2,3
- 2: 1,4

 - Plassbruk O(V + E)
 - Bra for BFS, DFS, Dijkstra, MST
 - For å sjekke om en bestemt kant finnes må man se i lista -> O(deg(u))
Adjecency matrix - O(1) edge check, men bruker O(v^2)
- En V x V matrise
- A[u] ,[v ] = 0/1 basert på om det finnes  en kant eller ikke

Fordeler: O(1) for å sjekke om en kant finnes
Ulemper: bruker O(v^2) plass

Når bruker man hva?
**Adjacency list**
→ Når grafen er **sparsom** (få kanter)  
→ Nesten alle algoritmer i pensum: BFS, DFS, Dijkstra, MST  
→ Best minnebruk
Adjacency matrix**
→ Når grafen er **tett** (mange kanter)  
→ Eller når du trenger ekstremt rask “finnes det en kant?”-sjekk: O(1)


### H2 - BFS (breadth first search)
BFS bruker:
- FIFO-kø
- Farger: hvit (ikke oppdaget), grå (oppdaget, ikke ferdig), svart (ferdig)
- Parent-peker for å finne stier

1. Starter på en node s
2. Utforsker alle på avstand 1, så 2, så 3, osv.
3. Finner korteste sti i antall kanter.

BFS gir BFS-tre:
- Inneholder parent[]-pekere
	- Hver gang en node blir oppdaget gjennom en kant setter bfs forelderen til denne noden lik den som den kom fra, det vil si at det blir laget en sti bakover fra hver node til startnoden.
- Brukes til print-path(s, u)
	- For å skrive ut korteste sti fra s til en node u, følger man bare parent pekerne baklengs. Også reverserer du rekkefølgen.

Det fungerer fordi første gang vi ser en node, er dette garantert via en korteste vei.
O(V + E)
Antall noder + antall kanter


### H3 - DFS (depth first search)
(parantesteoremet og hvit sti teoremet)

DFS bruker:
Rekursjon eller en stakk (LIFO kø)

DFS går så dypt som mulig før den backtracker.

Parantesteormet: Hvis v er en etterkommer av u i et DFS tre, vil u bli oppdaget før v, men fullført etter.

Hvit-sti-teormet: En node v er en etterkommer av u i DFS-treet, hvis og bare hvis det fantes en hvit sti fra u til v, da DFS startet på u.

O (V + E)

### H4 - Klassifisering av kanter i DFS
DFS klassifiserer kanter i 4 typer:

- Trekanter (tree edges)
	- brukes av DFS til å besøke en ny hvit node
- back edges
	- kant til en forfader i DFS-treet
	-  betyr at grafen har syklus
- foward edges:
	- kant til en etterkommer som allerede er ferdigprossesert
- cross-edges:
	- alt annet (mellom grener, mellom komponenter)

BFS har kun tree edges og cross-edges

### H5 - Topological Sort
![[Pasted image 20251124141851.png]]
"for å gjøre B, må man gjøre A"

Kjør DFS, noder som man er ferdig med plasseres bakerst i ett array (eller en stack)

Det funker fordi DFS fullfører alltid etterkommere før forfedre. (parantesteoremet)'

Brukes i:
- Planlegging
- DP på grafer
- løse avhengigheter (kompilatorer)

	### H6 - Strongy Connected Components (SCC)
Tar O(V + E) tid, to DFS + transponering

SCC  = Maksimale grupper av noder i en rettet graf, der alle noder kan nå alle andre.
Brukes for å komprimere en graf, analysere moduler, finne sykluser osv.

Kosaraju:
1. Kjør DFS på G, og lagre fullføringstidene
	: feks legg nodene i en stack når de fullføres
2. transponer grafen G
	(snur alle kanter (u ->v ) blir (v -> u) )
3. Kjør DFS på G i synkende rekkefølge av fullføringstider
	- Altså start med noden som fullføre sist
4. Hver DFS i G er nå en SCC

Det funker på grunn av hvit-sti-teoremet, parantesteoremet og fullføringstider.

### H7 - DFS med stakk
DFS-visit bruker rekursjon, men rekursjon er bare en stakk.
For å implementere DFS iterativt:
- Lag en stack S
- push startnoden
- pop -> besøk -> push naboer

### H8 - Traverseringstrær
Når man kjører BFS eller DFS får du et tre som viser hvordan nodene ble oppdaget.

BFS-tre: nivåer = avstand
DFS-tre dyp utforskning

Dette brukes i print-path, bevis av teoremer, analsye av grafstrukturer.

### H9 - Traversering med vilkårlig prioritetskø
BFS, DFS, Dijkstra og Prim er samme grunnalgoritme. De varerer bare hvordan de prioriterer hvilken node som tas ut av køen.


| Algoritme | Datastruktur | Hvem tas ut?                     |
| --------- | ------------ | -------------------------------- |
| BFS       | FIFO         | Eldste node                      |
| DFS       | LIFO         | nyeste node                      |
| Dijkstra  | min-heap     | node med lavest avstandsestimaet |
| Prim      | min-heap     | node med letteste kant til treet |



