### What digital signatures give you
- Authenticity: who sent it
- Integrity: message wasn't modified
- Non-repudiation: a third party (judge) can decide who signed (unlike MACs)

High-level pipeline
message -> hash -> sign(hash) with private key -> verify(signature) with public key

### Digital signatures vs MACs
MACs need a shared secret, signatures are public/private keys.
Signatures are publicly verifiable + transferable (anyone can verify)
Signatures simplify key management when one sender has many receivers.
MACs are shorter and 2-3x more efficient.

### Signature scheme: the 3 algorithms
1. KeyGen -> private signing key KS, public verification key KV
2. Sign(m, KS) -> signature σ
3. Verify(m, σ, KV) -> true/false

Correctness: valid signatures verify
Unforgeability: infeasable to produce a fresh valid (m, σ) without KS, even with access to a chosen-message snigning oracle (strong modern notion)

Attack goals:
- Key recovery
- Selective forgery (forge a chosen target message)
- Existensial forgery (forge any new message)
- Modern target: existensial unforgeability under chosen message attack.

### RSA signatures
KeyGen (same as RSA encryption)
n = p q
choose e, d such that ed = 1 (mod φ(n) 
KS = (d, p, q), KV = (e, n)

Sign
σ = H(m)^d mod n

Verify:
compute h' = H(m)
accept if σ^e mod n = h'

hash/encoding choices
Standard hash like SHA-256
Full domain hash (map into 1..n)
RSA-PSS (probabilistic encoding)

