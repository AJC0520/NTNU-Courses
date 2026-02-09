### Why public-key crypto exist
Problem with symmetric-crypto is that both parties must already share a secret key (hard key distribution)

#### Public-key crypto (asymmetric)
- You publish a public key, which anyone can encrypt to you / verify your signatures.
- You keep a private key secret, which only you can decrypt or sign

There are two key advantages vs symmetric
1. Simpler key management, no confidential key transport is needed
2. Enables digital signatures, which provides authenticity + integrity

![[file-20260130112929317.png]]
![[file-20260130112934206.png]]

### One-way functions & trapdoors
One-way functions are easy to compute but hard to invert. Examples:
- Multiply big primes -> inverse is factorization
- Exponentiation -> inverse is discrete log
- Hashing -> "seems" one-way

Trapdoor one-way function are functions which are hard to invert unless you know secret extra info (trapdoor). Example:
- modular squaring $f(x) = x^{2} \; mod\; n$ where $n=pq$
- If you can take square roots mod n you can factor n.
- Trapdoor = knowing p, q

### How public-key encryption is actually used (hybrid encryption)
Public-key operations are expensive, so we actually do hybrid encryption.

1. Sender picks random symmetric key, K
2. Encrypt k with the receiver's public key. $C_1 = E(k, PK_{A})$
3. Encrypt message with fast symmetric crypto: $C_2 = E_{s}(M, k)$
4. Send ($C_{1}, C_{2}$). Receiver decrypts k with private key, then decrypts M.

### RSA
RSA is a public-key scheme for encryption and signatures based on the integer factorization problem.

#### RSA algorithms:
Key generation:
1. Choose large random distinct primes p, q
2. n = pq
3. Choose e such that gcd(e, $\varphi$(n)) = 1
4. Compute d $\equiv e^{-1} \; (mod\; \varphi(n))$
5. Public key: (n, e)
6. Private key: (p, q, d)

Where $\varphi(n) = (p-1)(q-1) for\; n=pq$


##### Encryption / decryption
Encrypt: $C = M^{e}\; mod\; n, \; for\; 0 < M < n$
Decrypt: $M = C^{d}\; mod\; n$

Real messages must be encoded + padded into an integer M (padding is crucial)

##### Numeric example:
p = 43, q = 59 => n = 2357 => $\varphi(n) = 2436$
Choose e = 5, then d = 1949
Encrypt M = 50 => C = $50^{5}$ mod 2537 = 2488
Decrypt $2488^{1949} mod\; 2537 = 50$

### Implementation notes
#### Generating primes p,q
Practical method: pick random odd r of desired length, test primality else try next odd. Sizes usually recommended at least 1024 bits per prime

#### Are there enough primes?
Prime number theorem gives density  ~ 1 / ln(x) for 1024-bit numbers, about 1 in 710 is prime since ln($2^{1024}) = 710$

#### Choosing e and d
Random e is best, but small e is faster.
e = 3 is sometimes used but can be risk for small/unpadded messages.
Common choice e = 2^16 + 1 = 65537
Avoid too-small d: d should be at least sqrt(n) to avoid known attacks.

#### Fast modular exponentiation (square and multiply)
Compute $M^{e}\;mod\;n$ efficiently using exponent bits. Cost idea: about one squaring per exponent bit and half the bits cause a multiply on average.

#### Faster decryption with CRT
Compute separately mod p and mod q, then recombine using CRT. 4x less computation, up to 8x if parallelized

### Padding
Raw RSA is insecure (determnistic, malleable, guessable) Attacks: dictionary building, guessing-and-checking, Håstads attack

#### Håstad's attack (broadcast, no padding)
If same message m is sent to 3 recipents with e = 3
$$c_{i} = m^{3}\;mod\;n_{i}$$
Use CRT to recover $m^{3}$ as an integer, then cube-root to get m.

##### Example padding format: PKCS#1 v.15-style block
Block: `00 02 PS 00 D` where PS is a random nonzero bytes $\geq 8\;bytes$ 
The idea is to force structure + randomness so ciphertexts aren't predictable.

##### OAEP (Optimal Asymmetric Encryption Padding)
OAEP adds k0 random bits and k1 redundancy bits (typical 128/128) using hash functions G, H.
OAEP encoding is invertible without secrets, its not encryption by itself.
![[file-20260130124713352.png]]


### What breaking RSA reduces to
If an attacker factors n -> gets p,q -> can compute d and decrypt, there is an RSA problem formalization. It's unknown if RSA problem is exactly as hard as factoring, but Miller Theorem deriving  d from (e, n) is as hard as factoring n.

#### Miller's algorithm (get d => factor n)
Write $ed-1=2^{v}u$ with u odd.
Look at sequence $a^{u}, a^{2u},...,a^{2^{v}u}\;(mod\;n)$ for random a
Since $a^{2^{v}u}=a^{ed-1}\equiv 1\;(mod\;n)$, you expect to find a non-trivial square root of 1 mod n, which reveals factors. Repeat with a new a if needed.


### Side-channels attacks (math is fine, implementation leaks)
Timing, power analysis, fault analysis

Timing attack on square-and-multiply
Each bit ei controls wheter a multiply happens, multiply makes that iteration slower, so timings can leak exponent bits.

Countermeasures:
- constant-time. Do dummy multiply even when ei = 0
- montgomery ladder. constant-time structure + helps against some faults
- randomize RSA message to reduce differential timing analysis.












