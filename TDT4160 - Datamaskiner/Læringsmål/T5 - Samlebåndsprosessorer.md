
|                                  | Enkeltsykel                                                               | Flersykel                                           | Samlebånd                                                                                                        |
| -------------------------------- | ------------------------------------------------------------------------- | --------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Klokkesyklustid                  | Lang. Bestemmes av lengste instruksjonsbane                               | Kort. Bestemmes av det lengste individuelle steget. | Kort. Bestemmes av det lengste pipelinesteget, likt flersykeldesign                                              |
| Gjennomstrømning                 | Lav. Kun en instruksjon fullføres per klokkesyklus, men syklusen er lang. | Høyere enn enkeltsykel, da syklusen er kortere.     | Høyest. Øker gjennomstrømningen ved å lage flere instruksjoner overlappe i utførelse                             |
| CPI                              | Alltid 1                                                                  | Variabel. Kortere instruksjoner fullføres raskere   | Ideelt sett 1, men øker på grunn av farer.                                                                       |
| Datasti                          | Høy kostnad. Krever dupliserte funksjonelle enheter.                      | Lav kostnad. Gjenbruker funksjonelle enheter.       | Høy kostnad. Ligner enkeltsykel, men krever pipelineregister mellom hvert steg for å lagre midlertidig tilstand. |
| Ytelse for en enkelt instruksjon | Lang, lig klokkesyklustiden                                               | Lang, summen av stegene                             | Lang, lik summen av stegene                                                                                      |

Hovedfordeler:
- Høyere klokkerate. Bestemmes av tiden til det lengste individuelle steget (feks 200ps) isteden for hele instruksjonsutførelsen (feks 800ps)
- Pipelineing øker ytelsen med å øke throughput, selv om utførelsestiden for en individuell instruksjon forblir høy.
- Høy utnyttelse. Ved å holde alle pipelinestegene opptatt, utnyttes maskinvaren bedre.

### Hvordan oppstartskostnad og balanse mellom steg påvirker ytelse.

Ytelsen til en prosessor måles i CPU-tid, som er produktet av instruksjonstelling, sykluser per instruksjoner og klokkesyklustid.

Oppstartkostnaden er tiden det tar før samlebåndet er fullt. Dette påvirker ytelsen når det totale antallet instruksjoner er lite.

Pipelineing gir først optimal ytelsesforbedring når det er nok arbeid til å holde alle stegene opptatt. I et fire-stegs samlebånd som tar 30 minutter per steg tar fire lass 3.5timer i pipeline-versjon, mens i den tar 8 timer i en sekvensiell versjon. For bare fire lass er forbedringen mindre enn det ideelle fire ganger raskere.

Amdahls lov: For et stort antall instruksjoner, blir forholdet mellom total utførelse i ikke-pipelined vs pipelined nærmere det idelle teoretiske forholdet.

Balanse mellom steg:
Klokkesyklustiden til en samlebåndsprosessor bestemmes av tiden som kreves av det lengste steget. For å oppnå den maksimale teoretiske ytelseforbedringen, må stegene i samlebåndet være perfekt balansert. Ideelt sett er hastighetsforbedringen lik antallet steg i samlebåndet. 

Hvis stegene ikke er balansert, må klokkesyklusen forlenges for å imøtekomme det tregeste steget. Dette øker klokkesyklustiden for alle instruksjoner, og dermed reduseres ytelsen i henhold til ytelsesformelen.

### Avhengigheter vs farer

Avhengigheter er logisk programmeringsmessig egenskap, mens farer er et implementeringsproblem som hindrer optimal pipelinet utførelse.

Avhengighet: En relasjon der en instruksjon må bruke et resultat som produserers av en tidligere instruksjon i programmet. Dette er en egenskap ved selve koden. Et eksempel er en sann dataavhengighet, der en instruksjon skriver til et register som den neste instruksjonen leser fra.

Fare: Oppstår når en instruksjon ikke kan utføres i den tiltenkte klokkesyklusen på grunn av at pipeline-implementeringen ikke støtter den nødvendige instruksjonskombinasjonen, enten på grunn av ressurskonflikter eller manglede data. Farer er altså et resultat av avhengigheter og eller begrensninger i maskinvaren.

