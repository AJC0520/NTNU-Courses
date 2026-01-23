# Problemer og reduksjoner

### B[1] - Typer problemer
Tre ulike problemer:
- Søkeproblem
	- Du får en input og skal finne et svar
	- Eksempel: Finn en sti i en graf fra A til B
	- Output er ett objekt
- Beslutningsproblem
	- Ja/nei versjon av et problem
	- Finnes det en sti fra A til B i grafen? (ja/nei)
- Optimeringsproblem
	- Du skal finne en best mulig løsning
	- Korteste sti, billigste løsning

### B[2] - Reduksjoner
"Hvis jeg kan løse problem A ved å bruke en løsning for B, så er A <= B (A er ikke vanskeligere enn B)"

- Karp reduksjon:
	- Input til A -> Transformeres til input for B
	- Slik at løsning på B gir løsning på A
	- Må være beregnbar i polynomisk tid.
	- Dette er vanligst i NP-kompleksitet
- Turing-reduksjon
	- Du kan bruke problemet B som en subrutine flere ganger
	- A kan kalle b mange ganger, ikke bare en
- Cook-reduksjon
	- Levin-reduksjon brukes mellom søkeproblemer, ikke bare ja/nei-problemer.
	- En transformasjon av input fra A → B
	- En transformasjon av løsningen på B → løsning på A
	- Begge må være polynomiske
### B[3] - Redusibilitet
A <= B betyr "hvis jeg kan løse B, kan jeg også løse A"
- B er minst like vanskelig som A
- A er ikke vanskeligere enn B

### B[4] - Løkkeinvarianter
En løkkeinvariant er noe som er sant hver gang du starter løkka.

For eksempel i insertion sort: "Innen starten av hver iterasjon er A[1, j-1] sortert"

Brukes til å bevise:
1. Initiering: Det er sant før løkka starter
2. Vedlikehold: Hvis det er sant i en iterasjon, er det sant i neste.
3. Terminering: Når løkka er ferdig, gir invarianten korrekt løsning.

### B[5] - Rekursiv dekomponering og induksjon
Samme ide som løkkevarianter, bare brukt på rekursive algoritmer
- Splitt problemer i mindre delinstanser
- Anta at algoritmen fungerer korrekt på små instanser
- Vis at den dermed fungerer for større instanser

For eksempel Mergesort:
- Sorter venstre halvdel
- Sorter høyre halvdel
- Slå dem sammen

### B[6] - Lineære programmer
LP = optimaliesering av en lineær funksjon
Under lineære restriksjoner (likninger/ulikheter)
Kan beskrive masse problemer (matching, flyt, ressursfordeling)