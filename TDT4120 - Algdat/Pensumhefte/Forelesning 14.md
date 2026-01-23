# NP-komplette problemer
### N1 - Hvordan bevise NP-kompletthet med en reduksjon

Som vanlig må to ting bevises:
1. Vise at X er i NP (kan verifiseres polynomisk)
2. Vise at X er NP-hard
	Ta et kjent NP-komplett problem A og reduser det til X i polynomisk tid.
	 - Hvis vi kan løse X raskt, kunne vi løse A ( og dermed alt i NP) like raskt.
	 - X må være minst like vanskelig som A -> NP-Hard
	- 

Altså:
1. Ta et kjent NP-complete problem A
2. lag en polynomisk algoritme som oversette en instans av A til en instans av X
3. Vis to ting:

- Hvis A-instansen er JA → X-instansen er JA
    
- Hvis A-instansen er NEI → X-instansen er NEI


### N2 - NP-komplette problemer

1. Circuit-SAT
	- Finnes det en input som gjør kretsen sann?
2. SAT
	- Finnes det en assignment som gjør hele formelen sann?
3. 3-CNF-SAT
	- Sat der formelen er i 3-CNF (3 litteraler per klausul)
4. CLIQUE
	- Gitt graf G og tall k, finnes det en mengde av k noder som alle er koblet til hverandre?
5. VERTEX-COVER
	 - Gitt graf G og tall k, finnes det en mengde av k noder som dekker alle kanter
6. HAM-CYCLE
	- finnes en hamiltonsk rundtur? (besøker alle noder en gang, men stier kan kun tas en gang)
7. TSP
	- Finnes en rundtur av lengde mindre eller lik K
8. SUBSET-SUM
	- Gitt tall s1, s2, s3 og mål T
	- Finner en delmengde som summerer til T

### N3 - Kompletthetbevisene
- CIRCUIT-SAT → SAT:
	- Konverter krets til logisk formel
- SAT → 3-SAT:
	- Standard transformasjon til CNF med 3 litteraler
- 3-SAT → CLIQUE:
	- Lag en node for hver mulig sann variabel i en klausul
	- Koble sammen kompatible valg  
	- K → antall klausuler
- CLIQUE ↔ VERTEX-COVER:  
	- Bruk komplementgrafen
- HAM-CYCLE → TSP:
	- Gi pris 1 på eksisterende kanter, pris 2 på manglende kanter
- SUBSET-SUM → KNAPSACK:
	- Enkel koding ved bruk av vekter = verdier = tallene

### N4 - 0/1 knapsack NP-hard
0/1 knapsack er NP-hard fordi det binære knapsackproblemet kan løse SUBSET-SUM og den er Np-complete

Hvis man bruker tallene i subset sum som både vekter og verdier, finnes det en knapsack løsning med verdi større eller lik T og vekt mindre eller lik T, hvis og bare hvis det finnes en delmengde som summerer til T.

### N5 - lengste enkle vei NP-hard
Å lese den lengste enkle vei lar deg løse Hamiltonsk vei.
Hvis det finnes en hamiltonsk vei, så finnes det en enkel vei med lengde n-1, derfor er det NP-hard.

### N6 - Reduksjonstrategier

1. Strukturbevaring
	- Behold strukturen i orginalproblemet
2. Kompatibalitet-grafer
	- Knytt sammen valg slik at bare gyldige kombinasjoner er sammenkoblet
3. Komplementer
	- Bruk komplementgrafen
4. Straff ulovlige valg




