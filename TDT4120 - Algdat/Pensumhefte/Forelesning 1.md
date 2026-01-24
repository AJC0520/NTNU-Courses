# Algoritmer og kompleksitet

### Hva er en algoritme?
En algoritme er en oppskrift på hvordan man løser ett problem, det vil også si at forskjelle oppskrift vil gi forskjellige resultater og forskjellig kjøretid. Et algoritmevalg kan mange ganger være viktigere enn både språk og maskinvare.

### A[1] - Pseudokode-konvensjoner
Pseudokode er en forenklet kode som viser ideen, uten syntaksregler. 

### A[2] - RAM-modellen
RAM = Random-Access Machine
Dette er en forenklet modell av en datamaskin som brukes for å analysere algoritmer. 
Man antar følgende:
- Alle elementære operasjoner (addisjon, sammenligning, tilgang til array-element) tar konstant tid: O(1)
- Vi har uendelig minne (teoretisk)
- Vi kan lese/skrive hvor som helst på minnet på konstant tid.

### A[3] Problem, instans, problemstørrelse
Problem: En genrell oppgave vi vil løse
- Feks: sortere en liste
Instans: En konkret utgave av problemet
- Feks: [4,2,9]
Problemstørrelse (n): hvor stor instansen er:
- For sortering: antall elementer i lista.

### A[4] Asymptotisk notasjon - O, Ω, Θ, o og ω
Big-O: O(f(n))
- En øvre grense
- Algoritmen er ikke tregere enn f(n)
- "Max så dårlig"

Big-Omega: Ω(f(n))
 - En nedre grense
 - Algoritmen er ikke raskere enn f(n)
 - "Max så bra"

Big-Theta: Θ(f(n))
- Stram grense
- Både O og Ω gjelder
- "Eksakt vekst"

Liten-o: o(f(n))
- Streng øvre grense
- Vokser mye mindre enn f(n)

Liten-omega: ω(f(n))
- Stram nedre grense
- Vokser mye mer enn f(n)


### [A5] Best-, average- og worst-case
### [A6] Alle O, Ω, Θ, o, ω kan brukes for alle cases
Man kan si:
- “Worst-case er O(n²)”
- “Worst-case er Ω(n)”
- “Best-case er O(n²)”
- “Average-case er O(n²)”

Fordi O og Omega beskriver grenser, ikke cases, kan de brukes for alle casene. En øvre grense sier ingenting om hvor tiden ligger, kun at den ikke kan være verre enn grensen.

### [A7] Insertion-Sort
[[Algoritmer i pensum TDT4120]]




