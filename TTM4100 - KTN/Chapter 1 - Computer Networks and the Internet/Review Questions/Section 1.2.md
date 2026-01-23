#### List four access technologies. Classify each one as home access, enterprise access, or wide-area wireless access.

- Digital Subscriber Line (DSL)
	- Home access
- Ethernet
	- Enterprise access
- Fiber-to-the-home (FTTH)
	- Home access
- 4g/5g Cellular networks
	- Wide-area wireless access

#### Is HFC transmission rate dedicated or shared among users? Are collisions possible in a downstream HFC channel? Why or why not?

Hybrid Fiber Coaxial (HFC) transmission rate is shared among all users connected to the same local coaxial segment. This means that all available bandwidth is divided among users and the more users simultaneously, the less bandwidth is available per user.

Collisions are **not** possible in downstream HFC channel. This is because in a HFC network, the downstream channel (from ISP to users) operates as a broadcast channel. Data is sent from the headend to all connected users simultaneously, and each users modem filters out data not intended for it. Since only the headend transmits downstream data, there is no risk of multiple devices attempting to transmit at the same time.


#### What access network technologies would be most suitable for providing internet access in rural areas?

Satellite would provide wide coverage in remote areas where it is difficult to establish physical infrastructure. (starlink)


#### Dial-up modems and DSL both use the telephone line (a twisted-pair copper cable) as their transmission medium. Why then is DSL much faster than dialup access?

DSL is much faster than dial-up modems because it uses higher frequencies on the telephone line (beyond the 0-4 kHz voice range) which enables more data to be transmitted. It also uses advanced modulation techniques and allows simultaneous voice and data transmission, unlike dial-up which is limited to the narrow voice band and simpler technology.

#### What are some of the physical media that Ethernet can run over?

- Twisted Pair Copper Cables which is commonly used in home and office nettworks.
- Fiber Optic Cables, ideal for high-speed, long-distance connections.
- Coaxial cables, used in older ethernet standards.

#### HFC, DSL, and FTTH are all used for residential access. For each of these access technologies, provide a range of transmission rates and comment on whether the transmission rate is shared or dedicated.

- HFC
	- Transmission rates: Down (100mbps to 1gbps), Up (10mbps to 100mbps)
	- Shared, speed may decrease with higher usage
- DSL
	- Transmission rate:
		- ADSL: Down (24mbps), Up (1-3mbps)
		- VDSL: Down(100mbps), Up (10-50mbps)
	- Each user has a dedicated line to the DSLAM, performance may degrade with distance from the CO
- FTTH
	- Transmission rates:
		- GPON: Down (2.5gbps), Up (1.25gbps)
		- XGS-PON, 10gbps both ways
	- Bandwidth is shared


#### Describe the different wireless technologies you use during the day and their characteristics. If you have a choice between multiple technologies, why do you prefer one over another?

* WiFi (used at school and home)
	* Operates on 2.4GHz and 5GHz with speed ranging from 100mbps to 1gbps and a 20-50m range

* 5G (used on mobile phone outside of home)
	* Speeds ranging from 100mbps to 1gbps, used for wide-area coverage, mobile calls and messaging. 

* Bluetooth
	* Speeds up to 2mbps, range 10-100meters
	* Used for connecting headphones

I often prefer 5g because of its reability.
