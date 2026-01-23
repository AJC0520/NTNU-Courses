### Lokalitet i Tid og Rom
Lokalitetesprinsippet er grunnlaget for minnehierarkier og sier at programmer aksesserer en relativt liten del av sitt adresseområde til enhver tid.

To typer:

Lokalitet i tid:
- Hvis en dataenhet nylig har blit aksessert, er det sannsynlig at den vil bli aksessert igjen snart
- Programmer inneholder ofte løkker så bade instruksjoner og data aksesseres gjentatte ganger. Minnehierarkier utnytter lokalitet i tid ved å holde nylig aksesserte dataenheter nærmere prosessoren.

Lokalitet i rom:
- Hvis en dataenhet blir aksessert, er det sannynslig at dataenheter med nærliggende adresser vil bli aksessert snart.
- Instruksjoner aksesseres sekvensielt, noe somviser høy lokalitet i rom. Utnyttes ved å flytte blokker som består av flere sammenhengede ord til de øvre nivåene av hierarkiet.

### Minnehierarkiet og illusjonen om stor og raskt minne
Man ønsker gjerne at minnet skal være raskt, stort og billig. Men disse kravene er i konflikt. Løses ved minnehierarki

Består av flere nivåer av minne med ulik hastighet og størrelse. Nærmest prosessor ligger minnet som er raskest, men dyrest per bit som SRAM, mens nivåene lengre unna er tregere og billigere som DRAM.

Målet med hierarkiet er å gi brukeren illusjonen av et minne som er like stort som det største nivået i hierarkiet, men som kan aksesseres nesten like raskt som det raskeste nivået.

Utnyttes ved lokalitet, nivåer nærmere prossesoren er en delmengde av nivåene lengre unna. Ved høy treffrate i de raske øvre nivåene blir den gjennomsnittlige aksesseringstiden bestemt hovedsaklig av trefftid, som er svært lav.

### Direkte tilordnet hurtigbuffer

![[Pasted image 20251204154921.png]]

Direkte tilordnede hurtigbuffere er den enkleste formen for cache-organisasjon, hvor hver minneblokk har kun ett spesifikt sted den kan plasseres i cachen.

1. Indeksering: Minneadressen deles inn i tre felt. Tag, indeks og offset

	Indeks feltet brukes til å velge nøyaktig ett cache-sett

2. Hver cacheblokk har en gyldighetsbit som indikerer om innholdet i blokken er gyldig data eller ikke
3. Tag feltet inneholder den delen av adressen som trengs for å identifisere om blokken i cachen faktisk tilsvarer den forespurte minneadressen
4. Ved en lesing sjekkes indeks for å finne blokken, gyldighetsbiten sjekkes og tag-feltet i cachen sammenlignes med tag feltet i den forespurte adressen. Hvis de amtcher så er det en hit.

Utvidelse til blokker med mer enn ett ord.
Cache-blokker består ofte av flere ord for å utnytte lokalitet i rom.
- Hvis blokkstørrelsen er 2^m ord brukes m bits av adressen til å peke på ordet innenfor blokken pluss to bits for å peke på byten.
- Den totale størrelsen på tag-feltet beregnes ut fra den totale adressebredden, minus antall bits brukt for indeks, ord innenfor blokk og byte-offset
- Større blokkstørrelser kan redusere missraten for en stor rekke blokkstørrelse på grunn av lokalitet i rom, men kan også øke straffen ved en miss og potensielt øke missraten hvis blokkene blir for store.

### Integrasjon av hurtigbuffere i samlebåndsarkitektur.

I en samlebåndsprosessor behandles cache-aksesser i de separate stegene

Instruksjons-cache brukes i IF-steget for å hente instruksjoner
Data-cache brukes i MEM-steget for å lese eller skrive data
Integrasjonen krever at cachen kan håndtere stalls og exceptions. Ved en cache miss må prosessoren stanses til minnet svarer med dataene

En ulempe med enkelte integrasjoner er antall minefeil, som en sidefeil i det virtuelle minne, kan føre til at pipelinen må håndtere unntak.


### Håndtering av skriveoperasjoner
Mer kompleks en lesing, siden det kan føre til at cachen og hovedminnet blir inkonsistense

