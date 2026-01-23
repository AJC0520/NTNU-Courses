# Maskimal flyt

### L1 - Flytnett, flyt og maks-flyt
**Flytnett er en:**
- rettet graf med kapasitet c(u, v) >= 0 på hver kant
- en kilde s
- en sluk t

**Flyt f(u, v)**
Må tilfredstille:
1. Kapasitetskrav:
	0 <= f(u, v) <= c(u, v)
		Flyten må være mer eller lik 0, og kapasiteten må være mer eller lik flyten. (Kan ikke fylle noe mer enn det er plass til)
2. Flytbevaring:
	For alle noder u som ikke er kilde eller sluk
		summen av flyt inn = summen av flytt utø

**Maks-flyt-problemet**
Å finne en gyldig flyt f som maksimerer total flyt ut av s (eller inn i t)


### L2 - Antiparallelle kanter + flere kilder/sluk

Antiparallelle kanter (u -> v og v -> u)
Løses ved å:
- splitte opp noden eller ved å legge inn en hjelpe-node slik at vi unngår unike retninger i restnettverket.
- da får man u -> w med c1 w -> v med c1
- og v -> w med c2 og w -> u med c2

Flere kilder eller flere sluk
- legg til:
	- ny superkilde som peker til alle kilder
	- ny supersluk som mottar fra alle sluk

### L3 - Restnettverk (residual network)
Gitt en flyt f bygger man restnettet G_f

For hver kant (u, v)
1. Fremoverkant med kapasitet
	1. C_f (u, v) = c(u, v) - f(u, v)
		Hvor mye mer flyt du kan fortsatt sende i riktig retning.
2. Bakoverkant med kapasitet
	C_f (v, u) = f (u, v)
	Hvor mye flyt du kan sende tilbake for å angre noe av flyten

Viktig for ford fulkerson

### L4 - Oppheve (cancel) flyt
Når man bruker en bakoverkant i restnettverket betyr det at man trekker tilbake flyt på orginalkanten.

Hvis vi går bakover 3 enheter betyr det bare at
f(u, v) = f(u, v) - 3

Basically hvis man sender flyt på v -> u, synker flyten på u -> v

### L5 - Forøkende sti (augmenting path)
En augmenting path er en sti fra s til t i residualgrafen der alle kanter har positiv restkapasitet. Hvis man finner en slik sti, kan man øke total flyt.

Hvis det finnes en fullstending sti fra s -> t i residualgrafen, betyr det at man kan sende ekstra flyt langs den.

### L6 - Snitt, snitt-kapasitet og minimalt snitt

**Snitt** i et flytnettverk er en oppdeling av nodene i to mengder S og T slik at s er et element i S og t er et element i T.

Alle kanter som går fra S til T er over snittet

**Snitt-kapasitet** er summen av kapasiteten til alle kanter som går fra S til T

Altså, hvor mye flyt som kan passere fra S til T hvis alle kanter var helt fulle

**Minimalt snitt** er det snittet som har minste mulige snittkapasitet blant alle gyldige snitt mellom s og t. (flaskehalsen i netteverket)

### L7 - Maks-flyt/min-snitt-teoremet
Maks flyt = kapasiteten til det minimale snittet.

- Maks flyt stopper når alle kanter i minst ett snitt er fulle
- Disse kantene er flaskehalsen
- Derfor er snittet de tilhører min cut

### L8 - Ford-Fulkerson
[[Algoritmer i pensum TDT4120]]

### L9 - Edmonds-Karp

### L10 - Hvordan finne minimalt snitt i Ford-Fulkerson?
Når maks-flyt er funnet:

- Kjør DFS/BFS fra kilden i restnettverket
- Noder som er nåbare = S
- Resten = T
Snittet (S, T) er et minimalt snitt som teoremet garanterer


### L11 - Maks-flyt -> maksimum bipartitt matching

1. Lag superkilde s
2. Lag supersluk t
3. Koble s -> venstreside-noder med kapasitiet 1
4. Koble høyreside-noder -> t med kapasitet 1
5. For hver mulig matching-edge:
	- lag en kant fra venstre til høyre med kapasitet 1

Kjør maks-flyt → flyten på “midt-kantene” er matchingen.
Flyt = antall matchinger.

### L12 - heltallsteoremet
Hvis alle kapasiteter er heltall, så finner det en maksimal flyt der alle f(u, v) også er heltall.

Dvs:
- bipartitt matching funker
- vi trenger ikke fraksjonell flyt
- ford-fulerkson gir integer flow hvis BFS/DFS velger delta

### L13 - Reduksjoner til maks-flyt problemet
Kan brukes til:
- matching
- fordeling
- planlegging

triks:
- kapasitet = hvor mye som kan "gjøres"
- tvang -> kapasitet 1
- valgmuligheter -> flere kanter
- grupper -> lag mellomlag med noder
