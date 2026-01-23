# Grådige algoritmer
Grådige algoritemer, gjør ett valg av gangen, hver gang det ser best ut "akkurat nå". 

### G1 - Designmetoden grådighet

1. Definer problemet
2. Finn et grådig valg (beste umiddelbare valg)
3. Bevis to ting:
	1. Optimal delstruktur
	2. Grådighetsegenskapen
4. Velg grådig valg, reduser problemet og gjenta

Forskjellen fra DP er at DP prøver alle valg og lagrer de beste, grådighet tar ett valg og håper det er riktig.

### G2 - Grådighetsegenskapen
Det finnes en optimal løsning der det første valget er det grådige valget.

Vi mister ikke muligheten til å være optimale av å ta det grådige valget først.

Ved siden trenger vi også optimal delstruktur.

### G3 - Aktivitetsutvelgelse og Kontinuerlig ryggsekkproblem

Aktivitetsutvelgelse
Man har aktiviteter med start og slutttid. Velg flest mulig som ikke overlapper.

Strategien er å velge aktiviteten som alltid slutter først.

Det er fordi:
- Det finnes alltid en optimal løsning der første aktivitet er den med tidligst slutt.
- Deretter løser man resten iteraitvt/rekursivt

O(n log n)

Kontinuerlig ryggsekkproblem:
Forskjellen fra vanlige problemet er at man kan ta deler av en gjenstand.

Løsningen er å alltid velge gjentanden med høyest verdi per vekt først.

Dette fungerer fordi:
- Optimal delstruktur
- Grådighetsegenskapen holder
- Ingen diskrete 0/1 bebgrensinger

O(n log n)

### G4 Huffman-koder
Gitt frekvenser for symboler skal man lage en prefixfri binærkode med minimal forventet lengde.

1. Tell antall forekomster av hver symbol
2. velg de to symbolene med lavest frekvens
3. slå sammen til en node
4. sett som barna av en ny node med frekvens = sum
5. gjenta til man har ett tre

Det funker fordi alltid en optimal løsning hvor de to minst frekvente symbolene er bladsøsken på maks dybde.
Grådighetsegenskapen ^^

O(n log n) med min-heap


