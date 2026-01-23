
### De tre designprinsipene for instruksjonssett
1. Regelemessighet forenkler
	Regularitet reduserer kompleksiteten i maskinvaren. Prinsippet motiverer designvalg i RISC-V som: å holde alle instruksjoner i en og samme størrelse, alltid kreve registeroperander i aritmetiske instruksjoner og holde registerfeltene på samme sted i alle instruksjonsformater.

2. Mindre er raskere
	 Færre registre betyr raskere tilgang. RISC-V har derfor kun 32 registre. Registre er ekstremt raske, omtrent 200 ganger raskere og 10 000 ganger mer energieffektive enn DRAM.

3. God design krever gode kompromisser.
	Løser konflikter i designet, som for eksempel mellom ønsket om fast instruksjonslengde og behovet for store adresser eller konstanter. Bruk distinkte instruksjonsformater for ulike instruksjonsklasser, men likevel beholde alle på 32 bit.

### Oversettelse fra assemblyinstruksjoner til maskinkode (og omvendt)
Assembleren oversetter symbolske versjoner av instruksjoner til den binære versjonen som maskinvaren forstår. Hver instruksjon er delt inn i numeriske segmenter kalt felt.

For å reversere prosessen må man dekode den binære strengen:
1. Bestem format: Først se på de 7 laveste bitene i instruksjonsordet for å avgjøre hvilket format.
2. Bestem operasjon, basert på formatet og verdiene i funct3 og funct7 felt.
3. Les registre.


### RISC-V instruksjonsformater
Instruksjoner er konsekvent 32-bit lange for å opprettholde enkelhet og regularitet i maskinvaren.

R-type (reg til reg): 
- Simpel operasjon (kun tre registeroperander) for å holde maskinvaren enkel

I-type (instrukser med en ummidelbar konstant):
- Tillater bruk av konstante operander inne i instruksjonen, noe som er svært vanlig og gjør operasjoner raskere (make the common case fast)

S-type ( lagringsinstruksjoner):
- Imm er delt inn i to deler. Begrunnelsen for den rare splittingen er å holde rs1 og rs2 feltene sammen i bitposisjon som i de andre formatene, noe som sterkt forenkler maskinvaren i datastien.

### Hvordan instruksjoner lagres i minnet og kontrollflyt
Grunnlaget for moderne databehandling er prinsippet om lagrede programmer.

1. Instruksjoner er representert som tall (binære koder)
2. Programmer lagres i minnet for å leses eller skrives, akkurat som data.

Datamaskinens minne kan inneholde både programkode og dataene programmet bruker.

Datamaskinens evne til å ta beslutinger og endre hvilken instruksjon som skal utføres videre (kontrollflyt) skiller den fra en kalkulator.

**Program Counter (PC)**
- Alle instruksjoner utføres i den rekkefølgen de er lagret, kontrollert av PC som holder adressen til instruksjonen som skal utføres.

**Sekvensiell utførelse:**
- Normalt øker PC med 4 for å peke på den neste instruksjonen i minnet (siden instruskjoner er 4 byte lange)

**Beslutninger (betingede forgreininger)**
- For å implementere kontrollflyt basert på dataverdier (som if setninger eller while løkker), brukes conditional branches som beq og bne
	- Disse instruksjonene sammenligner innholdet i to registre. Hvis betingelsen er sann, oppdateres PC med en ny mål-adresse (som er summen av PC og en konstant i instruksjonen)

**Ubetingede hopp:**
- For å hoppe ubetinget, for eksempel for å implementere funksjonskall eller slutten av en if setning, brukes instruksjoner som jal eller jalr, som endrer PC-en for å starte utførelse på et annet sted i programmet.

### Negative heltall på 2s komplement form
Mest signifikante bit: 0 betyr positivt, 1 betyr negativt. (sign bit)

For å finne representasjon av et negativt tall gitt det positive tallet
1. Inverter alle bitene, og lett til 1
Kan også brukes i motsatt retning.

### Fortegnsutvidelse av tall på 2s komplement form.
Fortengsutvidelse: øke antall bits som brukes til å representere et tall på tos komplement form, uten å endre verdien.

Hvorfor verdien beholdes:
Positive tall:
- Positive tall i 2s komplement har et uendelig antall ledende 0-er til vesntre. Når man utvider et positivt tall (som har 0 som det mest signifikante bittet), kopierer man 0-en gjentatte ganger for å fylle de nye større bitposisjonene. Dette tilsvarer å gjenopprette de skjulte ledende 0-ene.
- Negative tall i to's komplement har et uendelig antall ledende 1-ere til venstre. Når man utvider et negativt tall (som har 1 som det mest signifikante bittet) kopierer man 1-tallet gjentatte ganger for å fylle den nye, større bredden. Dette gjenoppretter de skjulte ledende 1-erne og bevarer dermed den negative verdien


### Overflyt og når det oppstår

Overflyt oppstår når resultatet av en operasjon er for stor til å bli representert av det tilgjengelige maskinvareformatet, for eksempel 32-bit ord.

Overflyt i 2s komplement:
- Ved bruk av 2s komplement skjer overflyt når fortegnsbitet er feil. Dette betyr at det er en logisk feil i det mest signifikante bittet av resultatet, gitt de to operandene.

