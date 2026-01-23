
### De 7 datamaskintypene:

| Type                   | Karkatertrekk                                                                                                         |
| ---------------------- | --------------------------------------------------------------------------------------------------------------------- |
| PC                     | Designet for enkelte brukere, som laptoper. Bra performance med lav kostnad.                                          |
| Server                 | Tilgjengelig via nettverk, og orientert mot å holde på større arbeidsoppgaver. Bra lagring.                           |
| Supercomputer          | Høy performance og høy kostand. Konfigurert som servere og koster mellom tusenvis til hundre millionervis av dollar.  |
| Embedded Computer      | Største gruppen av datamaskiner, de man finner overalt. (i biler, tv) Lav kostand, men krever lav toleranse for feil. |
| Personal Mobile Device | Små wireless enheter, ofte avhengig av batteri for strøm og koblet til internettet.                                   |
| Cloud Computing        | Store kolleksjoner av servere som tilgjengeligjør deler av internettet.                                               |
|                        |                                                                                                                       |
### De 7 store ideene i datamaskinarkitektur:

|                                    |                                                                                                                                                 |
| ---------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| Make the common case fast          | Man bør optimalisere ting som forekommer ofte, siden det ofte er mer performance å hente fra dette enn å optimalisere ting som skjer sjeldnere. |
| Use abstraction to simplify design |                                                                                                                                                 |
| Performance via Parallelism        | Kjør flere operasjoner samtidig for å øke performance.  Pipelining, multicore, subword parallelism.                                             |
| Performance via pipelinening       | Kjøre flere instruksjoner i sekvens. Hver intruskjon er på en annerledes del av utførelse, samtidig.                                            |
| Performance via prediction.        | Gjett for å øke hastighet. (gjette outcome av en branch for å ikke sakke ned en pipelinge)                                                      |
| Hierarchy of memories              | Strukturere minne i levels, (cache, main memory, second storage) Kjappeste minne er minst og dyrest per bit.                                    |
| Dependability via redundeancy      | Inkludere ekstra komponenter så systemet kan funke selv om en komponent failer                                                                  |

### Størrelser:

Gigabyte (GB) = 10^9 bytes (powers of 1000)
Gibibyte (GiB) = 2^30 bytes (powers of 1024)

### Rollen til applikasjonsprogramvare og systemprogramvare
Programvare er organisert hierarkisk:
1. Applikasjonsprogramvare utgjør det ytterste laget i programvarehierarkitet.
	- Komplekse programmer (tekstbehandler, databasesystem) som ofte består av millioner av kodelinjer og er avhengige av sofistikerte biblioteker.
2. Systemprogramvare
	- Ligger mellom applikasjon og maskinvare
	- Leverer tjenester som er nyttige for systemet:
	- Operativsystemet (OS)
		- Sentral i hver datamaskin
		- Fungerer som et grensesnitt mellom brukerens program og maskinvare, og tilbyr ulike tjenester og overvåkingfunksjoner.
		- Viktigste funksjoner er: håndtering av I/O, operasjoner, allokering av lagring og minne, beskyttet deling av datamaskinen.
	- Kompilatoren:
		- Oversette program skrevet i høynivåspråk (java), til instruksjoner som datamaskinen kan utføre.
		- Siden høynivåspråk er komplekse og maskininstruksjoner er enkle, er dette komplisert. Kompilatoren oversetter høynibåspråk til assemblerspråk, som deretter settes sammen til binær maskinspråk.

### Prinsippet om det lagrede program
Instruksjoner og data er lagret sammen i minnet.
Konseptet er basert på to nøkkelprinsipper:
1. Instruksjoner er representert som tall
2. Programmer lagres i minnet for å leses eller skrives, akkurat som data.

Fordi instruksjoner og data er numerisk likeverdige, kan minnet inneholde kildekoden for et redigeringsprogram, det kompilerte maskinspråket, teksten programmet bruker og til og med kompilatoren som genererte maskinkoden.

Hver enkelt maskin kan raskt skifte funksjon, bare ved å laste ned nye programmer og data inn i minnet og be datamaskinen starte utførelsen på et gitt sted. Dette forenkler minnemaskinvaren og programvare i systemet.


### Produksjonsprosessen for integrerte kretser
1. Silisium vokses til en krystallstang
2. Stangene skives i tynne runde skiver
3. Skiven gjennomgår mønstringstrinn for å bygge kretser.
4. Den mønstrede skiven kuttes i uavhengige komponenter kalt brikker (dies)
5. De gode brikkene kobles til I/O pinnene på en pakke ved bonding.
6. Pakkede delene testes en siste gang.