1. Write-through
	- Skriver alltid dataen til både cachen og det neste lavere nivået i minnehierarkiet
	- Sikrer at data alltid er konsistense mellom cachen og hovedminnet
	- Skriveraten fra prosessoren er ofte raskere enn minnesystemet kan håndtere. Derfor brukes ofte en skrivebuffer, som er en kø som holdet data mens de venter på å bli skrevet til minnet, for å redusere ytelsesstraffen.

2. Write-Back
	- Oppdater verdien kun i cache-blokken. Den modifiserte blokken kopieres tilbake til det lavere nivået først når blokken erstattes.
	- Krever en dirty bit som indikerer at blokken er modifisert og må skrives tilbake til minnet.
	- Er vanligvis nødvendig for virtuelle minnesystemer på grunn av den lange forsinkelsen ved å skrive til disk. I dag bruker typisk lavere nivå av cache, write-back.

### Beregning av minneaksesstid og ytelsespåvirkning.
Minnesystemet har en signifikant effekt på programmets uførelsestid

Ytelsen måles ved hjelp av Gjennomsnittlig minneaksesstid
AMAT = Tid for treff + Missrate x Miss straff

Påvirkning på CPU-ytelse
Minnefeil øker programmets cpi ved å legge til ekstra minne-stantsykluser

### Treffrate i flernivå hurtigbuffer
- Flernivåcacher brukes til å redusere miss penalty
- Lokal missrate er brøkdelen av aksesser til ett nivå i cachen som misser
- Global missrate er brøkdelen av referanser som misser i alle nivåer av en flernivåcache.

Den gjennomsnittlige minneaksesstiden for et to-nivå hierarki er
HittimeL1 + missrateL1 x misspenaltyL1

![[Pasted image 20251204165540.png]]
For multilevel caches er det ofte slik at L1 cacher prioritere lav trefftid, mens lavere nivåer prioriterer lav missrate.

### Setassosiative og fullassosiative hurtigbuffere

Å øke assosiativiteten reduserer vanligvis missraten

Settassosiativ
- En blokk kan plasseres i et fast antall lokasjoner (minst 2) kalt et sett. En n-veis settassosiativ cache består av sett og hver minneblokk tilordnes et unikt sett, men kan plasseres i hvilket som helst element i det settet.
- En settassosiativ cache bruker indeks for å velge settet og krever deretter paralelle sammenligninger av taggene til alle blokkene i det valgte settet for å finne et treff. Økt assosiativitet øker antall parallelle sammenligninger som trengs og øker typisk tiden.

Fullassosiativ cache
- En blokk kan plasseres i hvilken som helst lokasjon i cachen
- En fullassosiativ cache har bare ett sett. Hele adressfeltet, forutenom blokk-offset, sammenligner med taggen til hver eneste blokk i cachen parallelt.
- Full assosiativitet reduserer konfliktmisser som oppstår når flere blokker konkurrerer om samme sted i cachen til null.

### Programvarepåvirkning på treffraten i hurtigbuffere
Programmerere kan ha stor innvirkning på ytelsen ved å ta hensyn til minnehierarkiet og justere algoritmer for å bedre lokalitet i tid og rom.

Cache blokking, er en viktig programvareoptimalisering spesielt for matriseoperasjoner med store arrays -> I stede for å behandle hele matries sekvensielt deles amtrisene inn i mindre blokker. Beregningene fullføres for en blokk før man går videre til neste

Dette utnytter en kombinasjon av lokalitet i tid og rom, slik at data kan gjenbrukes effektivt mens de er i cachen, og dermed redusere missraten.

Utrulling av løkker, Kompilatorer kan omorganisere løkker for å øke dataflyten og utnytte cachen bedre. Ved å sikre at datastrukturer lagres i minnet slik at de aksesseres sekvensielt i henhold til programmets fly, øker lokalitet i rom og treffraten forbedres.

Det er en fallgruve å ignorere minnesystemets oppførsel ved koding, da ytelsen lett kan dobles ved å inkorpere minnehierarkiets adferd i algoritmedesign.


### Volatilt og ikke volatilt minne, statisk og dynamisk minne

Volatilt minne mister data hvis de mister strøm. DRAM er eksempel
Ikke-volatilt  beholder data selv uten strømtilførsel. Flash-minne

Statisk minne (SRAM). I statisk ram lagres verdien i en celle ved hjelp av et par inverterende porter, og verdien beholdes så lenge strøm er tilført. SRAM trenger ikke periodisk oppdatering, og har derfor en tilgangstid som er svært nær syklustiden.

