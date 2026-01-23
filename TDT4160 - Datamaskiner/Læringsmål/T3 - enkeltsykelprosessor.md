

### Forklare begrepene datasti og kontrollenhet
Prosessoren består logisk sett av disse to komponentene.

1. Datasti
	- Muskelen i prosessoren
	- Utfører de aritmetiske opersasjonene. I
	- Inneholder elementer som opererer på eller holder data. Som feks Instruksjonsminnet, dataminnet, regfil, ALU, addere. 
	- Datastien tar inn data, behandler dem og lagrer resultatet.


2. Kontrollenhet
- Hjernen i prosessoren
- Den styrer og beordrer datastien, minnet og IO enheter i henhold til instruksjonene
- Den mottar instruksjoner som input og bestemmer hvorda alle kontrolllinjene og multiplexerne skal stilles inn.


### Mikroarkitekturen til enkeltsykelprosessoren

Hver instruksjon fullfører hele utførelsen på en enkelt, lang klokkesyklus.

1. Instruksjonshenting (IF): Programtelleren (PC) holder adressen til instruksjonen som skal utføres. Instruksjonen hentes fra instruksjonsminnet, og PCN inkrementeres samtidig med 4 for å peke på neste sekvensielle instruksjon.
2. Dekoding og registerlesing (ID): Instruksjonen mates inn i kontrollenheten. To registeroperander leses fra Registerfilen.
3. Utførelse (EX)
	1. ALU brukes for alle instruksjonsklasser
	2. For aritmetiske instruksjoner utfører ALU operasjonen på de to registerverdiene
	3. For minneinstruksjoner (lw, sw), beregner ALU minneadressen ved å legge sammen et base-register og et konstant offset.
	4. For forgreininger trekker ALU fra base registerene og bruker Zero utgang for å teste likhet
4. Minnetilgang (MEM): Dataminnet brukes kun av lw (ses) og sw (skriv) instruksjoner.
5. Tilbakeføring: (WB): Resultatet skrives tilbake til regfil. Kilden (ALU-resultat eller dataminne) velges av memtoreg-mux. 

Kontrollenhetens oppgave er å motta opcode-feltet fra instruksjonen som input. Basert på dette settet, bestemmer den tilstanden til åtte kontrollsignaler.

Pc-oppdatering: Pcn oppdateres enten med PC + 4, eller forgreningsmåladressen. Valget styres av signalet PCSrc som er resultatet av en AND-operasjon mellom kontrollsignalet Branch og ALUens Zero-utgang.


### Sette opp kontrollord, dont care

ALUop 2-bit kontrollsignal

Dont-care (x)
Betyr at verdien av output-signalet ikke avhenger av verdien på den korresponderende inputen og designeren er fri til å velge 0 eller 1 for å forenkle implementeringen av logikken.


1. Input dont care
	Når ALUOp er 00 (for lw eller sw) er ALU-operasjonen alltid addisjon. Derfor spiller funct-feltene ingen rolle, funct feltene får da verdien X i input kolonnen
2. Output dont care
	Hvis regwrite er satt til 0 (som for sw og beq), betyr det at registerfilen ikke skal skrive. I dette tilfellet spiller verdien memtoreg ingen rolle, siden det ikke skrives noe til registeret. Memtoreg får verdien X.

### Identifisere instruksjonstype fra kontrollrod
### Logiske porter
### Buss og adressering av enkeltlinjer
En buss er en samling av datalinjer, som behandles som ett enkelt logisk signal. Den brukes til å overføre data mellom funksjonelle enheter.

Busser indikerers i diagrammer med tykkere linjer, bussen er ofte merket med sin bredde.

Siden buss er en samling av linjer, må en operasjon som skal utføres på en hel buss faktisk replikeres for hver bit. Feks, en 32-bit multiplekser som velger mellom to 32-biters busser er faktisk et array av 32 separate 1-biters multiplekser.


### Konstruksjon av en 32-bit aritmetisk logisk enhet
ALU-enhet er prosessoren muskel, ansvarlig for å utføre aritmetiske og logiske operasjoner. En 32-bit alu bygges ved å koble sammen 32 separate 1-biters ALU-er.


A 1-bit ALU: AND og OR

De logiske operasjonene er de enkleste å implementere. En 1-biters logisk enhet for AND og OR, består av en AND-port, en OR-port og en multiplekser som velger resultatet fra enten AND eller OR basert på et kontrollsignal.

B
Addisjon: 1-biters full adder har tre innganger (a, b og CarryIn) og tu utganger (Sum og CarryOut)

