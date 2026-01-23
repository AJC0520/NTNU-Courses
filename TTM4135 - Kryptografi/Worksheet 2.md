1
a) symmetric ciphers.
	secret key used for both encryption and decryption. hard to share safe.
b) asymmetric ciphers
	uses a key pair (public for encryption and private for decryption)
b) ciphertext only attack, attacker only has access to encrypted text.
	known-plaintext: attacker knows some pair of plaintext and corresponding ciphertext.
		chosen-plaintext attack: attacker can chose plaintext and see corresponding ciphertext.
			chosen-chipertext attack: attacker can chose ciphertext and get it decrypted.
c)
	assume an attacker has complete knowledge of how the cryptosystem works. the decrypt. meaning that a secure system never should be based on a secret algorithm.
d)
	transportation
		characters in plaintext are mixed up with eachother, fixed period d, and permutation f. letters are the same.
	substitution:
		each letters is swapped with a specific letter.
e)
	synchrounous stream cipher
		keystream is generated independently of the plaintext. sender and receiver needs to be in sync.
f)
	one-time pad
		key is a truly random sequence of characters all independently generated. provides perfect secrecy since  cipher and plain are uncorrelated. 
		key is as long as message and used only once. theorethical unbreakable but not possible.

2.
1.
	Caesar cipher:
		25 possible keys.
	25 / 10000 = 0.0025s
		25/ 10^10 = 2.5*10^-9

Vigenere cipher with 10-character key.
- 26^10 = 1.4 * 10^14 keys
-  10^14 / 10000 = 14116709565 sek = 447 år
- 10^14 / 10^10 = 3.9 timer

simple substitution cipher:
- 26! keys
- en pc = 1.3* 10 ^15 år
- dedikerte chips = 1.3 milliarder år

3
FAITH
- Solve for P, then find constants a b and n by brute force.

4.
key = EWVAMDP

5.
1 = transposition
	transposition only moves the letters around so the graph is similar to the one of the most common letters
3 = simple random substitution
	swaps out letters, so should have the same tops but just at different letters
2 = vigenere
	tries to flatten the curve

6
a) (4/19, 5/18)
b) EWNX
c) WITH

7
* 7 1 1 24
* NOWISTHETIMEFORALLGOODMENTOCOMETOTHEAIDOFTHEIRCOUNTRYZ

9.
Although S2 is derived from the image, it is uniformly random when S1 is unknown, and therefore statistically independent of the image.