Dynamisk minne (DRAM). I dynamisk ram lagres verdien som en ladning i en kondensator og en enkelt transistor brukes for tilgang. Fordi ladningen i kondensatoren ikke kan beholdes på ubestemt tid, må dram cellene periodisk oppdateres ved å lese innholdet og skrive det tilbake.

### Omtrentlig aksestid og kostnad for minneteknologier

| Minnetek       | Typisk aksesstid  | Kostnad per GiB | Volatilitet   | Bruk i hierarkiet                 |
| -------------- | ----------------- | --------------- | ------------- | --------------------------------- |
| SRAM           | 0.5-2.5ns         | 500-1000        | Volatilt      | Cacher                            |
| DRAM           | 50-70ns           | 3-6             | Volatilt      | Hovedminne                        |
| Flash          | 5k-50k ns         | 0.06-0.12       | Ikke-volatilt | Sekundærlager                     |
| Magnetisk Disk | 5mill - 20mill ns | 0.01-0.02       | Ikke-volatilt | Skeundærlager i tjenere (servers) |

Minnehierarkiet er strukturert for å gi brukeren en illusjon av et minne som er like stort som det største nivået, men som kan aksesseres nesten like raskt som det raskeste nivået. Denne strukturen utnytter lokalitet ved å flytte data mellom nivåer.

### Konstruksjon av SRAM minne
![[Pasted image 20251205115354.png]]

En registerfil kan implementeres med D-flip-flops. Større mengder minne bygges ved hjelp av DRAM-er


SRAM:
I stedet for en gigantisk multiplekser, bruker et sett med tristate-buffere, som deler felles utgangslinje

Disse bufferene har en datautgang som enten er sann. usann, eller i en høyimpedans-tilstand, som lar en annen buffer drive linjen. Ved å bruke disse SRAM cellene kan flere celler dele den samme utgangslinjen.

4x2 SRAM^^
En dekoder brukes til å velge hvilke celler som skal aktiveres. De aktiverte cellene bruker tristate-utgangen koblet til de vertikale bitlinjene for å levere de forespurte dataene. Adressen sendes langs horisontale ordlinjer. For større minner brukes ofte to-trinns dekoding i stedet for en stor sentralisert dekoder for å redusere kompleksiteten.

### Konstruksjon av DRAM minner
Lagrer data som ladning i en kondensator.

En DRAM-celle består av en kondensator som lagrer ladningen (verdien) og en bryter som brukes for tilgang til cellen
![[Pasted image 20251205120401.png]]
- Når signalet på ordlinjen settes høyt, lukkes transistoren og kobler kondensatoren til bitlinjen
- Verdien som skal skrives plasseres på bitlinjen og ladningen på kondensatoren justeres deretter
- Ved lesing lades bitlinjen først til en halvspenning. Når ordlinjen aktiveres, endres spenningen på bitlinjen litt basert på ladningen i kondensatoren. Dette detekteres og forsterkes av en føleforsterker
![[Pasted image 20251205121152.png]]

For å spare pinner og redusere kostnad, bruker DRAM to-nivå adressering

### Virituelle adresser og oversettelse til fysiske adresser
Virituelt minne er en teknikk der hovedminnet fungerer som en cache for sekundærlagringen. Hovedformålet er å tillate trygg og effektiv deling av minne mellom flere programmer

Adresseoversettelse:
Prosessen med å oversette virtuelle adresser til fysiske adresser kalles adresseoversettelse:
1. Virtuelt minne deler både det virtuelle og det fysiske minnet inn i faste blokker kalt sider
2. En virtuell adresse deles inn i et virtuelt sidetall og en sideforskyvning. Sideforskyvningen endres ikke under oversettelsen
3. Oversettelsen implementeres ved hjelp av en sidetabell som befinner seg i hovedminnet. Hvert program har sin egen sidetabell.
	1. Sidetallen indekseres med det virtuelle sidetallet for å finne det tilsvarende fysiske adressen
4. For å redusere mengden hovedminne som brukes til å lagre sidetabeller, kan man bruke flernivås sidetabeller. For eksempel bruker RISC-V to nivåer for å oversette en 32-biters virtuell adresse.

Adresseoversettelsen er et samarbeid mellom maskinvaren og operativsystemet.

