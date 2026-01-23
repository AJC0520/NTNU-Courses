
### 1.1 A Nuts-and-Bolts Description (Infrastructure based Internet)

#### 🌐 Internet Basics and Structure
##### End systems (hosts)
- Include computers, smartphones and other connected devices
- Referred to as hosts or end-systems
- Connected through a network of links and switches.

##### Packet Switching
- Packet switches (like routers or link-layer switches) forward packets to their destination.
- The route/path = sequence of links and switches a packet traverses:

>[!NOTE]
> The analogy:
> - Packets = trucks
> - Links = roads/highways
> - Network = transportation system


##### Internet Service Providers (ISP)
- Types: Residential, corporate, university, WiFi, cellular.
- Lower-tier ISPs connect to upper-tier ISPs (national/international)
- ISPs connect end users to content providers and each other.

#### 📡 Protocols and Standards
##### Internet Protocol Suite (TCP/IP)
- TCP - transmission control protocol
- IP - internet protocol
- together they define how data is transmitted oer the internet

##### Standards and Governance
- Managed by the Internet Engineering Task Force (IETF)
- Documented as RFCs (Request for Comments) - there are nearly 9000.

---

### 1.2 A Services Description (Service Based Internet)
##### Internet Applications
- Examples: messaging, mapping, streaming, social media
- Distributed: run on end systems, not in the core of the network.
- To build such applications, developers write programs on end systems.

##### Socket Interface
- A socket is an interface between an application and the Internet
- It defines rules for:
	- Sending/receiving data
	- Specifying destination end systems.
- Applications use sockets to instruct the Internet to deliver data

##### Protocols
- Defines:
	- Message format
	- Message order
	- Actions upon sending/receiving or upon specific events.
- Enable communication between entities

---

### 1.3 The Network Edge
##### Definition
- End systems = devices at the edge of the network
- Include computers, smartphones, loT devices, etc
- Also called hosts
- Run application programs

##### Types of Hosts:
- Clients:
	- Examples: desktop, laptops, smartphones
	- Typically requests and consumes data
- Servers:
	- More powerful machines
	- Store and distribute content
	- Often located in large data centers
- Data Centers
	- Operated by large companies
	- Contain millions of servers worldwide
	- Provide scalability and high availability for Internet services.

---

### 1.4 Access Network
Connects an end system to the first router in the Internet. Its the first hop in the path to other end systems.

##### 1.4.1 DSL (Digital Subscriber Line)
- Delivered by the local telephone company (also acts as ISP)
- Components:
	- DSL modem (home ) <-> DSLAM (central office)
- Uses same line for data and voice via frequency division multiplexing (FDM)
- Splitters at both ends seperate signals.
- Asymmetric speeds: higher downstream than upstream
- Performance drops from distance from central office.
 ![[Pasted image 20250519151305.png]]

##### 1.4.2 Cable Internet
- Uses existing cable TV infrastructure
- Structure:
	- Fiber to neighborhood head-end
	- Coaxial cable to homes -> called HFC (Hybrid Fiber-Coax)
- Equipment:
	- Cable modem (home) <-> CMTS (Cable Modem Termination System)
- Shared medium: bandwidth shared with neighbors
- Downstream rates typically higher, affected by congestion
- Upstream also shared -> requires multiple access protocol to avoid collision.

![[Pasted image 20250519151402.png]]

##### 1.4.3 FTHH (Fiber to the Home)
- High-speed fiber optic broadband
- Gigabit per second speeds possible
- Two main architectures:
	- AON (Active Optical Network)
	- PON (Passive Optical Network)
		- Components:
			- OLT (Optical Line Terminator) <-> Splitter <-> ONT (home)
			- OLT <-> Telco router
			- ONT <-> Home router
		- Splitter replicates all packets to multiple homes

![[Pasted image 20250519151726.png]]


##### 1.4.4 5G Fixed Wireless
- New tech for high-speed home Internet via wireless
- Eliminates cabling from central office to home
- Data sent from base station to home modem using beamforming
- Modem connects to WiFi router for home access.


##### 1.4.5 Ethernet & WiFi (Enterprise & Home Access)
- Ethernet
	- Wired LAN tech, twisted pair copper
	- Speeds: 100mbps to 10gbps;
- WiFi
	- Wireless LAN tech
	- Shared speeds exceeding 100 mbps
- Home networks
	- Often combine broadband access (DSL, cable, fiber) with WiFi for internal use
---

##### 1.5 Physical Media
- Guided Media (signals follows a physical path);
	- Twisted pair copper wire
	- Coaxial cable
	- Optical fiber
