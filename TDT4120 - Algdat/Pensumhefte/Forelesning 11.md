# Korteste vei fra alle til alle
APSP = dynamisk programmering over delinstanser som bestemmes av hvor mange noder (eller kanter) som får brukes i stien


### K1 - Forgjengerstrukturen i APSP
(Print-All-Pairs-Shortest-Path)

APSP:
- En distansematrise `D[i][j]` = avstand fra i til j
- En forgjengermatrise `Pi[i][j]` = hvem du kommer fra når du går til j på en korteste vei fra i

Fordi avstander alene ikke forteller hvordan stien ser ut, er dette nødvendig.

`j -> pi[i][j] -> pi[i[pi[i][j]] -> ... -> i`
Det vil si at man går baklengs helt til du kommer til startnode

### K2 - Slow-APSP og Faster-APSP

Slow-APSP
For hver node s i grafen, kjør Bellman-Ford fra s.

Den fungerer selv om det finnes negative kanter og returnerer både distanser og forgjengere.

Kjøretid:
Bellman-Ford O(VE), hvis man kjører for Alle V blir det O(V^2 E). Hvis man man har en graf hfor E kan være O(V^2) kan det derfor bli O(V^4)

Faster-APSP
Bruke en raskere algoritme når mulig
Hvis grafen ikke har negative kanter: bruk Dijkstra.

For hver node s i V, kjør djikstra fra s

Kjøretid: O(VE log V)

### K3 - Floyd Warshall
[[Algoritmer i pensum TDT4120]]

### K4 - Transitive closure
Samme som floyd-warshall, men i boolean form

I stedet for vekter har vi `t[i][j] = True` hvis det finnes en sti fra i til j, ellers false.

![[Pasted image 20251126104154.png]]
Samme struktur som FW, bare med OR/AND
Kjøretid O(V^3)
