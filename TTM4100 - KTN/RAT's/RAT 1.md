
#### Hva er formålet med et socket-grensesnitt i ende-system koblet til internett?

- Formålet er å muliggjøre kommunikasjon mellom applikasjoner over et nettverk. Den fungerer som et API mellom applikasjonslaget og transportlaget i nettverksmodellen. Altså gjør socket-grensesnittet det mulig for applikasjoner å kommunisere oer internett ved å sende og motta data via nettverksprotokoller som TCP og UDP

#### Hvilken organisasjon utvikler internettstandarder, og hva kalles standarddokumentene?
* Internet Engineering Task Force (IETF)
* Standarddokumentene kalles for Request for Comments (RFC). Disse inneholder tekniske spesifikasjoner, protokoller og retingslinjer for internett-teknologier. Når en RFC blir en offisiell internettstandard får den betegnelsen Internet Standard (STD)

#### Hva er de vanligste typene bredbåndstilgang for boliger?
* Fiber (FTTH, FTTB) - Høy hastighet og lav forsinkelse
* Kabelbredbånd (HFC - Hybrid Fiber Coaxial) - Leveres via kabel-TV nett, raskere enn DSL.
* DSL (Digital Subscriber Line) - Bruker telefonlinjer, feks ADSL og VDSL
* Mobilt bredbånd (4G, 5G) - Trådløs tilgang via mobilnettverk, fleksibelt men kan ha bregrenset kapasitet.
* Fast Trådløst Bredbånd - Bruker radiobølger fra basestasjoner, et alternativ der fiber/DSL ikke er tilgjengelig.
* Satelittbredbånd - brukes i avsideliggende områder, høy forsinkelse men tilgjengelig nesten overalt.

#### Hvordan fungerer DSL-teknologi for internetttilgang?
- DSL (Digital Subscriber Line) gir internettilgang ved å bruke eksisterende telefonlinjer.
- Hvordan det fungerer:
	- DSL skiller mellom tale- og dataoverføring ved å bruke ulike frekvensområder. Tale bruker lavfrekvensområde (0-4kHz) mens dataoverføring skjer i høyere frekvensbånd.
	- Et DSL-modem hos brukeren konverterer digitale signaler til elektriske signaler som sendes over telefonlinjen. Disse signalene mottas av en DSLAM i telefonsentralen, som kobler brukeren til internett.
	- Asynkron eller synkron hastighet:
		- ADSL(asymetrisk) - Raskere nedlastning enn opplastning, vanlig for hjemmenett
		- VDSL(very high bit rate) gir høyere hastigheter enn ADSL, spesielt på kortere avstander.
		- SDSL (symmetric) - like rask opplastning og nedlastning, ofte brukt av bedrifter.
	- DSL har begrenset rekkevidde (opptil ca. 5km fra sentralen) og hastigheten reduseres med avstanden.

#### Hva er "fiber til hjemmet" (FTTH) og hva er fordelene?
* FTTH er en bredbåndsteknologi der en optisk fiberkabel går direkte fra leverandørens nettverk til brukerens bolig, uten koaksialkabler.
* Fordeler:
	* Høy hastighet, kan levere symmetriske hastigheter i gigabit
	* Lav forsinkelse
	* Stabilit
	* Skalerbarhet
	* Energibesparende.

#### Hva er de to hovedkategoriene av fysiske medier som brukes i datanettverk?
- Kablede medier - kobberkabel, koaksialkabel, fiberoptiske kabel.
- Trådløse medier - radiobølger, wifi, mikrøbølger, infrarød kommunikasjon.

#### Hva er "store-and-forward"-overføring
- En metode for dataoverføring der en enhet, feks ruter eller switch, mottar hele datapakken, lagrer den midlertidig, sjekker for feil, og deretter videresender den til neste nettverksnode. Dette forbedrer påliteligheten, men kan introdusere forsinkelse.
- Altså må hele datapakken mottas, før den sendes videre.

#### Forklar analogien mellom ruting i internett og å be om veibeskrivelser når du kjører bil.
- Datapakker = biler: Informasjon på nettet sendes i små oakker, akkurat som biler frakter passasjerer (data).
- Rutere = veikryss: Hver ruter på internettet fungerer som et veikryss der datapakkene får en ny retning basert på den beste tilgjengelige ruten.
- IP-adresser = destinasjoner: Datapakker har en IP-addresse som forteller hvor de skal på samme måte som at en bil har en addresse å kjøre til.
- Dynamisk ruting = trafikkinformasjon: Rutene kan velge en annen rute hvis en vei(nettverksforbindelse) er overbelastet eller er nede, akkurat som en GPS kan foreslå en alternativ vei ved kø.

#### Hva er hovedforskjellen mellom linjesvitsjing og pakkesvitsjing?
- Circuit Switching (linjesvitsjing):
	- En dedikert kommunikasjonslinje opprettes mellom sender og mottaker før dataoverføring starter.
	- Hele båndbredden på forbindelsen reserveres for samtalen.
	- Effektiv for kontinuerlige datastrømmer, men sløser med ressurser når det ikke er aktiv overføring
- Packet Switching (pakkesvitsjing):
	- Data deles opp i små pakker som sendes individuelt gjennom nettverket, potensielt via ulike ruter.
	- Ingen fast forbindelse reserveres, og bandbredden brukes mer effektivt.
	- Brukes i internett og datanettverk, feks TCP/IP
	- Mer robust og skalerbart, men kan ha varierende latens.
- Linjesvitsjing = fast forbindelse med stabil ytelse
- Pakkesvitsjin = mer fleksibel og effektiv for datatrafikk.

#### Hvilke lag er inkludert i internett-protokollstakken?
TCP/IP modellen består av fire lag:
Application layer, Transport Layer, Internet Layer, Network Access layer.







