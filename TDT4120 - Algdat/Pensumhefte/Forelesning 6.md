# Dynamisk Programmering
Dynamisk programmering er splitt og hersk + gjenbruk av delproblemer.

### F1 - Delinstansgraf
I splitt og hersk får du et av tre delproblemer

I dynamisk programmering får du en rettet asyklisk graf (DAG) fordi:
- Flere delproblemer peker til samme delproblem
- Dermed brukes samme delproblemer flere ganger.

For eksempel i fibonacci vil Fib(3) og Fib(2) dukke opp flere ganger.
En delinstansgraf viser alle avhengighetene i en graf, uten å dobble noe.

### F2 - Designmetoden dynamisk programmering
DP løses slik:

1. Definer delproblemene
	Hva er f(i,j)? -> Hva betyr det?
2. Finn rekurrensen
	Hvordan brukes små delproblemer til å bygge større?
3. Finn rekkefølgen
	I hvilken rekkefølge må vi løse delproblemene for at alt vi trenger er klart?
4. Velg top-down (memoisering) eller bottom-up (iterasjon)
5. Rekonstruer løsning

### F3 - Memoisering (top-down)
- En vanlig rekursiv løsning
- MEN, man lagrer resultatet første gang du beregner et delproblem
- Neste gang henter man det fra minnet

Dette kutter eksponentiell tid -> ned til polynomial
```
fib(n):
    if n in memo: return memo[n]
    memo[n] = fib(n-1) + fib(n-2)
    return memo[n]
```

### F4 - Bottom-up (iterasjon)
- Skriver om rekurrensen til en tabell
- Regner oppover fra de minste delproblemene til det største
- Ingen rekursjon i det hele tatt

```
dp[0] = 0
dp[1] = 1
for i = 2 to n:
    dp[i] = dp[i-1] + dp[i-2]
```


### F5 - Rekonstruere løsning
Hvordan man får løsningen, og ikke bare verdien

### F6 - Optimal delstruktur
Et problem har optimal delstruktur hvis en optimal løsning inneholder optimale delløsninger.

For eksempel korteste vei i graf uten negative sykluser. -> Optimale sti består av optimale delstier.

Rekkefølgeproblemer med avhengigheter har ikke optimal delstruktur.

### F7 - Overlappende delinstanser
- At man får samme delproblem flere ganger i rekursjonen
- Gir eksponentiell eksplosjon hvis man ikke lagrer resultatet

Fib(3) dukker opp mange ganger, DP kutter det ned til en gang
Hvis man ikke har overlappende delinstanser trenger man heller ikke dynamisk programmering.

### F8 - LCS og Stavkapping

##### Longest Common Subsequence (LCS)
LCS handler om å finne den lengste delsekvensen som finnes i begge strenger, uten krav om at bokstavene står etter hverandre. Bare i riktig rekkefølge.

X = ABCBDAB
Y = BDCABA

En LCS er : BCBA

A = [b, d]
B = [a,b,c,d]

```
If A[I] = B[J]:
	LCS[i,j] = 1 + LCS[i-1, j-1]
else:
	LCS[i,j] = max(LCS[i-1,j], LCS(I,j-1))
```

Gå gjennom hver rute, hvis kolonne og rad input er lik (b = b) ta horisontalen opp til venstre + 1 i den ruten. Om de ikke er lik, ta maks av den over og den til venstre.

|     |     | a   | b   | c   | d   |
| --- | --- | --- | --- | --- | --- |
|     | 0   | 0   | 0   | 0   | 0   |
| b   | 0   | 0   | 1   | 1   | 1   |
| d   | 0   | 0   | 1   | 1   | 2   |
![[Pasted image 20251124105208.png]]
db

Alle plasser man går diagonalt (hvor det er en match) er en del av en LCS løsning

Theta(m * n)

Løses altså med DP ved å fylle en tabell c[i][j] med regler basert på match/mistmatch. Kjøretid og plass er Theta(mn)

##### Stavkapping
Cutting rod for å maksimere profit
Lengde = 5
Verdier (index = lengde) [2,5,7,8]


|       | 0   | 1   | 2   | 3   | 4   | 5   |
| ----- | --- | --- | --- | --- | --- | --- |
| 1 (2) | 0   | 2   | 4   | 6   | 8   | 10  |
| 2 (5) | 0   | 2   | 5   | 7   | 10  | 12  |
| 3 (7) | 0   | 2   | 5   | 7   | 10  | 12  |
| 4 (8) | 0   | 2   | 5   | 7   | 10  | 12  |

![[Pasted image 20251124112234.png]]

### F1 - 0/1 knapsack
Du har:
- En ryggsekk med maks kapasitet W
- n gjenstander
- Hver gjenstand har:
	- verdi v[i]
	- vekt w[i]
- Du kan bare ta en gjenstand 0 eller 1 gang

Målet er å velge en delmengde av gjenstandene slik at den totale vekten er mindre eller lik W, og den totale vekten blir størst mulig. (Optimeringsproblem)

1. Knapsack' (rask)
2. Knapsack (klassisk DP versjon)


W = 8
n = 4
Verdi = [1,2,5,6]
vekt = [2,3,4,5]

							Vekt

|       |      | 0     | 1   | 2   | 3     | 4   | 5   | 6     | 7   | 8   |
| ----- | ---- | ----- | --- | --- | ----- | --- | --- | ----- | --- | --- |
| Verdi | Vekt | **0** | 0   | 0   | 0     | 0   | 0   | 0     | 0   | 0   |
| 1     | 2    | 0     | 0   | 1   | 1     | 1   | 1   | 1     | 1   | 1   |
| 2     | 3    | 0     | 0   | 1   | **2** | 2   | 3   | 3     | 3   | 3   |
| 5     | 4    | 0     | 0   | 1   | 2     | 5   | 5   | 6     | 7   | 7   |
| 6     | 5    | 0     | 0   | 1   | 2     | 5   | 6   | **6** | 7   | 8   |

`V[i][j] = max(V[i-1,j], V[i-1, j-j[i] + Verdi[i]]`

x1, x2, x3, x4
0, 0, 0, **1** // 8 -6 = 2
0, 0, **0, 1** // 2 er med i tredje rad, men er også i 2. Ikke inkluder
0, **1, 0, 1**  // 2 - 2 = 0
0, 1, 0, 1 // 0 er med i første rad, men også i 1. Ikke inkluder.

Profit = 8

O(n * W)

Denne metoden er bra når W er liten og når vektene er små tall.
Men dårlig når W er stor, siden tabellen blir enorm


Den alternative måten Knapsack'

DP-tabellen er basert på verdi (V)
"Hva er minste vekt som trengs for å oppnå verdi v"

DP[v]

v = total verdi
DP[v] minste vekt som gir verdi v

Kjøretid: O(n * V_max)

Bra når verdiene er små, men vektene er store



**Knapsack** bruker kapasitet som dimensjon i DP-tabellen → O(nW).  
**Knapsack′** bruker verdi som dimensjon i DP-tabellen → O(nV_max).  
Valg av variant avhenger av om W eller V_max er mest håndterlig.  
Begge er pseudopolynomielle, ikke polynomiske.

