
### Utnyttelse av parallellitet 
Det er enklere å utnytte parallellitet mellom uavhengige programmer enn innad i ett program

Uavhengige program:

- Når flere uavhengige programmer eller oppgaver kjører samtidig, krever de lite eller ingen koordingering, synkronisering eller kommunikasjon.
- Feks: En web-server som betjener forespørsler fra uavhengige brukere, eller en server som kjører en epostserver og en filserver samtidig.
- Uavhengige programmer kan kjøres på parallelle maskiner som klynger uten at maskinvaren trengte å tilby avansert cache-koherens.

Innad i et program:
Å få ett enkelt program til å utføres raskere ved hjelp av flere prosessorer er vanskeligere fordi det krever at programmet må omskrives for å utnytte parallelliteten eksplisitt

1. Ekstra kompleksitet, parallell programmering øker vanskelighetsgraden, programmet må ikke bare være korrekt, men det må også være raskt.
2. For å oppnå hastighetsøkning må oppgaven deles inn i like store parallelle deler, slik at alle prosessorer får omtrent like mye å gjøre. Hvis en del tar lengre tid enn de andre, reduseres fordelene med parallellitet.
3. Paralleliserte deler av et program må ofte kommunisere og synce for å vite når de skal lese eller skrive delte resultater. Overforbruket av tid på kommunikasjon og synkronisering kan redusere den potensielle ytelsen drastisk.


### Bruk av amdhals lov for å analysere skalerbarheten til parallelle programmer
Analysere den potensielle ytelsesforbedringen når bare en del av systemet forbedres eller paralleliseres.

Slår fast at ytelsesforbedringen som er mulig med en gitt forbedring er begrenset av hvor mye den forberede funksjonen brukes

For parallelle programmer er den upåvirkede delen av utførelsestiden den sekvensielle delen av programmet.

Hvis bare en liten brøkdel av et program forblir sekvensiell, beregner denne delen den totale oppnåelige hastighetsøkningen, uansett hvor mange prosessorer som legges til.

Særlig viktig når man vurderer skalerbarheten til systemer med mange prosessorkjerner. FOr å oppnå betydelig akselerasjon med et stort antall prosessorer, må den sekvensielle delen av programmet være ekstremt liten.


### Sterk skalering og svak skalering
Skalering beskriver hvordan ytelsen til et parallelt program endres når antall prosessorer øker.

sterk:
- Måler hastighetsøkningen når problemstørrelsen holdes fast, samtidig som antall prosessorer øker
- Begrenset av amdhals lov. Siden den sekvensielle delen av programmet forblir konstant mens den parallelle delen akseleres, kan selv små sekvensielle deler beregne den totale oppnåelige hastighetsøkningen betrakelig, spesielt når antall prosessorer er stor.


svak
- Måler hastighetsøkning når problemstørrelsen øker proposjonalt med økningen i antall prosessorer
- Letter å oppnå. Relevant når hovedårsaken til å kjøpe raskere maskiner er å løse større problemer. Mange vitenskapelige og kommersielle applikasjoner som databaser velger svak skalering, da det er mer realistisk å anta at arbeidsmengden øker med ressursene.

### Flynns taksonomi

1. Single instruction, single data (SISD)
	En enkel prosessor som utfører en enkel instruksjonsstrøm på en enkelt datastrøm. (Intel Pentium 4)
2. Single instruction, multiple data (SIMD)
	Samme instruksjon brukes samtidig på flere datastrømmer. Prosessoren opererer på vektorer av data. Garfikkort bruker simd prinsipper
3. Multiple instruction, multiple data (MIMD)
	Flere prosessorer utfører uavhengige instruksjonsstrømmer på separate datastrømmer. Standard for moderne multi-kjerne prosessorer. (Intel Core I7)
4. Multiple instruction single data. (MISD)
	Finnes sjeldent i dag. Kunne vært en strømprosessor som utfører en sekvens av beregninger på en enkelt datastrøm i en pipelinet mote.


### Roofline-modellen og operasjonsintensitet
Aritmetisk intensitet er definer som forholdet mellom antall flyttallsoperasjoner i et program og antall databyte som aksesseres fra hovedminnet,

Roofline-modellen er som å vurdere hastigheten du kan kjøre bil. Den er begrenset av enten **motorens kraft** (beregningsbundet) eller **veiens kapasitet** (minnebundet). Hvis du kjører på en trang, svingete vei (lav aritmetisk intensitet), hjelper det lite å ha en sterk motor – du er begrenset av veien. Hvis du kjører på en rett motorvei (høy intensitet), vil du utnytte motorens fulle kraft.

### Delt minne vs distribuert minne

MIMD-maskiner er klassifisert etter om de har en delt fysisk adresseplass eller private adresserom.

Delt minne multiprosessorer
- Gir programmeren en enkelt, felles fysisk adresseplass som alle prosessorer kan aksesseres. Den klassiske organiasasjonen involverer flere prosessorer, hver med sin egen cache, koblet til et felles minne vita et samkoplingsnettverk. Moderne er nesten alltid dette.

	- Slipper å bekymre seg for hvor data er plassert, alle variabler er tilgjengelige for enhver prosessor
	- Kommuniserer implisitt gjennom felles variabeler li minnet
	- vis latenstiden til minnet er lik for alle prosessorer, kalles det UMA (_Uniform Memory Access_). Hvis latenstiden varierer avhengig av hvilken prosessor som ber om data, kalles det NUMA (_Nonuniform Memory Access_)

	- Krever maskinvarestøtte for cache-koherens for å sikre at alle prosessorer har et konsistent syn på minnet.
	- Vanskeligere å programmere, og ytelsen kan være sensitiv for dataplassering
	
