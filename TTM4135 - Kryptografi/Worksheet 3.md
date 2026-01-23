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
Cipher structure used in modern blockciphers.

Each round is a product of:
1. Substitution (S-box)
	- Non-linear, confusion, small bits are swapped with others
2. Permutation (P-layer)
	- Linear shuffling, diffusion, spread bits over the entire block, AddRoundKey

This is repeated multiple times -> iterated cipher.

Strong because S-box ruins linear patterns and permutation spreads the changes. With many rounds this gives an avalanche-effect.



