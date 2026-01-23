# Korteste vei fra en til alle
### J1 - Varianter av problemet
1. SSSP - Single Source Shortest Path
	- Finn kortest vei fra en kilde s til alle noder
2. Single destination
	- Korteste vei fra alle noder til en node t (SSSP i transponert graf)
3. Single.pair
	- Finn korteste vei fra s til t
	- Løses ofte som en SSSP
4. All-pairs-shortest path (APSP)
	Finn korteste vei mellom alle par
	(Floyd Warshall)

### J2 - Strukturen til korteste vei-problemet
Korteste vei fra s til v består en sekvens av kanter som gir minst total vekt, og korteste vei er alltid enkel hvis den finnes.

### J3 - Negativ sykel
Hvis det finnes en sykel med negativ totalvekt, kan man gå rundt den uendelig mange ganger, avstanden går mot negativ uendelig, som gjør at korteste vei ikke eksisterer.

Men, en en korteste **enkel** vei kan fortsatt finnes.

### J4 - Forholdet mellom korteste enkle vei og lengste enkle vei
Korteste enkle sti i en graf med positive vekter = lengste enkel sti i en graf der vektene er endret til negative.

NP-hard

### J5 - Representere et korteste-vei-tre
BFS tre, men basert på kantvekter

Korteste vei tre har:
- Parent[v], node som kommer før v
- d[v] korteste avstand fra s til v
- parent[]-pekere gir stien til hver node

### J6 - Relaxation
Prøve å forbedre den beste distansen du kjenner til en node

Hvis man vet den beste kjente avstand til u og at det går en kant u -> v med kostnad w(u, v)

Så sjekker man om distansen til v blir bedre om man går via u


### J7
### J8 - Bellman - Ford
[[Algoritmer i pensum TDT4120]]
### J9 DAG-shortest-path
[[Algoritmer i pensum TDT4120]]

### J10 - Kobling mellom DAG-SP og dynamisk progg
En topologisk sortert graf er egentlig en delinstansgraf, akkurat som i dynamisk programmering.

Relax = samme som DP-overgang.

DAG-SP er DP på grafer.

### J11 - Dijkstra
[[Algoritmer i pensum TDT4120]]
Med fib heap tar de tO(E + V log V)
Binærhaug: O( E log V)


### J12 - Korteste vei som lineært program
Fordi en sti kan modelleres som 1 enhet flyt fra startnode _s_ til sluttnode _t_. Flytbevaringsreglene tvinger løsningen til å bli en gyldig sti, og å minimere total vekt gjør at stien blir den korteste.

Korteste‐vei kan formuleres som et flytproblem.  
Flytproblemer kan uttrykkes som lineære programmer.



"En sti kan modelleres som flyt.  
Flytbevaringskrav gjør flyten til en gyldig vei fra s til t.  
Ved å minimere total vekt får vi den korteste veien.  
Derfor kan korteste vei formuleres som et flytproblem, og dermed som et lineært program."