Tre grupper:
**Strukturfarer**: Oppstår når maskinvaren ikke kan støtte kombinasjonen av instruksjoner som skal utføres i samme klokkesyklus.
- Hvis vi bare hadde ett minne som skulle brukes til å hente både instruksjoner (IF) og data (MEM-steget) i samme syklus, ville det oppstå strukturfare.

**Datafarer:** Oppstår når pipelinen må stanses fordi en instruksjon er avhengig av data som ennå ikke er tilgjengelige fra en tidligere instruksjon som fortsatt er i pipelinen.
- Vanligste type er RAW (read after write), der en instruksjon prøver å lese et register før en tidligere instruksjon har skrevet det.

**Kontrollfarer:** Oppstår når den neste instruksjonen som skal hentes ikke er den korrekte instruksjonen, fordi beslutningen om en betinget forgrening skjer sent i pipelinen.

### Strategier for å håndtere farer
1. Unngåelse.
	- Gjøres av kompilatoren, som omorganiserer koden for å plassere uavhengige instruksjoner mellom avhengige instruksjoner for å unngå eller redusere faren.
2. Videresending
	- Legger til ekstra maskinvare som henter de manglende dataene tidlig fra interne buffere (pipelineregistrene) i stedet for å vente på at dataene som skrives til registerfilen i WB-steget.
3. Stans
	- Setter en boble eller en NOP instruksjon, i pipelinen. Forsinker instruksjoner som kommer bak i pipelinen til faren er løst. Bør unngå så langt som mulig.
4. Prediksjon
	- Gjetter utfallet av en betingen forgrening og fortsetter utførelsen basert på denne antagelsen. Hvis gjetningen er feil, må pipelinen flushes for de feilhentede instruksjonene.

### Grunnleggende mikroarkitektur til 5-stegs samlebåndsprosessor

fem like lange steg.
- Instruction Fetch, henter instruksjon fra instruksjonsminnet og øker PC
- Instruction decode, dekoder instruksjonen og leser to registeroperander fra registerfilen
- execution ufører alu operasjonen eller beregner minneadressen
- MEM, aksesserer dataminnet
- WB skriver resultatet tilbake til regfil

Fire registre er plassert mellom hvert steg. Kritisk for å lagre all informasjon.


### Implementering av kontroll
Kontrollenheten er enklere enn i en flersykelprossesor fordi den ikke trenger en tilstandsmaskin.
1. Kombinasjonell kontroll: Kontrollsignalene bestemmes av instruksjonens opcode i ID-steget
2. Siden hvert kontrollsignal er knyttet til en funksjonell enhet i et spesifikt steg, må de nødvendige kontrollsignalene sendes fremover gjennom pipelinen sammen med dataene.
3. Gruppering av kontrollsignaler, kontrollinjene er delt inn i grupper basert på hvilke steg de brukes i (EX, MEM eller WB)
	1. EX: (AluOP, AluSRC)
	2. MEM: (Memread,Memwrite)
	3. WB: (RegWrite, MemToReg)
4. PC-registeret og pipelineregistrene oppdateres på hver aktiv klokkekant, og krever derfor ingen separate skrivestyringssignaler.

### Håndtering av datafarer: videresending og stans

Videresending:
Primær løsning for datafarer, og eliminerer behovet for stans i de fleste tilfeller.

Ved å legge til multiplexere på inngangen til ALU-en (i EX steget) og en videresendingsenhet i kontrollenheten, kan data sendes fra utgangen av pipelineregistrene direkte til ingangene til ALU-en i EX-steget.

Siden forwarding kan løse uavhengigheter uten å forsinke instruksjonen, kan pipelinen ideelt sett opprettholde en CPI på 1 syklus per instruksjon.

Stans er nødvendig i tilfeller der forwarding ikke er tilstrekkelig, spesielt ved load-use farer. 

- Load-use: Når en load instruksjon umiddelbart etterfølges av en instruksjon som trenger de leste dataene i sitt EX-steg.

En hazard detection unit i ID-steget oppdager denne situasjonen. Hvis en load-use fare oppdages:
1. Et NOP (boble) settes inn i pipelinen ved å sette alle kontrollsignalene for de følgende stegene til 0.
2. Skrivningen til PC og IF/ID reg blokkeres, slik at IF- og ID- steget gjentar seg selv i neste syklus.

