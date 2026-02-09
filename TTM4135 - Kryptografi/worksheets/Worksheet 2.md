### Task 1
#### a) Symmetric ciphers
- Uses the same **secret key** for both encryption and decryption.
- Key distribution is difficult since the key must be shared securely.

#### b) Asymmetric ciphers
- Uses a **key pair**:
  - Public key for encryption
  - Private key for decryption

#### c) Attack models
- **Ciphertext-only attack:** attacker has access only to ciphertext.
- **Known-plaintext attack:** attacker knows some plaintext–ciphertext pairs.
- **Chosen-plaintext attack:** attacker can choose plaintexts and obtain their ciphertexts.
- **Chosen-ciphertext attack:** attacker can choose ciphertexts and obtain their decryptions.

#### d) Kerckhoffs’ principle
- Assume an attacker has complete knowledge of how the cryptosystem works.
- Security must rely only on the secrecy of the key, **not on a secret algorithm**.

#### e) Transposition vs substitution
- **Transposition:** characters in the plaintext are rearranged using a fixed period \( d \) and permutation \( f \); letters remain the same.
- **Substitution:** each letter in the plaintext is replaced with another specific letter.

#### f) Synchronous stream cipher
- The keystream is generated independently of the plaintext.
- Sender and receiver must remain synchronized.

#### g) One-time pad
- The key is a truly random sequence of characters.
- The key is as long as the message and used only once.
- Provides **perfect secrecy** since ciphertext and plaintext are uncorrelated.
- Theoretically unbreakable, but impractical in real systems.

---
### Task 2

#### a) Caesar cipher
- Number of keys: 25  
- Time at 10 000 keys/s:  
  $\frac{25}{10\,000} = 0.0025$ s  
- Time at $10^{10}$ keys/s:  
  $\frac{25}{10^{10}} = 2.5 \times 10^{-9}$ s

#### b) Vigenère cipher (10-character key)
- Number of keys: \( 26^{10} \approx 1.4 \times 10^{14} \)
- Time at 10 000 keys/s:  
  \( \approx 4.47 \times 10^{2} \) years
- Time at \( 10^{10} \) keys/s:  
  \( \approx 3.9 \) hours

#### c) Simple substitution cipher
- Number of keys: \( 26! \)
- Brute force:
  - Single PC: \( \approx 1.3 \times 10^{15} \) years
  - Dedicated chips: \( \approx 1.3 \) billion years
---

### 3
- Given ciphertext **FAITH**, solve for the plaintext.
- Then find constants \( a \), \( b \), and \( n \) by brute force.
---
### 4
- Key: **EWVAMDP**
---
### 5
- **1:** Transposition  
  - Letter frequencies remain the same; graph looks similar to plaintext.
- **3:** Random simple substitution  
  - Same frequency peaks, but at different letters.
- **2:** Vigenère  
  - Frequency distribution is flattened.
---

### 6
#### a)
$$
\begin{pmatrix}
4 & 5 \\
19 & 18
\end{pmatrix}
$$
#### b)
EWNX
#### c)
WITH

---
### Task 7
- \( 7\ 1\ 1\ 24 \)
- NOWISTHETIMEFORALLGOODMENTOCOMETOTHEAIDOFTHEIRCOUNTRYZ

---

### 9
Although \( S_2 \) is derived from the image, it is uniformly random when \( S_1 \) is unknown, and therefore statistically independent of the image.
