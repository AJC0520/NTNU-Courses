1. Hva er formålet med et socket-grensesnitt i et ende-system koblet til internett?
	- Koble sammen applikasjonen med transportlaget. (Feks TCP eller UDP)
	- Et socket gir applikasjonen mulighet til å sende og motta data over nettet via transportprotokoller.
2. Hvilken organisasjon utvikler internettstandarder, og hva kalles standarddokumentene? 
	- IETF, Internet Engineering Task Force
	- Standarddokumentene kalles RFC, Request for Comments.
3. Hva er de vanligste typene bredbåndstilgang for boliger? 
	- FTTH, Fiber
	- Coax, tv-kabel
	- DSL, kobberlinje
	- Mobilt bredbånd 5G
	- Trådløst bredbånd
	- Sattelitbrebånd
4. Hvordan fungerer DSL-teknologi for å gi internettilgang?
	- Gir internetttilgang ved å bruke de eksisterende kobberbaseret telefonlinjene i hjemmet. Hastigheten avhenger av avstanden tiL DSLAM, .
5. Hva er "fiber til hjemmet" (FTTH), og hva er fordelene?
	- Fiberoptisk kabel går rett inn i bolig istendefor å stoppe med en sentral.
	- Mye kjappere, lik opplastning som nedlastning
	- Stabilt
	- Høy kapasitet, lav ventetid, fremtidsrettet
6. Hva er de to hovedkategoriene av fysiske medier som brukes i datanettverk?
	- Guided media (fysisk)
		- Data sendes gjennom ledning
	- Unguided media
		- WiFi
		- 5g
		- satelitt
		- bluetooth
7. Hva er "store-and-forward"-overføring?
	- Store and forward betyr at feks en ruter ikke sender videre en packet før all data er mottatt. 
	- Pakken sjekkes for feil og valideres og sendes videre mot målet.
	- Kan gi forsinkelse
8. Prøv å forklar analogien mellom ruting i internett og å be om veibeskrivelser når du kjører bil.
	- Bil: Du starter hjemme og vil til en bestemt addresse
	- Internett: Data sendes fra en IP-adresse til en annen

	* Bil: du følger veibeskrivelser gjennom ulike veikryss og veier
	* Internett: Pakken går gjennom flere rutere som bestemmer neste steg

	- Bil: ved hvert veikryss vurderer du hvilken vei som fører nærmest målet.
9. Hva er hovedforskjellen mellom linjesvitsjing og pakkesvitsjing? 
	- Circuit switching
		- det settes opp en dedikert forbindelse mellom to parter
		- Den er reservert for disse to partene
		- Feks telefonsamtale
	- Packet switching
		- data deles opp i små pakker som sendes uavhengig og dynamisk gjennom nettet
		- pakker kan ta forskjellige ruter
		- feks internettet
10. Hvilke lag er inkludert i internett-protokollstakken?
	- Application
	- Transport
	- Network
	- Link
	- Physical