Overflyt oppstår kun når man legger sammen tall med samme fortegn.
Addisjon av to positive tall: Overflyt skjer hvis summen er negativ
Addisjon av to negative tall: Overflyt skjer hvis summen er positiv

Hvis to operander har ulikt fortegn, kan overflyt aldri skje.

Ved subtraksjon kan det kun skje når operander har ulikt fortegn.
1. positivt  minus negativ: overflyt hvis resultat er negativt
2. negativt minus positivt: overflyt hvis resultatet er positivt.

### Logiske operasjoner på binære tall
Brukes til å manipulere felter av bits eller individuelle bits innenfor et ord.

### Oppgaver med funksjonskall og kallkonvensjon
Et funksjonskall, eller en prosedyre er en lagret subrutine som utfører en spesifikk oppgave basert på parametere den mottar.

Opggaver som skal utføres ved prosedyrekall:

1. Plassere parametere: verdiene må plasseres der prosedyren kan få tilgang til dem
2. Overføre kontroll: kontrollen må overføres til prosedyren. jal
3. Allokere lagringsressureser: Nødvendig lagringsressurser for proseydren må anskaffes.
4. Prosedyren utfører den tiltenkte oppgaven
5. Resultatverdien må plasseres et sted der det kallende programmet kan få tilgang til den.
6. Kontrollen å returneres til det opprinnelige utgangspunktet (point of origin), da en prosedyre kan kalles fra flere steder i programmet. jump and link register.

Kallkonvensjon:
Sikrer at prosedyrekall kan skje effektivt og korrekt
Konvensjonen definerer hvilke regsitre som har bestemte roller (argumenter, returadresse, stakkpeker)

ra, sp og lagrede registre må bevares

Sørger for at de fleste prosedyrer kan bruke til opptil åtte argumentregistre, og syv temporære registre uten å måtte gå til minnet, noe som bidrar til prinsippet om å gjøre det vanlige tilfellet raskt.

### RISC-V minnekartet
Allokering av program og data i minnet.

Minneområdet for brukerprogrammer er delt inn i segmenter, hvor stakken og heapen er plassert slik at de kan vokse mot hverandre for effektiv minneutnyttelse.

![[Pasted image 20251202121855.png]]

Stack **lagrer automatiske/lokale variabler** og **lagrede registre** for prosedyrer. Den **vokser nedover** (fra høye adresser til lavere)

Dynamic data (heap) **lagrer dynamiske datastrukturer** (feks linkede lister) **allokert ved kjøretid** (malloc eller new). V**okser oppove**r (fra lave adresser til høyere)

Static data **lagrer konstanter og andre statiske variable**r (som eksisterer hjennom hele programmets levetid). Størrelsen er fastsastt.

Text segment lagrer maskinkode for rutiner. Programmets instruksjoner. Størrelsen er fastsatt.

Reserved er minneområdet reservert for OS og systemfunksjoner. starter ved 0

### Forskjellen på statisk og dynamisk data

Statisk data er variabler som eksisterer gjennom hele levetiden til programmet, selv når prosedyren der de er definert avsluttes og gjennintres.

Dynamisk data er strukturer som vokser og krymper under programmets kjøretid.

### Hvordan tekst representert i en datamaskin
Hovedsak ved hjelp av tallkodede tegn:
- ASCII og Bytes

### Håndtering av store konstanter og lange hopp (PC-relativ adressering)
Det finnes mekanismer for å håndtere konstaner og adresser som er større en 12-bit imm field

Load Upper Immediate:
- Laster en 20-bit konstant inn i vitene 12-31 til et register, de 12 laveste fylles med nuller

en 32-bit konstant kan dermes lages ved å bruke to instruksjoner
1. Lui for å laste de øvre 20 bitene
2. addi for å legge til de resterende 12 bitene

Unngå lange hopp:
Lange hopp løses ved å utnytte pc-relativ adressering.
- Betingete forgreininger finnes i løkker og if setninger, og de har en tendens til å hoppe til en nærliggende instruksjon.
- PCR adressering er en det måladressen er summen av PC og en konstant i instruksjonen.
- beq, bne bruker 12-bit felt +- 2^12 bytes
- jal bruker 20bit imm felt +- 2^20 bytes

For å kunne hoppe til hvilken som helst 32-biters adresse, brukes en to-instruksjonssekvens.
1. Lui skriver de øvre 20 bitene av mål adressen til et temp reg.
2. Jalr legger til de nedre 12 bitene av adressen til registret og hopper til summen

### RISC-V fire adressemodi
Har et sett med adresseringsmodi, som brukes til å identifisere operander. (enkelhet og regularitet)


1.  IMM adressing
	Operanden er en konstant som er inkludert som en del av selve instruksjonen. Brukes av aritmetiske og logiske instruksjoner med konstanter som addi og andi
2. Register adressering
	Operanden er innholdet i et register. Brukes av aritmetiske og logiske instruksjoner uten konstanter, som add.
3. Base eller forflytningsadressering
	Operanden er i minnet og adressen beregnes som summen av innholdet i et register og en konstant som finnes i instruksjonen. Bruks av dataoverføringsinstruksjoner som lw og sw.
4. PC-relativ adressing
	Måladressen for en instruksjon er summen av PC + en konstant. Brukes av beq, ben, jal