Ulempe på ytelse: Hver stans forårsaket av en load-use hazard legger til minst en ekstra klokkesyklus til CPI for programmet.


### Håndtering av kontrollfarer: stans og prediksjon
Kontrollfarer, forårsaket av betingede forgreninger, må håndteres tidlig for å minimere ytelsestapet.

Stans:
- En enkel løsning for kontrollfarer er å stoppe fetching av nye instruksjoner helt til forgreningen er avgjort.

Kontrollenheten løser forgreningen i EX/MEM-steget. Hvis den venter til dette punktet, må instruksjoner som er hentet i mellomtiden behandles som feilhentete. Dette resulterer i stor straff på CPI, ofte flere tapte sykluser per forgrening, noe som gjør pipelineing lite effektivt.

Prediksjon:
- Foretrekne metoden for å redusere grenstraffen

Predict not taken, anta at grenen ikke tas (alltid), Instruksjonene etter forgreningen fortsatter normalt i pipelinen
- Hvis grenen ikke tas, fortsetter pipelinen med full hastighet uten straff.
- Hvis grenen tas, må instruksjonene som ble feilhentet flushes og PC må erstattes med riktig måladresse. Dette medfører en forsinkelse.

Dynamisk prediksjon reduserer CPI-straff.

### Unntak og avbrudd
Unntak (exceptions) og avbrudd ( interrupts) er hendelser som endrer den normale, sekvensielle flyten av instruksjonsutførelse.

Unntak: Et usynkronisert hendelse som oppstår internt i prosessoren i forbindelse med en spesifikk instruksjon
- Utførelse av en udefinert instruksjon
- Systemkall, som brukes til å kalle operativsystemet fra et brukerprogram.
- Maskinvarefeil eller overflyt under aritmetiske operasjoner
- Sidefeil

Avbrudd: Et unntak som kommer utenfra prosessoren. Vanligbis IO forespørsel eller eksterne systemtilbaketillinger. Noen arkitekturer bruker begrepet interrup for å dekke alle unntak.

Presise unntak:
- Å håndtere unntak i et pipelinet prosessor er utfordrende fordi flere instruksjoner er aktive samtidig.

Et presist unntak er et unntak som alltid er assosiert med den korrekte instruksjonen.
- Krever:
	- Den feilende instruksjonen stoppes i utførelse
	- Alle tidligere instruksjoner i programrekkefølge får fullføre
	- Alle etterfølgende instruksjoner flushes
	- Adressen til den feilende instruksjonen lagres i et register
	- Årsaken til unntaket lagres.
	- Kontrollen overføres til OS ved en spesifisert adresse.

RISC-V og de aller fleste moderne datamaskiner støtter presise unntak


### Implementering av presise unntak
Unntak behandles som en annen form for kontrollfare. Mekanismen ligner på den som brukes for å håndtere tatt forgrening eller load-use farer, men krever at flere steg flushes og at tilstand lagres.

Maskinvareendring og steg:

1. Lagring av tilstand. To spesielle kontrollregistre legges til datastien
	- SEPC (supervisor exception program counter) lagrer adressen til instruksjonen som forårsaket unntaket.
	- SCAUSE: lagrer årsaken til unntaket
2. Oppdagelse og prioritering
	- Unntak oppdages i de ulike pipelinestegene, maskinvaren sorterer unntak slik at den tidligste instruksjonen i programrekkefølge som forårsaket en feil prioriteres
3. Flushing av pipeline (tømming). Når unntaket oppdages utløses spesielle flush-signaler for å hindre at etterfølgende instruksjoner fullføres.
4. Endring ac PC. En ny inngang legges til PC multiplekseren for å tvinge PC counter til å peke på en fast unntaksadresse. 
5. Bevaring av tilstand.

### Prinsippene bak presise unntak i ut-av-rekkefølge prosessorer.

Moderne superskalar-prosessorer utfører instruksjoner ut-av-rekkefølge. De er langt mer komplekse, men presise unntak opprettholdes (prinsippielt hvertfall)

Presise unntak krever at resultatet av operasjonene blir synlig for den programmer-synlige tilstanden i programrekkefølge. 

