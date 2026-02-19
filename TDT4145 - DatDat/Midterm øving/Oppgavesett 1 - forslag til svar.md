
**Anbefalt tid:** 2 timer  
**Poeng:** 100

- **Del 1 (65p):** korte/predefinerte svar (MCQ, multiple response, T/F, korttekst)
- **Del 2 (35p):** skrive relasjoner/SQL (ER→relasjonsskjema, endre skjema, skrive/omskrive SQL)

### DEL 1 – Korte / predefinerte svar (65 poeng)

#### 1) (2p) Begrep

Hva er forskjellen på **schema** og **instance** i en database? Svar med én setning for hver.

> Et schema er hvordan en database/tabell skal se ut, mens en instance er en faktisk versjon av databasen på et gitt tidspunkt.

---

#### 2) (3p) Multiple choice – “hvorfor DBMS?”

Hvilke problemer var typiske i “fil-system”-tilnærmingen som DBMS prøver å løse? Kryss av **alle** som passer.  
A) Data redundancy / inconsistency  
B) Integrity problems  
C) Turing-komplett spørringsspråk  
D) Concurrent access problems  
E) Security problems

> A - Samme data lagret flere steder -> inkonsistens
> B - Uten sentrale constraints er det lett å få ugyldige data.
> D - Samtidige brukere kan overskrive hverandre uten transaksjoner/låsing
> E - Filsystemet mangler tilgangskontroll



---

#### 3) (3p) Nøkler

Vi har relasjonen `instructor(id, name, dept_name, salary)`.  
Hvilke av følgende er **alltid** supernøkler? Kryss av alle som passer.  
A) {id}  
B) {name}  
C) {id, name}  
D) {dept_name}  
E) {id, dept_name}

> A, C, E
---

#### 4) (4p) Relasjonsalgebra – grunnoperatorer

Match operator → beskrivelse (skriv f.eks. “σ = …”):

- σ, π, ×, ∪, −, ρ

>σ = seleksjon
π = projeksjon
× = cross product
∪ = union
− = set difference
ρ = rename

---

#### 5) (4p) RA → intuisjon (True/False)

a) π (projeksjon) fjerner alltid duplikater i RA. **TRUE**
b) SQL fjerner alltid duplikater med mindre du bruker ALL.  **FALSE**
c) σ (seleksjon) kan sammenligne attributter med hverandre.  **TRUE**
d) R ⋈θ S er definert som σθ(R × S). **TRUE**


---

#### 6) (5p) SQL – SELECT/FROM/WHERE

Gitt SQL:

```sql
SELECT dept_name
FROM instructor
WHERE salary > 85000;
```

Hvilke påstander stemmer? (kryss av alle)  
**A) Resultatet kan inneholde duplikater**  
B) Resultatet er sortert alfabetisk  
**C) DISTINCT ville kunne endret resultatet**  
D) WHERE kjøres etter GROUP BY  
E) Queryen er ugyldig uten ORDER BY

---

#### 7) (4p) SQL – NULL og treverdilogikk

Kryss av alle korrekte:  
A) `salary = NULL` er riktig måte å teste NULL på  
**B) `salary IS NULL` er riktig måte å teste NULL på**  
C) `NULL = NULL` evaluerer til TRUE i SQL  
D) **`5 < NULL` evaluerer til UNKNOWN**

> Alle sammenligninger med NULL gir UNKNOWN
---

#### 8) (5p) GROUP BY / HAVING

Du har:

```sql
SELECT dept_name, avg(salary)
FROM instructor
GROUP BY dept_name
HAVING avg(salary) > 42000;
```

Hvilke påstander stemmer? (kryss av alle)  
A) HAVING filtrerer før grouping  
B) WHERE kan ikke referere til avg(salary) direkte  
C) Alle attributter i SELECT uten aggregate må stå i GROUP BY  
D) HAVING kan fjernes uten å endre resultatet

---

#### 9) (5p) Nested queries – IN/EXISTS/SOME/ALL

Hvilken matcher best (velg ett alternativ per linje):

1. “finn rader der subquery-resultatet er tomt” → A) EXISTS B) NOT EXISTS C) IN
2. "x er større enn minst én verdi i mengden" → A) ALL B) SOME
3. "x er større enn alle verdier i mengden" → A) ALL B) SOME

---

#### 10) (4p) JOIN – NATURAL JOIN-felle

Hvorfor kan `NATURAL JOIN` gi “for få” rader i noen tilfeller? Svar kort.


---

#### 11) (4p) Subquery vs join (korttekst)

Hva er en **korrelert subquery**, og hvorfor kan den bli treg? (2–3 linjer)

---

#### 12) (4p) ACID (match)

Match A/C/I/D til forklaring:

1. “endringer overlever crash etter commit”
2. "alt-eller-ingenting"
3. "samtidige transaksjoner ser ikke halvferdige resultater"
4. "constraints bevares (konsistent tilstand)"