32-bit addisjon: en 32-bitters alu er konstruert ved å koble carryout fra hver 1-biters ALU til carryin på neste bit til venstre. ripple carry

Subtraksjon, implementeres ved å legge til det negative tallet.
1. alle bitene inverteres ved hjelp av mux kontrollert av Binvert
2. tallet 1 legges til. Settes carryin på den minst signifikante biten til 1. Ved å sette binvert 1 og carryin 1, bergener aluen a + inversb som er lik a minus b

Nulldeteksjon
For å støtte betingede forgreininger (beq) må ALU kunne teste likhet. Likhetstest: ekteparet a og b er like hvis forskjellen er null. a-b = 
testes ved å substrahere b fra a. Detektoren sjekker om resultatet er null. Den enkleste måten å gjøre dette på er å ta logisk OR av alle utgangsbitene og deretter sette signalet gjennom en inverter. Hvis alle utgansgbitene er 0 blir resultatet 0 og inverten gir ut 1. 

### Multiplikasjon og divisjon av binære tall

Multiplikasjon:
Består av gjentatte skift og addisjoner
Produktet av to n-biters tall krever 2n bits.

1. Start med et 64-biters produt-reg init til 0
2. Multiplikanden plasseres i et 64-biters register og skfites til venstre ett hakk for hvert steg.
3. Multiplikatoren sjekkes bit for bit, fra høyre mot venstre. Hvis multiplikatorbiten er 1, legges multiplikanden til produktet.
4. Multiplikatoren skiftes til høyre ett hakk for hvert steg
5. Gjentas 32 ganger.

motsatt av multi er divisjon


### Fixed-point format

Fordel:
- I et fixed-point system, vil aritmetikken være like rask og enkel som heltallsaritmetikk siden det uføres av standard heltalls-alu. Unngår kompleksiteten og latensen forbundet med normalisering og avrunding av flyttall.
Ulempe:
- Kan ikke representere et bredt spekter av størrelser. Kan heller ikke representere brøkdeler på en fleksibel måte.

### Flyttall
Flytall trengs fordi heltall har en begrenset størrelse og dermed begrenset presisjon, noe som gjør det mulig å beregne tall som er for store eller for små til å representere i et datamaskinord.

Det støtter tall med brøkdeler
Tillater et stort dynamisk område ved å representere et tall i vitenskapelig notasjon.

Flytallsaddisjon er mer kompleks:
1. Sammenlign eksponentene. Bruk en liten ALU til å finne forskjellen og identifisere dens største eksponenten.
2. Signifikanten til tallet med den minste eksponenten skiftes tiø høyre til eksponentene er like.
3. Legges sammen ved hjelp av en større ALU
4. Summen normaliseres ved å skifte resultatet til høyre eller skifte til vesntre.
5. Resultatet avrundes til riktig antall bits.


Prinsipper for flyttallsmultiplikasjon:
- Multiplikasjon er enklere, siden man ikke trenger å justere signifikander før operasjonen.

1. De forhåndsjusterte eksponentene til operandene legges sammen. Eksponent-biasen må deretter trekkes fra summen for å få riktig ny justert 
2. Multipliser signifikandene
3. Produktet normaliseres og eksponentstørrelsen sjekkes.
4. Produktet avrundes.
5. sett fortengsbiten til 1 hvis de opprinnelige operandene hadde ulikt forteng eller 0 om de var like.


### Konvertering fra desimal til flyt

 85.125

konverter til binary
85 = 1010101
0.125 = 0.001
1**010101**.001

flytt x plasser til du har ett tal foran punktum
multipliser med 2^x
1.**010101**001 x 2^6

plasser sign bit
[0 | ]

exponent:
single precisioun = 127, double precisuoun = 1023
legg til x
127 + 6 = 133
konvertert til binary

[0 | 10000101 | ]

MANTISSA:
1.**010101001** x 2^6

[0 | 10000101 | **010101001** 0000000000]


### SIMD instruksjoner

Konsept og bruk:
SIMD er en form for parallelisme som utfører samme operasjon på flere databiter samtidig.

Brukes fordi man utfører identiske operasjoner på korte vektorer av data, grafikk og lyd blant annet.

Instruksjoner implementeres ved hjelp av teknikken subword parallelism. 

Istedenfor å bruke en stor ALU for å legge sammen to store tall, deler man alu opp i carry chains, så den kan utføre flere uavhengige mindre operasjoner parallelt.

Feks kan en 128-bit alu deles inn i

16, 8-bit operasjoner samtidig
8, 16-bit operasjoner
osv
osv


Det oppnås ved at carry signals ikke får lov til å forplante seg mellom de delte sub ordene slik at hver del behandles uavhengig.