1. Issue. Instruksjoner hentes og dekodes i rekkefølge
2. Execute: Instruksjoner utføres ut-av-rekkefølge når operandene deres er klare, ved hjelp av reservasjonsstasjoner
3. Resultatene skrives tilbake til registerfilen eller minnet i programrekkefølge.


Analogi:
En presis unntakshåndtering i en samlebåndsprosessor er som en pakkelinje på en fabrikk.

Når en feil oppstår:
1. Stopp feil-pakken og fjerne den
2. La pakker som allerede har passert feilstedet fullføre pakkingen.
3. Kast alle pakker som kommer etter feil-pakken
4. Start en ny prosess fra det punktet feilen ble oppdaget, men uten å ha ødelagt noen av de ferdige pakkene

I en ut-av-rekkefølge prosessor er det mer komplisert, men løses ved at alle ferdige pakker venter i en ventesone. De får bare forlate ventesonen og bli levert i streng rekkefølge. Hvis en feilpakke dukker opp i ventesonens kø, kastes alle pakker som kom inn etter den, selv om de er ferdige, og bare de pakkene som kom inn før feilpakken får levert sitt resultat.

### Utnyttelse av parallellitet i Tid og Rom
I tid:
Temporalt parallellitet utnyttes primært gjennom pipelining. Denne teknikken overlapper utførelsen av flere instruksjoner over tid. Pipelineing er den opprinnelige metoden maskinvaren bruker for å avdekke implisitt parallellitet blant instruksjonene i et program. Ved å dele instruksjonsutførelsen i mindre sekvensielle steg, reduserers klokkesykelen til den lengste individuelle forsinkelsen i et steg. Dette øker gjennomstrømningen, selv om den totale tiden for en enkelt instruksjon forblir den samme. 

I rom:
Bruke flere fysiske maskinvareenheter.
Multicore/multiprocessing. Bruken av flerkjerneprosessorer utnytter parallelitet i rom ved at flere uavhengige kjerner kan utføre uavhengige tråder eller prosesser samtidig.

Multiple issue. Prosessoren lanserer flere instruksjoner i en klokkesyklus.

Subword parallelism /SIMD, dele opp et bredt databehandlingsord i mindre sub ord og utfører den samme operasjonen på alle dise mindre dataelementene samtidig.


### RAW, WAW, WAR

Hazards er implementeringsproblemer som oppstår når instruksjoner i en pipeline hindres i å utføres i den tiltenkte klokkesyklusen på grunn av ressurskonflikter eller manglende data. Disse farene er resultatet av avhengigheter i programkoden.


| Fare | Avhengighet          |                                                                                                                                                                                                             |
| ---- | -------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RAW  | Sann dataavhengighet | En instruksjon prøver å lese en operande fra et register før en tidligere instruksjon har skrevet den nye verdien til det registret.  Denne avhengigheten representerer en reell dataflyt i programmet      |
| WAR  | Antiavhengighet      | En instruksjon prøver å skrive til et register eller minnelokasjon som en tidligere instruksjon fortsatt er i ferd med å lese fra. Dette er en ordning tvunget av gjenbruk av et navn.                      |
| WAW  | UIdataavhengighet    | To instruksjoner forsøker å skrive til det samme registeret eller minnelokasjonen. Riktig programrekkefølge må opprettholdes for å sikre at den siste utførte instruksjonen er den som setter sluttverdien. |
WAR og WAV er spesielt relevante i prosessorer som tillater utførelse av ut-av-rekkefølge, da de kan endre den logiske rekkefølgen av les og skriveoperasjoner.


### Pinsippene bak register renaming
Register renaming er en teknikk som fjerner navnavhengigheter, slik at WAW og WAR farer elimineres.

Prinsipp:
 Navnavhengigheter oppstår fordi de er tvunget av at to logisk uavhengige instruksjoner gjenbruker samme register-navn.

Register renaming løser dette ved å gi instruksjonene midlertidige, unike fysiske registre som er atskilt fra de arkitektoniske registrene.

Resultatet er at hver instruksjon skriver til et unikt fysisk register, selv om de i programkoden ser ut til å skrive til samme logiske register. Dette eliminerer WAW-faren. Videre kan en lesing skje fra det tidligere, korrekte fysiske registeret før den senere instruksjonen skriver til sitt unike fysiske register, noe som eliminerer WAR-faren.