---

#### 13) (6p) Constraints (multiple response)

Hvilke constraints/konsepter stemmer? Kryss av alle som passer.  
A) PRIMARY KEY-attributter kan være NULL  
B) UNIQUE kan tillate NULL (DBMS-avhengig, men ofte tillatt)  
C) FOREIGN KEY kan peke til samme tabell (self-reference)  
D) CHECK(P) kan brukes til å håndheve en lokal regel på en tabell  
E) DROP TABLE påvirkes aldri av foreign keys

---

#### 14) (4p) Views

Kryss av alle korrekte:  
A) WITH-definisjoner lever “globalt” i databasen  
B) Views blir værende til de droppes  
C) Materialized view lagrer resultatet fysisk  
D) Vanlige views lagrer alltid resultatet fysisk


---

#### 15) (6p) Autorisasjon (kort + MCQ)

a) Nevn **to** privileges for data (READ/INSERT/UPDATE/DELETE).

b) Hvilken SQL-kommando brukes for å gi rettigheter?  
A) ALLOW B) GRANT C) PERMIT D) AUTHORIZE

---

#### 16) (6p) ER → nøkler (multiple choice)

Du har en relationship set R mellom entity sets A og B.  
Hvis relasjonen er **many-to-many**, hva er typisk primary key i relasjonstabellen?  
A) PK(A)  
B) PK(B)  
C) PK(A) ∪ PK(B)  
D) en ny surrogate key må alltid innføres

---

#### 17) (6p) Weak entities (korttekst)

Hva er en **weak entity**, og hva består nøkkelen av når den oversettes til relasjonsmodell?

---

#### 18) (6p) Funksjonelle avhengigheter & normalisering (multiple response)

Kryss av alle korrekte:  
A) En FD X → Y betyr at X bestemmer Y unikt  
B) BCNF krever at for alle ikke-trivielle FD-er, er venstresiden en superkey  
C) 3NF er strengere enn BCNF  
D) Det er ikke alltid mulig å få både BCNF og dependency preservation samtidig

---

### DEL 2 – Skrive relasjoner / SQL (35 poeng)

#### Oppgave 1 (12p) ER-beskrivelse → relasjonsskjema

Du modellerer et lite **bolig-rating-system**:

- **Student**(StudentID, Name)
    
- **Address**(AddressID, Street, City)
    
- En student kan skrive **Review** av en adresse.
    
- Hver review har attributtene: Rating (1–5), Comment (tekst), CreatedAt (tidspunkt).
    
- En student kan maks ha **én** review per adresse.
    
- Det finnes også **Landlord**(LandlordID, Name). En landlord kan eie mange adresser, men hver adresse har **akkurat én** landlord.
    

**Oppgave:** Lag et relasjonsskjema med:

- tabeller + attributter
    
- primærnøkler
    
- nødvendige fremmednøkler
    
- eventuelle UNIQUE-constraints som trengs for “maks én review per student per adresse”.
    

_(Skriv også 1–2 linjer om antakelser hvis du må.)_

---

#### Oppgave 2 (11p) “Endre skjema” (DDL)

Du starter med:

```sql
CREATE TABLE Student(
  StudentID INT PRIMARY KEY,
  Name      VARCHAR(50) NOT NULL
);

CREATE TABLE Address(
  AddressID INT PRIMARY KEY,
  Street    VARCHAR(80) NOT NULL,
  City      VARCHAR(40) NOT NULL
);

CREATE TABLE Review(
  StudentID INT,
  AddressID INT,
  Rating    INT,
  Comment   VARCHAR(300),
  CreatedAt TIMESTAMP
);
```

Gjør følgende endringer (skriv SQL):

1. (3p) Legg inn PK/UNIQUE som sikrer **maks én review per (StudentID, AddressID)**
    
2. (4p) Legg inn FOREIGN KEYs fra Review til Student og Address
    
3. (2p) Legg inn CHECK som sikrer `Rating` mellom 1 og 5
    
4. (2p) Lag en view `AddressAvgRating(AddressID, AvgRating)` som viser snittrating per adresse (adresser uten reviews skal **ikke** være med).
    

---

#### Oppgave 3 (12p) SQL – skriv/omskriv query

Bruk samme skjema som i oppgave 2.

a) (6p) Skriv en SQL-spørring som finner **alle adresser i Trondheim** som har **minst 3 reviews** og **avg rating ≥ 4.0**. Returner `AddressID, Street, AvgRating, NumReviews`.

b) (6p) Omskriv denne nested-queryen til en variant som bruker JOIN (der det passer):

```sql
SELECT a.AddressID, a.Street
FROM Address a
WHERE a.AddressID IN (
  SELECT r.AddressID
  FROM Review r
  WHERE r.Rating = 5
);
```