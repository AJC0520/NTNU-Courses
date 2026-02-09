Discrete-log cryptosystems are the main alternative to RSA/factoring.
On elliptic curves you get the same security with smaller keys -> faster /less bandwidth

### Diffie-Hellman (DH) key exchange
Goal is for Alice + Bob to agree on a shared secret using only public communcation

Public parameters: generator g of a group G of order t
Secret: Alice chooses a, Bob chooses b (random, 0 a,b < t)

Protocol:
![[file-20260209111038921.png]]

Alice sends A = $g^{a}$
Bob sends B = $g^{b}$
Shared secret:
- Alice computes Z = $B^{a} = g^{ab}$
- Bob computes Z = $A^{b} = g^{ab}$

If attacker can compute discrete logs (recover a from g^a). DH breaks.
The problem compute `g^(ab)` given `g, g^a, g^b` is the computational Diffie-Hellman (CDH problem)

In practice Z becomes a symmetric key via a KDF (hash-based) before using AES

### Authenticated DH (fixes man-in-the-middle)

Basic DH has no identity binding -> vulnerable to MITM. The fix is to sign the DH values + identities
![[file-20260209111804542.png]]

Bob sends $B = g^{b}$ plus a signature tying (Bob, B, Alice, A)
Alice replies with signature tying (Alice A, bob, B)
Then they compute the same Z

### Static vs ephemeral DH
Ephemeral DH: fresh a, b per session then discard.
Static DH: long-term private keys xA, xB with public keys $yA=g^{xA}, yB=g^{xB}$ giving shared secret $S=g^{xA xB}$ (same until keys change)
You can also combine static + ephemeral ideas

### ElGamal encryption (DH turned into encryption)
KeyGen (receiver Bob)
- Choose prime p, generator g of $Z_p*$
- Choose private x
- Public key: (p, g, $y=g^{x}\; mod \;p$)

Encrypt message M (0 < M < p):
- Choose random k
- CIphertext:
- $C = (C1, C2)= (g^{k}\; mod\; p, M\cdot y^{k}\; mod\; p$

Decrypt with private key x:
$M = C2 \cdot C1^{-x}\; mod \; p$

It works because of the cancellation idea
$$y^{k} = (g^{x})^{k} = g^{xk}$$
and 
$$C1^{-x} = (g^{k})^{-x} = g^{-xk}$$
cancels, leaving M

### Elliptic curves (EC) basics
Curve example form:
$$y^{2} = x^{3} + ax + b + (mod\; p)\; over \; Z_{p}$$

- Points on the curve + an identity point 0 form a group with an addition operation
- Given P and generator G, find k such that P = [k]G (scalar multiplication)
- Uses double-and-add (analogy to square-and-multiply)
- Rules for special cases (0, opposite points), otherwise compute slope then x3, y3 for R=P+Q
- Short Weierstrass (common), Montgomery (constant-time-friendly), Edwards (fast ops).
- Best known EC discrete log algorithms are exponential (no known sub-exponential like for factoring / finite-field dlog), so EC achieves same security with much smaller parameters.
- ~128-bit symmetric ≈ 3072-bit RSA ≈ 256-bit EC group size.