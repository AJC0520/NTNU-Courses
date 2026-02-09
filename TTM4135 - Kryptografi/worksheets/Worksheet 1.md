### Task 1
#### a) confidentiality
Only authorized people can read the information.

#### b) Integrity
Data cannot be altered or if its been altered it is detectable. Ensures that the message is correct in its whole form.

#### c) Availability
Systems or data is accessible and usable when authorized users need it.

#### d) Entity authentication
Verifies who you are talking to, typically at the start of a session.

#### e) Data origin authentication
Verifies where a message came from, and that it wasn't forged.

#### f) non-repudiation
Provides evidence so a party cannot later deny an action (like sending/signing a message)

#### g) Group-generator
A number which can be used to get all the other numbers in a group.

#### h) Finite field
A field with a finite numbers of elements where all non-zero element has a multiplicand incerse.


### Task 2
#### a)
gcd(23, 29) = 1
#### b)
gcd(893, 703) = 19
#### c)
gcd(1045, 77) = 11

### Task 3
#### a) 
35 mod 31 ⇒ 35 = 31 · 1 + 4  

#### b)
3 mod 1000 ⇒ 3 = 1000 · 0 + 3  

#### c)
65 mod 21 ⇒ 65 = 21 · 3 + 2  

#### d)
236 mod 5 ⇒ 236 = 5 · 47 + 1  

#### e) 
123 mod 3 ⇒ 123 = 3 · 41 + 0  


### Task 4
#### a)  
$3^{-1} \mod 31 = 21$
#### b)
$21^{-1} \mod 91 =$ ingen invers  
#### c)
$39^{-1} \mod 195 = 176$


### Task 5
For addition: check for each number a if there exist some number a, if there exist some number b  so that a + b = 0 mod (n)

| a \ b | 0     | 1     | 2     | 3     | 4     |
| ----- | ----- | ----- | ----- | ----- | ----- |
| 0     | **0** | 1     | 2     | 3     | 4     |
| 1     | 1     | 2     | 3     | 4     | **0** |
| 2     | 2     | 3     | 4     | **0** | 1     |
| 3     | 3     | 4     | **0** | 1     | 2     |
| 4     | 4     | **0** | 1     | 2     | 3     |
There is a zero in every row so this works.

For multiplication: check that for each non-zero number a, if there exist a number, b so that a x b = 1 (mod 5)

| a \ b | 0   | 1     | 2     | 3     | 4     |
| ----- | --- | ----- | ----- | ----- | ----- |
| 0     | 0   | 0     | 0     | 0     | 0     |
| 1     | 0   | **1** | 2     | 3     | 4     |
| 2     | 0   | 2     | 4     | **1** | 3     |
| 3     | 0   | 3     | **1** | 4     | 2     |
| 4     | 0   | 4     | 3     | 2     | **1** |
There is a 1 in every non-zero row, so this works.

$\mathbb{Z}_{5}$ is a field


### Task 6
#### a)
$\mathbb{z}^{*}_{11}$, since 11 is a prime there are 11 - 1 = 10 elements in this field. 7 is a generator because it powers modulo 11 produces all non-zero elements of $\mathbb{Z}_{11}$
#### b)
$\mathbb{z}^{*}_{12}$, since 12 is not a prime we need to find the co primes.

gcd(x,12) = 1 => x $\in$ {1,5,7,11}
So there are 4 elements.

All order of its element is 1 (mod 12) so there is no generator.

### Task 7
If we define $GF(2^{8})$ by representing elements as 8-bit strings using addition = XOR and multiplication = multiplication modulo $2^{8}$, then the structure is not a field.

What must hold for a field?
For a field: every non-zero element must have a multiplicative inverse, and there must be no zero divisors.

$2^{2^8} = 256$, is not prime. Modular arithmetic modulo 256 does not guarantee inverses.