### Fordeler og ulemper med statisk multi-issue prosessorer
SMI er en tilnærming til å implementere en prosessor som utsteder flere instruksjoner per klokkesyklus, der mange beslutninger tas av kompilatoren før utførelse. Denne arkitekturen er ofte kjent som very long instruction word

Fordeler:
- Enkel maskinvare: Det primære målet er å forenkle prosessoren ved å flytte kompleksiteten fra maskinvaren til kompilatoren. Dette gjør maskinvaren bak utstedelse og dekoding enklere, siden kompilatoren har gjort den tunge jobben.
- Høy gjennomstrøming. Kan potensielt forbedre ytelsen betydelig ved å utstede to eller flere instruksjoner per syklus.

Ulemper:
- Kompleks kompilator: Kompilatoren får et stort ansvar, inkludert å pakke instruksjoner og håndtere farer. Kompilatoren må ofte sette inn NOP-instruksjoner for å fjerne farer, selv om dette kan kaste bort issue slots.
- Den økte overlappen av instruksjoner øker det relative ytelsestapet for data og kontrollfarer. En fare tvinger gjerne hele instruksjonspakken som inneholder den avhengige instruksjonen til å stanse.
-
### Prinsippene bak dynamisk multi issue prosessorer
Dynamisk multi-issue (superscalar) er en maskinvarebasert tilnærming der prosessoren tar mange beslutninger under utførelse. 

Målet er å utføre instruksjoner ut-av-rekkefølge for å unngå stans forårsaket av farer.

Dynamisk planlegging er implementert ved å dele pipelinen inn i tre hovedenheter:

a) Utstedelsesenhet
- Denne enheten henter instruksjoner, dekoder dem og sender hver instruksjon til en tilsvarende funksjonell enhet for utførelse.

b) Funksjonelle enheter med reverasjonsstasjoner
- Instruksjonene utføres av funksjonelle enheter (ALUer) Før utførelse lagres operander og operasjonen i bufferet kalt reservasjonsstasjoner.
- Dynamisk planlegging, en instruksjon utføres så snart dens operander er klare og den funksjonelle enheten er ledig, uavhengig av om tidligere instruksjoner er ferdige
- Reservasjonsstasjonene og reorder bufferen brukes til å implementere register renaming, en teknikk som elimnerer WAW og War farer ved å gi instruksjonene unike fysiske registre.

c) Commit-enhet
- Resultatet for programutførelse blir sikret ved å skrive resultatet til de programmer-synlige registrene og minnet kun i programrekkefølge.
- Reorder buffer: Commit-enheten bruker en buffer for å holde resultatene fra utførte instruksjoner inntil det er trygt å skrive dem tilbake. Dette sikrer at virkningen av instruksjoner blir synlig for systemet i riktig rekkefølge, selv om de ble utført ut av rekkefølge.
- Håndtering av uforutsigbare stans: Dynamisk planlegging lar prosessoren skjule stans forårsaket av uforutsigbare hendelser som for eksempel cache misses (minnefeil) ved å fortsette å utføre andre, uavhengige instruksjoner.****


### forskjellen
Statisk multi-issue = kompilatoren bestemmer parallelitet
dynamisk multi-issue = maskinvaren bestemmer paralleliteten


### Speculation
Sentralt konsept for å utnytte mer instruksjonsnivåparallellitet i agressive pipeliner

Spekulasjon er en tilnærming basert på prediksjon, der kompilatoren eller prosessoren gjetter utfallet av en instruksjon for å muliggjøre at instruksjoner som er avhengig av den, kan begynne utførelsen tidligere.

1. Forutsigelse av forgrening
- Gjette om en betinget forgrening vil bli tatt eller ikke, slik at alle instruksjonene på den forutsagte banen kan hentes og utføres umiddelbart

2. Minnetilgangspekulasjon
- Spekulere i at lagringsinstruksjon som kommer før en lasteinstruksjon ikke refererer til samme minneadresse, slik at lastingen kan utføres tidligere.

1. Krav til gjennopretting
- Siden spekulasjon kan være feil må enhver mekanisme inkludere en måte å verifisere gjetningen på, og en metode for å tiblakeføre

Korrekt spekulasjon øker ytelsen, mens ukorrekt spekulasjon reduserer ytelsen fordi pipelinen må tømmes og instruksjonene må utføres på nytt.