Maskinvare:
- Aksesseres på hver minnereferanse for rask oversettelse. Sjekker tilgangsrettigheter, via bits i TLB-oppføringen. Stiller inn referansebiten og dirty bit ved aksess. Håndterer TLB-misser ved å forsøke å laste inn oversettelsen fra sidetabellen.

Programvare:
- Håndterer sidefeil ved å finne siden på sekundærminnet og velge side for utskifting. Allokeler og oppdaterer sidetabellene og fysisk minne. Velger side for erstatning. Styrer minnebeskyttelse og prosessbytte.

### Translation Lookaside Buffer (TLB)
Spesiell maskinvarecache som lagrer nylig brukte adresseoversettelser for å unngå å måtte aksessere sidetabellen i hovedminnet på hver referanse.

Uten TLB måtte hver programminneaksess kreve minst to minneaksesser, en for å hente den fysiske adressen fra sidetabellen og en for å hente selve dataen. TLB fungerer som et cache for sidetabellen og lagrer det virtuelle sidetallet og det tilsvarende fysiske sidetallet (som data)

TLB-er er ofte lite og kan være fullt assosiative for oppnå en lav missrate siden kostnaden for parallell søking er overkommelig for en så liten struktur.

TLB-oppføringer inkluderer statusbiter som dirty bit og reference bit samt tilgangsrettighetsbiter som bruke for beskyttelse.


### Virtuelt minne for beskyttelse
Beskytte prosesser fra hverandre når de deler samme hovedminnet

Hver prosess har sitt eget virtuelle adresseområde, definert av sin unike sidetabell. OS sikrer at alle disse sidetabellene kartlegger til atskilte fysiske sider slik at en prosess ikke kan aksessere en annens data uten tillatelse.

Moduser hvor sensitive instruksjoner kun er tilgjengelige i supervisor-modus
Kontrollbiter i sidetabellene og TLB-ene som angir om en side kan leses eller skrives til. Disse kan kun endres av OS i supervisor-modus

Sidetabellene er plassert i OS beskyttede adresseområde, slik at brukerprosesser ikke kan endre kartleggingen.

### Håndtering av sidefeil
- En sidefeil er en hendelse som oppstår når en forespurt virtuell side ikke er til stede i hovedminnet (kun i sekundærminnet). -> TLB-miss som er fulgt av oversettelsen i sidetabellen har en ugyldig bit. Håndtering av sidefeil er kostbart, da det involverer aksessering av disk som kan ta millioner av klokkesykluser.

1. Overfør kontroll. Prosessoren bruker unntaksmekanismen for å overføre kontrollen til operativsystemet. Den lagrer adressen til instruksjonen som forårsaket feilen i et register SEPC.
2. Finn side: OS finner den refererte siden i sekundærminnet
3. OS velger en fysisk side i hovedminnet som skal erstattes, ofte basert på en tilnærming av LRU ved hjelp av referansebiten.
4. Hvis siden som skal erstattes har dirty bit satt, må den skrives tilbake til sekundærminnet
5. Os starter en lesing for å hente den refererte siden fra sekminne til den valgte fysiske siden
6. Siden diskaksessen er treg, vil OS ofte la en annen prosess kjøre i mellomtiden. Når lesingen er fullført, gjenopptar OS den avbrutte prosessen ved å bruke instruksjonen for retur fra unntak (**sret** i RISC-V), som gjenoppretter **PC** (programtelleren) og fortsetter utførelsen av instruksjonen som feilet


### Forklaring av virtuell maskin
En programvareabstraksjon som gir brukeren illusjonen av å ha en hel del datamaskin til rådighet, inkludert en kopi av OS

VM-er er presenterer et komplett systemnivåmiljø på det binære instruksjonssetarkitektur-nivået. En enkelt fysisk datamaskin kan kjøre flere VM-er som deler maskinvareressursene

Virtual machine monitor er ansvarlig for å kontrollere maskinvareressursene og må kjøre på et høyere privelegienivå enn gjeste-os for å opprettholde isolasjon og beskyttelse.

VM er viktig for:
- Isolasjon og sikkerhet: Beskytter brukere fra hverandre når de deler samme server.
- Konsolidering: Lar flere uavhengige programvarestabler kjører på en fysiske server, noe som reduserer maskinvareantallet.



