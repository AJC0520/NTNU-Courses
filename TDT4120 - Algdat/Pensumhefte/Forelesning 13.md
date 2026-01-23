# NP-Kompletthet

### M1 - Koding av en instans
Alle problemer må kodes som en streng over et alfabet før man kan snakke om:
- Størrelse på input
- Polynomisk tid
- språk
- reduksjoner

- Graf G representeres som en liste av kanter
- Integer knapsack representerer som binærkoding av vekt/verdier
- boolean formel representeres som tekststreng

Hvis kodingen blåser opp inputen, påvirker det om noe er "polynomisk"


### M2 - Hvorfor 0/1 knapsack ikke er polynomisk.

DP-lsningen for knapsack går i:
![[Pasted image 20251126171032.png]]

Den ser polynomisk ut, men er egentlig ikke det.

Inputen til knapsack inkluderer:
n = antall gjenstander
W = maks kapasitet (gitt i binær form)

Lengden på W i input = log(W) bits
Men DP-algoritmen bruker W direkte i en løkke
den gjør W operasjoner, ikke log W


Hvis man øker inputen med 1 bit, øker W eksponentielt

### M3 - Konkrete vs Abstrakte problemer
Abstrakt: matematisk ("finn en vei", "finn en matching")
konkret: faktisk datakoding: ("i"nput er en streng som representerer...")

NP, P, reduksjoner osv jobber på konkrete problemer

### M4 - Beslutningsproblemer som formelle språk
Et beslutningsproblem er et problem der svaret alltid er ja eller nei 
For å analysere slike problemer teoretisk, representerer man dem som formelle språk.

Man koder hver instans av problemet som en streng
Så definerer man et språk:
L={x∣x er en instans der svaret er JA}
- L er mengden av alle instanser som har svaret JA

Ved å skrive beslutningsproblemer som språk kan vi:
- snakke om klasser som P, NP og co-NP
- definere reduksjoner
- definere NP-hardhet og Np-kompletthet


### M5 - P, NP og co-NP

P:
Alle språk som kan løses i polynomisk tid

NP:
Alle språk hvor et "ja" svar kan verifiseres i polynomisk tid.

co-NP:
Komplementet av NP-problemer
"Bevis for NEI-svar kan sjekkes raskt"

### NP-hardhet og Np-kompletthet

NP-hard:
Et problem X er NP-hard hvis alle problemer i NP kan reduseres polynomisk til X

NP-complete (NPC):
X er NPC hvis:
- X er et element i NP
- X er NP-hard

Hvis man løser ETT NP-komplett problem i polynomisk tid, så er P = NP

### M7 - Sammeneheng søke, beslutnings og optimeringsproblemer
- Beslutningsproblem -> brukes i NP (ja/nei)
- Optimeringsproblem -> ofte NP-hard
- Søkeproblem -> ofte minst like vanskelig som beslutningsvarianten

### M8 - Den konvensjonelle hypotesen
Det alle forskere tror er sant, men ingen har klart å bevise

**P er IKKE lik NP**
Det finnes problemer som kan verifiserers raskt (NP) men ikke kan løses raskt (P)

Vi vet ikke om det er sant, og er et åpent spørsmål.

### M9 - Reduksjon begge veier mellom optimering og terskling
Eksempel: (knapsack)
- Optimering: Hva er den beste verdien?
- Terskling: finnes det en verdi med minst K?

Begge kan reduseres til hverandre polynomisk


Optimering -> terskling

### M10 - Reduksjon begge veier mellom søk og beslutning

Søkeproblem: skal finne selve løsningen
beslutingsproblem. ja/nei

Søk og beslutning er polynomisk ekvivalente

Altå:
Et søkeproblem kan løses ved å bruke beslutningsproblemet som et orakel
Et beslutningsproblem kan løses ved ett kall til søkeversjonen

Du kan løse et søkeproblem ved å gjøre mange beslutningsspørringer:
"Hvis jeg setter denne biten til X, finnes det fortsatt en gyldig løsning?"
Til slutt har du hele løsningen.
Dette tar O(n) beslutningskall -> polynomisk

Beslutning -> søk.
Hvis du har en søkealgoritme som kan gi deg selve løsningen, kan du løse beslutningsversjonen ved å spørre
" Finn en løsning"
- Hvis den finnes -> ja
- hvis ingen -> nei
dette er ett enkelt kall


### M11 - CIRCUIT-SAT NP complete
En circuit-sat er et logisk kretsdiagram (and, or, not) med en input vektor.

Problemet går ut på om det er noen form for input som vil gi 1.
En løsning er å sjekke alle muligheter 2^n
O(2^n)

X er NP komplett om:
1. X er NP
2. X er NP-hard

NP:
- En input vektor er et bevis
- Du kan sjekke om kretsen returnerer 1, i polynomisk tid.

NP-hard:
3SAT er et logisk uttrykk med AND, OR NOT.
Hvis man tar 3SAT-formelen som allerede er en sammensetting av logiske operatorer, kan man lage en krets der hver operator blir en tilsvarende gate. Da oppfører kretsen seg akkurat som formelen.









