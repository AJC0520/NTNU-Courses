### Task 1
#### a) confusion and diffusion

**confusion** - hide the connection between key and ciphertext. If you change the key slightly, the output should become very different. Attacker should not be able to se patterns that shows the key. Achieved by S-boxes and non-linear operation

**diffusion** - spread information from plaintext over the entire ciphertext. If you change 1 bit input, many bits changes in output. No bit in output should depend on just one bit in input. Achieved by permutations, and linear mixes (XOR, matrix)

#### b) product cipher and iterated cipher:

**product cipher** - combines simple cryptographic operation for security. Each operation alone is weak, but is strong together. Typical combination is confusion and diffusion. DES, AES.

**iterated cipher** - does the same round multiple times. One round gives a little security, but many rounds give high security. Each round usually uses a round key and substitution + permutation. 

#### c) Feistel cipher
Structure for encryption for blockciphers. The same structure is used for both encryption and decryption. 

**How it works**:
1. Each block is split in two L0 and R0
2. For each round:
	Li + 1 = Ri
	Ri+1 = Li XOR F(Ri, Ki)

F = round function
Ki = round key

F does not need to be invertible, yet the whole cipher is still invertible.
DES

#### d) Substitution-permutation network
Cipher structure used in modern block ciphers.

Each round is a product of:
1. Substitution (S-box)
	- Non-linear, confusion, small bits are swapped with others
2. Permutation (P-layer)
	- Linear shuffling, diffusion, spread bits over the entire block, AddRoundKey

This is repeated multiple times -> iterated cipher.

Strong because S-box ruins linear patterns and permutation spreads the changes. With many rounds this gives an avalanche-effect.

#### e) ECB mode
Mode for block cipher, not secure.
Works by splitting the message in blocks, encrypt each block independently
Problematic since patterns in plaintext leaks through, which means that similar blocks will get encrypted similarly and the structure will be shown.
![[Pasted image 20260123130455.png]]

#### F) CBC mode
Mode for block cipher. Fixes main issue in ECB.
Before each block is encrypted, it is XOR'd with the previous ciphertext-block. 
![[Pasted image 20260123130504.png]]
IV = random initialization value.
Same plaintext-block will give different ciphertext and patterns are removed. Gives semantic security with a random IV.
- IV needs to be random and unique
- IV does not need to be secret.

Sequential, so cant be done in parallel.  Gives no authentication alone. 

Error propagation is also a problem, one bit error in C_i destroys the entire P_i and one bit in P_{i+1}

#### g) CTR mode
Block cipher mode that makes a block cipher into a stream cipher.

Instead of encrypting plaintext, you encrypt a counter. 
![[Pasted image 20260123130952.png]]

nonce = unique start value
counter = increases for each block

There are no pattern-leaks and you can encrypt in parallel. No padding is necessary. 

It is important to not reuse (K, nonce). If the same keystream is used twice:
C1 XOR C2 = P1 XOR P2

Also has error propagation, bit error in ciphertext -> same bit error in the plaintext. No spread.

#### h) true random generator and pseudorandom generator

**TRNG** -  true randomness, retrieved from the real world. Based on physical processes and it is unreliable even if you know the system. Slower. Used to generate keys and seeds to PRNG

**PRNG** - Algorithmic randomness. Starts from a seed, but is fully deterministic. Looks random but isn't. Fast. Used for cryptography in practise.  (CTR, stream ciphers)

---
### Task 2
a)
Two-key Triple DES = 112-bits key.
$2^{112}$ possible keys

With brute force you have to test half on average:
$2^{111}$ tries

If the computer can test $2^{55}$ keys per second:
$\frac{2^{111}}{2^{55}} = 2^{56}$ seconds = $2^{31}$ years

b)
	 About 80 years.

---
### Task 3
If encryption is linear, decryption is also linear. 
The attacker can take the 128 simplest ciphertext (1 1-bit and rest 0) and ask the decryption oracle of every one of them. Now the attacker has 128 plaintext blocks saved.

Since the system is linear, the attacker can decrypt any ciphertext by XORing the decryption of the single bit versions (which the attacker already have)

---
### Task 4
#### a) substitution-permutation
$$K_{1} = 11000011,\; K_{2} = 10000111$$
##### Round 1:
P XOR K1
01010101 $\oplus$ 11000011 = 10010110
Substitution gives 01000001 and permutation gives 00001010

##### Round 2:
C1 XOR K2
00001010 $\oplus$ 10000111 = 10001101
Substitution gives 01101100 and permutation gives 11100010

C = 11100010


#### b) feistel cipher


### Task 5
Double encryption:
$$C = E_{K_{2}}({E_{K_{1}}}(P)), \;\;\; K_{1},K_{2} \in \{0, 1\}^{128}$$
A meet in the middle attack given one plaintext-chipertext pair (P, C):

1. Forward table:
	For every $2^{128}$ $K_{1}$ compute $X = E_{K_{1}}(P)$, store (X, $K_{1}$) in a lookup table keyed by X.
2. Backward search:
	For every $K_{2}$ ($2^{128}$) compute $Y=D_{k_{2}}(C)$
	Check whether Y appears in the table. Any match gives a candidate ($K_{1},K_{2}$). In practice you verify candidates using a second plaintext-ciphertext pair to eliminate false matches.


#### Computation required:
- Building the table: $2^{128}$ AES encryptions
- Searching $2^{128}$ AES descryptions
- Total about:
	- $2^{128} + 2^{128} \approx 2^{129}$ AES operations

Work is roughly $2^{129}$ AES calls

#### Storage required:
Store about $2^{128}$ intermediate values
Each intermediate X is 128 bits = 16 bytes
Need to keep the associated K1 (16 bytes)
$2^{128} \cdot 32\; bytes=2^{128} \cdot 2^{5}=2^{133}$

### Task 6
#### a) length of ciphertext
AES = 128 bit block size
M1 = 128 bits
M2 = 72 bits

E(M1) = 128 bits
Split so first 72 bits = C2
last 56 bits = J
E(M1) = C2 || J

M2 is only 72 bits
Take 56 stolen bits J
M2 || J
C1 = E(M2 || J)
Send (C1, C2)

So length is the same as the original message (200 bits)

#### b) how to decrypt
Receiver gets (C1, C2)
C1 = 128 bits
C2 = 72 bits

Decrypt C1:
$X = D_{K}(C_{1})$

Then X is 128 bits
X = M2 || J

Split: first 72 bits of X = M2
Last 56 bits of X = J

Recover M1
Y=C2​ || J
M1 = Dk(Y)

M = M1 || M2

#### Task 7
![[file-20260225110711030.png]]

























