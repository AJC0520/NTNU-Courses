# Minimale spenntrær

Sett av kanter som kobler sammen alle nodene (blir et tre med n-1 kanter) og har så lav total vekt som mulig.

### L1 - Disjunkte mengder
Datatstruktur som holder styr på hvilke elementer som hører sammen. Den brukes i kruskal for å forhindre sykler og for å finne om to noder er i samme komponent. 

Skog-implementasjonen
- Hver mengde har et tre og hver tre har:
	- en representant (rot)
	- parent peker for hvert element
	- rotens parent = seg selv

Dette gjør implementasjonen effektivt når vi legger til heuristikkene:
- Union på rank
- Path compression

**Make-Set(x)**
Lager en ny mengde som kun inneholder x
Implementasjon:
- x.parent <- x
- x.rank <- 0
Altså at x er en rot og representant for sin egen mengde.


**Find-Set(x)**
Returnerer representanten for mengden x er i.
- Følg parent-pekerne opp til du finner roten.
- Med path compression: sett alle underveis til å peke direkte på roten.
- Det gjør at senere kall går ekstremt raskt.

**Union(x,y)**
Slår sammen mengdene som inneholder x og y
Men union kaller alltid Find-Set først

hvis rx =ry -> de er allerede i samme gruppe
Hvis ikke, kalles Link(rx, ry)

**Link(rx,ry)**
Slår sammen to trær

Union by rank:
- Den rota med lav rank henges under den med høy rank
- Hvis rank er lik -> velg en som ny rot og øk ranken
Dette hindrer trærne i å bli dype -> raskere Find-Set

**Same-Component(x, y)**
Kortversjon for Kruskal:
Same-Component(x,y) = Find-Set(x) == Find-Set(y)
Hvis dette er sant ligger de i samme komponent, som vil si å legge til denne kanten ville laget en syklus.

**Connected-Components**
En connected component er en mengde av noder der alle kan nå hverandre. 
I union-find modellen er hver rot en komponent. Etter vi har kjørt Union for alle kanter i en urettet graf: Alle noder med samme representant er i samme komponent.

### L2 - Hva er et spenn-tre og MST
Spenn-tre:
Et tre som spenner ovrer alle nodene i grafen og kobler alt sammen, men med ingen sykler.

MST:
Et spann-tre med minst mulig total kantvekt.


### L3 - Generic-MST
Både kruskal og prim er spesialtilfeller av samme grunnide (generic)

1. Start med en tom løsning T
2. Legg til en trygg kant om gangen

### L4 - Hvorfor lette kanter er trygge
En kant e er trygg hvis:
- Vi kan legge den til den delvise løsningen T (skogen vi bygger) uten å risikere at vi mister muligheten til å lage et MST.

En kant e = (u, v) er trygg hvis den er den letteste kanten som krysser et snitt som respekterer T.  

Et snitt er en måte å dele nodene i to grupper på:
S | (V-S)
En kant krysser snittet hvis:
- Den ene enden er i S
- den andre enden er i V-S

Snittet respekterer T, hvis ingen av kantene i T krysser snittet. Altså at T ligger helt på en side av snittet eller består av flere komponenter som hver ligger på sin side.


La e være den letteste kanten som krysser et snitt som respekterer T.  
Ethvert MST må krysse dette snittet med minst én kant.  
Hvis MST bruker en annen kant f som er dyrere enn e, kan vi erstatte f med e og få et billigere tre.  
Dette er en motsigelse.  
Derfor er e trygg.


**Hvis man antar man har en MST, T, som ikke inneholder den letteste cut-kanten e. Da må T inneholde en annen cut-kant, f. Siden e er lettere enn f, kan vi bytte f ut med e og få et like bra eller bedre tre. Dermed finnes det en MST som inneholder  e. Altså er e alltid trygg å ta.**


### L5 - Kruskal
Kruskal = alltid velg letteste kant som ikke danner en syklus.

1. Sorter alle kanter etter vekt
2. T = tomt sett
3. Gå gjennom kantene i stigende vekt:
	- Hvis de forbinder to ulike komponenter (Find-Set)
		- Legg kanten til
		- Union(u,v)

Ferdig når man har n-1 kanter.

Kjøretid:
- Sortering O(m log m)
- Union find O(m a(n))
	- Total: O(m log n)

### L6 - Prim
Prim fungerer som Dijkstra uten avstander.
- Start i en node
- Legg alltid til den letteste kanten som kobler en ny node til treet
- Datastruktur: min-heap (priority queue)

Kjøretid: O(m log n)
Med fib heap: O(m + n log n)