### Viktigste ytelsesmetrikkene i datamaskinarkitektur
To hovedmål:
- Kjøretid: Den totale tiden det tar for datamaskinen å fullføre en oppgave. Inkulderer all tid, so mdiskaksesser, mineaksesserer, IO aktiviteter, os overhead, cpu-utførelestid.
- Gjennomstrømning (throughput/bandwidth): Den totale antallet oppgaver som fullføres i løpet av en gitt tidsenhet.
	- Ytelse er det omvende av kjøretid
	- Ytelse = 1 / kjøretid

### Forskjellen på kjøretid og båndbredde og valg av metrikk
Kjøretid er den viktigste metrikken for individuelle brukere, feks når man skal åpne en app er man interessert i hvor kjapt den åpnes.

Båndbredde er den viktigste metrikken for datacenters som har flere servere som kjører jobber snedt inn av mange brukere, og som ønsker å vite hvor mange jobber som kan fullføres i løpet av en dag.

Å redusere kjøretiden vil nesten alltid forbedre gjennomstrømningen ( båndbredde). I de fleste systemer vil endring av den ene metrikken på virke den andre.

### The Iron Law
Relaterer observert kjøretid til de grunnleggende faktorene som bestemmes av maskinvare og programvare, brukes til å forutsi effekten av arkitekturendringer.

CPU-kjøretid = Instruksjonstall x CPI x Klokkesyklustid

Siden klokkesyklustid er det inverse av klokkerate:

Cpu-kjøretid = (Instruksjonstall x CPI) / Klokkerate

Den er nyttig fordi den separerer tre nøkkelfaktorer som påvirker ytelsen:

1. Instruksjontall: Antall maskininstruksjoner som utføres av programmet. Bestemmes av algoritmen og kompilatoren.

2. CPI (klokkesykler per instruksjon): Gjennomsnittlig antall klokkesykluser hver instruksjon tar å utføre. Bestemmes av kompilatoren og prosessorimplementeringen.

3. Klokkesyklustid / klokkerate: Tiden for en klokkesyklus, som er maskinvarens grunnleggende tidsintervall. Klokkeraten er den inverse av klokkesyklustiden.


### Hvordan spenning og klokkefrekvens påvirker effekt og energiforbruk.
Dominerende teknologi for integrerte kretser er CMOS
Hovedkilden til energiforbruk er dynamisk energi, som forbrukes når transistorer bytter tilstander.

En **testprogramsamling** (benchmark) er et sett med programmer som er spesifikt valgt for å måle ytelsen til en datamaskin.

Hva er Benchmarks og Workloads?

• **Workload:** Et sett med programmer som kjøres på en datamaskin, enten den faktiske samlingen av applikasjoner en bruker kjører, eller en konstruert blanding som tilnærmer seg dette.

• **Benchmark:** Et program valgt for å brukes i sammenligning av datamaskinytels


### Hvorfor datamaskiner har mer enn en prosessorkjerne
1. The power wall
	  - Klokkeraten og strømforbruket økte raskt for intel mikroprosessorer
	  - Designere støttet på en grense for kjøling av standard mikroprossesorer.
2. Det ble begrenset ytelsesforbedring for enkeltkjerner på grunnav grensene for strømforbruk.
	  - Løsningen ble å inludere flere kjerner på brikken i stedet for å forsøke å redusere kjøretiden for et enkelt program på en kjerne.
3. Througput
	- Multicore-prosessorer er ofte mindre aggressivt spekulative og pipelinert enn sine forgjengere, men de leverer bedre ytelse per Joule

### Ahmdals lov

Bruk av Amdahl’s lov til å analysere ytelsesforbedring

Amdahl’s lov er en regel som fastslår at ytelsesforbedringen som er mulig med en gitt forbedring, begrenses av hvor mye den forbedrede funksjonen brukes. Det er en kvantitativ versjon av loven om avtagende utbytte.

Amdahl’s lov (Formel)

Den enkle likningen for å estimere kjøretiden etter en forbedring er:

Kjøretid etter forbedring = (kjøretid påvirket av forbedring / forbedringsfaktor) + kjøretid upåvirket.

Den mulige ytelsesforbedringen er begrenset av den upåvirkede delen av programmet.