- Unguided Media (Wireless, signal propagates through air/space)
	- Radio spectrum
	- Satellite channels
>[!NOTE]
>Instillation labor often cost more than the materials themselves -> multiple media types may be installed together to reduce future upgrade costs.

###### Guided Media:
- Twisted Pair Copper Wire
	- Two insulated copper wires twisted to reduce electromagnetic interference
	- Common in telephone networks and LANs
	- Category 6a: Up to 10gbps over short distances
	- Widely used for high-speed LANs
- Coaxial Cable
	- Two concentric copper conductors
	- Used in cable TV and cable Internet
	- Supports hundreds of Mbps
	- Can serve as a shared medium: multiple systems receive signals sent by others
	- Uses frequency division multiplexing: digital signals modulated to specify frequency bands and transmitted as analog signals.
- Optical fiber
	- Transmits light pulses as data
	- High data rates, low signal loss, resistant to interferance
	- Ideal for long-distance transmissions (backbone networks)
	- Coastly for short distance use

###### Unguided Media:
- Terrestrial Radio Channales
	- Used in wireless communication
	- Affected by:
		- Path loss
		- Shadow fading
		- Multipath fading
		- Interferance
	- Categories:
		- Short-range
		- Local-area
		- Wide-area
- Satelitte communication
	- Two types:
		- Geostationary Satellites (GEO)
			- Fixed above Earth
			- Covers large areas
			- High propagation delay
		- Low Earth Orbit (LEO)
			- Closer to earth
			- Move in robits
			- Require constellations (multiple satelittes) for full coverage
	- Offer high-speed connections, useful in remote-regions without traditional broadband.

---

##### 1.6 Packet Switching (Store and forward Transmission)
- Most routers use store-and-forward method:
	- Entire packet must be received before being fowarded
	- Incoming bits are buffered (stored) until the full packet is ready to send
- Transmission delay
	- For a single link:
		- Delay = 2L/R
		- L = packet length in bits, R = transmission rate in bps
	- For N links of rate R
		- Delay = N * (L/R)
- Routers have output buffers (queues) to hold packets before transmission
- Queuing delay occurs if the outbound link is busy
- Packet loss happens when buffer is full due to congestion.
>[!EXAMPLE]
>If incoming traffic exceeds 15 mbps for a brief moment,
>Congestion -> Queue buildup -> possible packet drop

![[Pasted image 20250520094450.png]]

- Routers uses forwarding tables to decide where to send packets
- Destination IP Addresses are used for lookup
- Routing Protocols (like OSPF, BGP) automatically configure these tables

---

#### 1.7 Circuit Switching
- Resources are reserved along the full path for the entire session
- Traditional telephone networks are an example
- No sharing with other sessions - dedicated circuit.

- Multiplexing techniques:
	- FDM (Frequency Division Multiplexing)
		- Frequency band divided into-fixed-width sub bands
		- Example: 4 bands of 4 kHz each
	- TDM (Time Division Multiplexing):
		- Time divided into frames, each with time slots for different users
		- Example: 4 time slots per frame
- ![[Pasted image 20250520095554.png]]
- Disadvantages
	- Inefficient if data isn't constantly sent (idle resources)
	- More complex and costly


| Feature         | FDM                        | TDM                             |
| --------------- | -------------------------- | ------------------------------- |
| Resource Shared | Frequency                  | Time                            |
| Allocation      | Permanent Bandwidth        | Repeating time slots            |
| Usage pattern   | Simultaneous transmission  | Alternating transmission        |
| Synchronization | Not required between users | Required to maintain time order |

#### 1.8 Networks of Networks
- Types of ISPs:
	- Global transit ISPs
		- Large international networks
		- Interconnect with Tier 1 ISPs
	- Regional ISPs
		- Connect access ISPs to global transit ISPs
	- Tier 1 ISPs
		- Can reach every network on the Internet without paying for transit
		- Peer with each other freely
- Peering
	- ISPs may peer to exchange traffic directly without cost
	- Helps reduce dependency on higher-tier ISPs
	- Tier 1 ISPs also peer with one another to maintain reachability.
- IXPs (Internet Exchange Points)
	- Facilities where multiple ISPs connect
	- Allow ISPs to bypass higher-tier ISPs
	- Improve routing efficiency and reduce costs
- Content Provider Networks
	- Large companies like Google, Meta, Microsoft build their own networks
	- Deploy data centers and private backbone networks
	- Benefits
		- Lower costs
		- Improved performance
		- Greater control over traffic routing
