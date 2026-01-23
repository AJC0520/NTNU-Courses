### Mikroarkitekturen til flersykelprosessoren

Designet for å la hver instruksjon fullføres over flere klokkesykler, i motsetning til en lang syklus. Detet gir kortere klokkesykluser og økt ytelse, men krever mer kompleks kontroll.

Sammenlignet med enkeltsykeldatastien, kjennetegnes flersykelarkitekturen av to hovedprinsipper, delt maskinvare og midlertidig lagring.

1. Delt maskinvare.
	- Det brukes kun en minnenhet som deles mellom instruksjonsminne og dataminne
	- Det brukes kun en ALU, i stedet for ALU pluss separate addere for pc inkrementering og forgrening.
	- Dette gjør at funksjonelle enheter kan brukes mer enn en gang per instruksjon, så lenge det skjer i forskjellige klokkesykluser.

2. Midlertidige lagringsregistre
	- Siden en instruksjon strekker seg over flere klokkesykluser, må utdata fra en syklus lagres til neste syklus for samme instruksjon. Dette krever ekstra tilstands elementer eller midlertiidige registre. Disse registrene skrives til på hver aktiv klokkekant og inkluderer:
		- Instruction register
		- Memory data register
		- A og B
		- AluOUT lagrer resultatet av en ALU-operasjon

### Hvorfor kontrollenheten blir en tilstandsmaskin

Kontrollenheten i flersykelprosessoren må implementeres som en tilstandsmaskin fordi instruksjonsutførelsen er sekvensiell og flerstegs.

I en enkeltsykelprosessor avhenger kontrollen kun av instruksjonens opcode, i en flersykel må man spore hvor en instruksjon er i sin utførelse.

- Sekvensiell logikk. Flersykelkontroll krever sekvensiell logikk, fordi atferden avhenger av både innganger og innholdet i den interne tilstanden.

Tilstandsmaskinen består av et sett med tilstander og funksjoner som definerer hvordan man endrer tilstand. Hver tilstand tilsvarer ett klokkesyklussteg av instruksjonsutførelsen.

Kontrollenheten må bestemme:
- Hvilke kontrollsignaler som skal være aktive i den nåværende tilstanden.
- Hva som er den neste tilstanden i sekvensen, basert på nåværende tilstand og instruksjonens opcode.


### Sammenheng mellom kontrollord og tilstanden i tilstandsmaskinen
Hver tilstand er direkte knyttet til kontrollroder, settet av kontrollsignaler som sendes til datastien, gjennom output funksjonen.

Når tilstandsmaskinen er i en bestemt tilstand, spesifiseres denne tilstanden hvilke utganger som skal assertes. Disse utgangene er kontrollsignalene som styrer multiplekserne og skriveoperasjoner til tilstandselementene i datastien.

Det antas at alle utganger som ikke er eksplisitt assertet i en tilstand er satt til 0. Dette er kritisk for å hindre uønskede skriveoperasjoner som for eksempel å unngå register eller minneskrivninger.

De første to tilstandene IF ID er identiske for alle instruksjonsklasser.
Etter state 1, brukes instruksjonens opcode som inngang for å dekode instruksjonen og bestemme hvilken gren som skal følges. Denne forgreningen leder til tisltander som assertser de kontrollsignalene som er spesifikke for den instruksjonstypen.

### Fordeler og ulemper ved flersykel sammenlignet med enkeltsykel.


|                   | Enkeltsykel                                                                                               | Flersykel                                                                                                        |
| ----------------- | --------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------- |
| Klokkesyklustid   | Lang, må strekkes for å romme den lengste instruksjonsbanen                                               | Kort, bestemmes av det lengste individuelle steget.                                                              |
| CPI               | Alltid 1                                                                                                  | Variabel, typisk 3-5. Kortere instruksjoner fullføres raskere enn lengre.                                        |
| Maskinvarekostnad | Høy. krever separate funksjonelle enheter (feks to addere og to minneenheter fordi alt skjer i en syklus) | Lav. funksjonelle enheter kan deles og gjenbrukes i forskjellige sykluser, noe som reduserer mengden maskinvare. |
| Kontrollenhet     | Enkel. Kombinasjonell logikk basert på sannhetstabeller.                                                  | Kompleks. (sekvensiell tilstandsmaskin som styrer sekvensering og datastien)                                     |
| Total ytelse      | lav. lang syklustid forsinker alle instruksjoner                                                          | potensielt høyere. på grunn av høyere klokkerate og muligheten til å la raske instruksjoner fullføres raskt.     |


### Oppførelsen til SR-lås, D-lås og D-vippe
Minnelementer lagrer tilstand. Output fra ethvert minnelement avhenger både av inputs og verdien som er lagret internt.

SR-lås (Set-reset latch)

Når S eller R er aktivert fungerer de som invertere og lagrer de forrige verdiene av utgangene Q og Qstrek

Hvis S aktiveres blir utgangen Q aktivert (sann) og Qstrek blir usann
Hvis R aktiveres blir Utgangen Qstrek sann og Q deaktiver.

Å aktivere begge samtidig akn føre til feilaktig operasjon,


Dlås(d-latch)
Klokket minnelement som lagrer verdien av datainngangen D. Den er ofte implementert ved å legge to ekstra porter til den krysskoblede NOR-strukturen.

Utgangen Q er lik den lagrede tilstanden


Når klokkeinngangen C er aktivert er låsen åpen. Utgangen Q antar umiddelbart verdien av innganen D siden Q endres umiddelbart når D endres mens klokken er høy, kalles dette noen ganger en transaprent lås.

D-vippe
Klokkede minneelementer, men kan tilstanden endres kun på en klokkekant. Dette er den foretrukne typen minneelement i systemer som bruker kan-trigget klokking.

### Konstruksjon av registre og registerfilet
En registerfil er en sentral komponent i datastien og består av et sett med registre som kan leses fra og skrives til ved å spesifisere et registernummer. Den er implementert med d-vipper og kombinasjonell logikk.

### Klokkesignalets funksjon og kritisk sti
Klokkesignalet er essensielt for synkrone systemer, som er minnesystemer der data kun leses når klokken indikerer at signalverdiene er stabil. 

Klokkekant fungerer som et sampling-signal som får verdien av datainngangen til et tilstandselement til å bli samplet og lagret. Denne prosessen er øyeblikkelig, noe som eliminerer problemer med at signaler samples på litt forskjellige tidspunkt.

Klokken styrer når tilstandselementene skal oppdateres. Dette sikrer at operasjoner er forutsigbare og unngår races.

For tilstandsmaskiner som ikke oppdateres på hver klokkekant, brukes et eksplisitt skrivestyringssignal. Dette signalet må kombineres med klokken slik at oppdateringen kun skjer på klokkekanten hvis skrivesignalet er aktivt.

Kritisk sti
Lengste tidsforsinkelsen i den kombinasjonelle logikken, og den bestemmer den nødvendige lengden på klokkesyklusen.

Klokkesyklusen må være lang nok til å tillate at signaler forplanter seg fra ett minneelement, gjennom all kombinasjonell logikk, og når frem til inngangen til neste minneelement i tide til å tilfredsstille setup-tidskravet.





