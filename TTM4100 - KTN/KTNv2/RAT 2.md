1. Beskriv hvordan "longest prefix matching" regelen brukes i rutere, og forklar hvorfor denne regelen er viktig for effektiv ruting på internett.
	- Når en pakke kommer med en destinasjons ip sjekker ruteren hvilke ruter i tabellen som mathcer starten av IP adressen
	- Flere ruter kan passe, men ruteren velger den ruten med den mest spesifikke prefikset.
	- Dette blir sjekket på et binært nivå
	- Dette er mer effektivt
2. Forklar begrepet "head-of-the-line (HOL) blocking" i en input-kø svitsj, og beskriv hvordan det påvirker ytelsen.
	- Head of line blocking skyldes at en pakke som er på toppen av køen ikke kan gå ut av køen fordi utgangsporten den skal til er opptatt eller blokkert, Som fører til at alle pakkene bak heller ikke kan bli sendt.
	- Dette fører åpenbart til redusert effektivitet og økt forsinkelse.
3. Beskriv FIFO, prioritetskø, Round Robin (RR) og Weighted Fair Queuing (WFQ) pakkedisipliner (scheduling). 
	- FIFO (first in, first out)
		- Pakkene sendes ut i rekkefølgen de kom i (0 prioritering)
		- Enkelt å implementere
		- Viktige pakker kan bli forsinket.
	- Prioritetskø
		- Hver pakke får en prioritet, pakker med høyere sendes ut først
		- Viktige pakker får rask behandling
		- Lavprioritetspakker kan sulte (starvation), blir aldri sendt
	- Round Robin
		- Ruteren roterer gjennom flere køer, og sender en pakke fra hver i tur og orden.
		- Alle strømmer får sjansen, men samtidig blir alle behandlet likt
	- WFQ
		- Round Robin på steroider
		- Hver strøm får en vekt som bestemmer hvor mye bandwidth den får
		- Rettferdig fordeling, viktige strømmer får mer kapasitet
		- Mer kompleks å implementere
4. Hvilke mekanismer finnes for å håndtere køer i rutere og unngå overbelastning? Beskriv "drop-tail policy" og minst én "active queue management (AQM)" algoritme. 
	- Drop-tail policy (enklest og mest brukt)
		- Når køen er full, droppes nye pakker som kommer inn.
		- Kan føre til global synkronisering hvor mange sendere reduserer og øker hastigheten samtidig, som skaper svingninger og dårlig ytelse.
		- AQM: 
			- AQM algoritmer begynner å droppe eller merke pakker før overbelastning skjer, for å signalisere til avsendere at de bør bremse ned.
			- RED (random early detection)
				- Når køen blir lang, droppes eller markeres pakker tilfeldig, men en sannsynlighet som øker med kø-lengden.
				- Varsler tidlig til sendere at de må redusere hastigheten
				- Hindrer forsinkelse og pakketap
				- Merk kompleks en drop-tail.
5. Forklar formålet med "Time-to-Live (TTL)"-feltet i IPv4-headeren og "Hop Limit"-feltet i IPv6-headeren. Hva skjer når dette feltet når null? 
	- IPv4 (TTL)
		- Et tall som angir maksimalt antall hopp (rutere) en pakke kan gå gjennom
	- IPv6 (Hop limit)
		- Har samme funksjon bare i et IPv6 nettverk
	- Hver gang pakken går gjennom en ruter, reduseres verdien med 1, når den når 0 kastes den av ruteren og sender en ICMP-feilmelding tilbake (time exceeded)
		- Hindrer at pakker sirkulerer evig ved rutingfeil
		- Beskytter nettverket mot overbelastning
		- 
6. Beskriv trinnene (og meldingene) i DHCP-protokollen for en ny host som ankommer et nettverk. Hvorfor må DHCP-serverens svar kringkastes?
	- DHCP (Dynamic Host Configuration Control) brukes når en ny host kobler seg til et nettverk og trenger en IP-adresse. Hovedtrinnene (DORA)
		1. DHCP*DISCOVER*
			- Host sender en kringkastingsmelding for å finne DHCP-servere. IP-adressen er ukjent, så den bruker broadcast(255.255.255.255)
		2. DHCP*OFFER*
			- DHCP-server svarer med et tilbud, IP-adresse + info. Sendes med broadcast for å nå klienten som ennå ikke har IP.
		3. DHCP*REQUEST*
			- Host sender melding for å akseptere tilbudet, den kan også bruke dette trinnet til å be om en spesifikk IP.
		4. DHCP*ACK*
			- DHCP-server bekrefter tildelingen. Nå kan klienten bruke IP-adressen.
7. Hva er de viktigste forskjellene mellom IPv4 og IPv6 datagramformater? Hvorfor ble fragmentering fjernet fra IPv6? 
	- Fragmentering ble fjernet fordi:
		- Effektivitet - rutere søipper å bruke tid på fragmentering
		- Forenklet ruterdesign - mindre kompleks, bedre ytelse
		- Ende-til-ende kontroll, bedre at sender og mottaker styrer størrelsen på datagrammene
		- IPv6 krever at avsender finner minste tillate pakke-størrelse langs ruta og tilpasser seg den.

| Funksjon         | IPv4                         | IPv6                                |
| ---------------- | ---------------------------- | ----------------------------------- |
| Adresse-lengde   | 32 bits                      | 128 bits                            |
| Header-Størrelse | variabel (20-60 bytes)       | Fast (40 bytes)                     |
| Fragmentering    | Tillatt, av sender og rutere | Bare avsender, ikke rutere          |
| Checksum         | Ja                           | Nei (fjernet for hastighet)         |
| Broadcast        | Brukeees                     | Ikke brukt, erstattes med multicast |
| Opsjonsfelt      | Ja                           | flyttet til extension headers       |

8.  Hvordan fungerer Network Address Translation (NAT), og hvilke problemer løser det?
	- Brukes for å oversette private ip, til offentlig ip.
	1. En enhet i hjemnettverket, sender en pakke ut mot internettet
	2. Ruteren oversetter den interne ip adressen og porten til sin offentlige ip og en ledig port
	3. Ruteren husker koblingen
	4. Når svarpakker kommer tilbake, slår ruteren opp i tabellen og videresender til riktig enhet i lokalnettet.
	- NAT løser
		- IP-adressmangel
			- IPv4 har kun ca. 4 milliarder adresser.
			- NAT gjør det mulig for mange enheter å dele en offentlig IPv4-adresse
		- Sikkerhet (delvis)
			- NAT skjuler interne IP-adresser fra internettet
			- 