- ![[Pasted image 20250520101823.png]]
---
#### 1.9 Delay, Loss, Throughput
![[Pasted image 20250520103120.png]]
- Nodal processing delay
	- Time to process the packet header and check for errors
	- Typically in microseconds
	- Performed by routers
- Queuing delay
	- Time a packet waits in a queue before being transmitted
	- Varies with traffic load: more packets -> longer delay
	- Ranges from microseconds to ms
	- Related to traffic intensity $\frac{La}{R}$
		- If $\frac{La}{R} > 1$, queuing delay can grow very large.
- Transmission delay
	- Time to push all bits of a packet into the link
	- Formula: $\frac{L}{R}$
		- L = packet size in bits
		- R: transmission rate in bps
	- Usually in microsecond to ms
- Propagation delay
	- Time for bits to travel through the link (router to router)
	- Depends on:
		- Distance
		- Propagation speed (speed of light in medium)
	- Typically in milliseconds
>[!ANALOGY]
>Transmission delay = time to get all cars onto the highway
>Propagation delay = time for cars to reach destination

- Traffic intensity
	- Defined as $\frac{La}{R}$ 
		- L = packet length (bits)
		- a = average packet arrival rate (bps)
		- R: transmission rate (bps)
	- If $\frac{La}{R} \le 1$ = stable delays
	- If $\frac{La}{R}>1$ = severe congestion, infinite queuing.
![[Pasted image 20250520103137.png]]
- Traceroute Utility
	- Used to measure end-to-end delay and identify network path
	- Sends packets with incrementally increasing TTL
	- Reports round-trip time (RTT) for each router hop
	- If a response is not received, shows asteriks *
	- Helps diagnose:
		- Routing problems
		- Latency issues
		- Packet loss
---

#### 1.10 Throughput
- Definition:
	- Throughput is the rate at which the destination host receives data.
	- Formula:
		- $Average Throughput = \frac{F}{T} [bits/sec]$
		- F = file size in bits
		- T = time it takes to transfer the file
- Types of throughput:
	- Instantaneous throughput: rate at a specific moment
	- Average throughput: rate over the entire transfer
- Throughput in Networks
	- Two-Link Networks
		- Throughput is determined by the slower link
			- Throughput=min{Rs​,Rc​}
			- Rs : rate from sender to receiver
			- Rc : rate from router to receiver
	- Multiple-Link network
		- Throughput is limited by the slowest link along the end-to-end path (bottleneck)
- Common bottlenecks:
	- The access network (WiFi, DSL, cellular) is often the bottleneck
	- Competing traffic on shared links reduces throughput even on high-speed links
	- Throughput depends on both link speeds and network traffic load.
---

#### 1.11 Protocol Layers
- Protocol layering
	- Networks protocols are organized into layers, each providing specific services.
	- Each layer uses services from the layer below and offers services to the layer above.
	- This modular design simplifies protocol development and maintnance.
- Implementation
	- Layers can be implemented in software, hardware or both
	- Application and transport layers are usually software-based.
	- Physical and data link layers are often implemented in hardware.
- Advantages of layering
	- Modularity: easy to update or replace layers independently
	- Structure: provides a clear framework to design and discuss networks
- Drawbacks:
	- Can cause duplication of functionality across layers
	- Information dependencies between layers can complicate design.
- Protocol Stack:
	- A collection of layered protocols is called a protocol stack.
	- The internet protocol stack has five layers.
		- Physical
		- Link
		- Network
		- Transport
		- Application
- Encapsulation
	- As data moves down the stack, each layer adds it own header to the data.
	- This process is called encapsulation, forming a packet with header and payload.
---

#### 1.12 Networks Under Attack
- Malware Consequences
	- Malware can cause serious damage, including:
		- Deleting files.
		- Stealing sensitive data (passwords, personal info)
		- Turning infected devices into botnet members for malicious use
- Self-replicating Malware
	- Many malware types spread by infecting one host and then propagating to others over the Internet, causing rapid infection growth.
- Types of DoS Attacks
	- Vulnerability Attacks: Exploit software bugs to crash systems.
	- Bandwidth Flooding: Overwhelm network capacity.
	- Connection Flooding: Exhaust resources by opening many connections.
- DDoS attacks
	- Attackers control multiple compromised sources to launch coordinated attacks, making detection and defense much harder.
- Cryptography Defense
	- Cryptography protect communication by encrypting data, preventing packet sniffing and eavesdropping.
- IP Spoofing
	- Attackers forge sources IP addresses to disguise themselves, complicating network security.
- End Point Authentication
	- To prevent spoofing and verify message sources, authentication mechanism are essential.