Distribuert minne multiprosessorer
- Hver prosessorer har sitt eget private fysiske adresserom og sin egen lokale hukommelse. Kommunikasjon skjer via meldinger hvor en prosessor sender en melding og den andre mottar den

	- Krever ikke kompleks maskinvare for cache koherens
	- Mye enklere å bygge store systemer
	- Ved feil på en server er det enklere å isolere og erstatte den uten å krasje hele systemet.

	- Porting av sekvensielle programmer er vanskeligere fordi all komm må være eksplisitt identifisert
	- Komm over nettverket har høyere latens og lavere båndbredde sammenlignet med det raske minneinterconnectet.

### Flerkjerneprosessorarkitektur
En flerkjerneprosessor er en enkelt integrert krets som inneholder flere prosessorer(kjerner)

Arkitekturen er en delt minne multiprosessor hvor alle kjernene deler en enkelt fysisk adresseplass

Skiftet fra enkeltprosessorer til flerkjernearkitektur skyldtes primært to faktorer som begrenset ytelsesøkningen

1. Power wall. Å øke klokkehastigheten til enkeltprosessorer førte til uholdbart høyt strømforbruk og varmeutvikling
2. Ahmdals lov, ble vanskeligere å finne og utnytte mer instruksjonsnivåparallellitet i enkelttråder.

Ved å bruke flere enklere, mer energieffektive kjerner kan brikken oppnå høyere samlet ytelse og bedre ytelse per Joule, forutsatt at programvaren kan utnytte paralleliliteten


### Synkronisering
 Nødvendig for å koordinere oppførselen til parallelle prosesser eller tråder som deler data, for å sikre at ops utføres i riktig rekkefølge og for å unngå data races. Hvis tråder ikke synkroniseres kan resultatet av programmet bli uforutsigbart.

Synkronisering implementeres ofte ved hjelp av låser som sikrer at bare en prosessor får eksklusiv tilgang til en delt ressurs om gangen. Låser implementerer ved hjelp av spesielle atomiske maskinvareprimitiver som garanterer at les og skriv operasjon til et minnsted skjer uten at noen annen operasjon kan komme imellom.

lr.w, leser verdien i et minnsted
sc.w, forsøker å skrive en ny verdi til samme adresse, men lykkes kun hvis ingen annen prosessor har endret innholdet i minnesteden siden lr.w ble utført.

Paret av instruksjoner kan brukes til å  bygge enkle synkroniseringsoperasjoner som atomisk bytte.


### Cache-koherens
Nødvendig i multiprosessorsystemer med delte adresser og private cacher for å sikre at alle prosessorer har et konsistent syn på delt minne. Uten kan forskjellige prosessorer ende opp med ulike verdier for den samme minnelokasjonen

Koherent hvis:
1. Lesing av en prosessor P etter en skriving av P til samme lokasjon alltid returnerer verdien skrevet av P
2. En lesing av en prossesor som følger en skriving av en annen prosessor returnerer den skrevne verdien, gitt at de er tilstrekkelige i atskilt tid
3. Skrivninger til samme lokasjon serialiseres, slik at alle prosesser ser skrivningen i samme rekkefølge.

Snooping løser.
Hver cache som har en kopi av en minneblokk har også en kopi av blokkens delingstilstand. Alle cache kontrollere overvåker den felles kommunikasjonsbussen eller nettverket for å se om de har en kopi av en forespurt blokk
**Write Invalidate Protocol:** Den vanligste typen koherensprotokoll er _write invalidate_ (skrive-ugyldiggjøring).

    ◦ Når en prosessor ønsker å skrive til en delt blokk, må den først få **eksklusiv tilgang**.

    ◦ Den sender en **ugyldiggjøringsforespørsel** (_invalidation_) over bussen.

    ◦ Alle andre cacher som har en kopi av blokken, **ugyldiggjør** sin kopi (setter valid bit til 0).

    ◦ Når en annen prosessor senere prøver å lese blokken, resulterer det i en cache miss, og den henter den oppdaterte verdien.

### Minnekonsistensproblemet
Definerer nøyaktig når en skrevet verdi må sees av andre prosessorer, i motsetning til cache-koherens som definerer hvilke verdier som kan returneres.

Når prosessorer kjører uavhengig, er det viktig å sikre at programtilstanden opprettholdes

1. **Skriving til Minne:** En skriving anses ikke som fullført før **alle** prosessorer har sett effekten av skrivingen. Dette sikrer at endringer til slutt blir synlige over hele systemet.

2. **Programrekkefølge:** En prosessor må ikke endre rekkefølgen av skrivinger i forhold til andre minneaksesser.

Disse to begrensningene sikrer at hvis en prosessor skriver til adresse X, og deretter til adresse Y, vil enhver annen prosessor som ser den nye verdien av Y, også se den nye verdien av X. Dette opprettholdes ofte ved hjelp av **minnebarrierer** (_memory barriers_ eller _fences_). For eksempel bruker RISC-V `fence`-instruksjonen for å sørge for synkronisering av dataminneaksesser for flerkjerneprosessering