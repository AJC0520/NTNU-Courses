### 2.1 Principle of Network Applications
---
Client-server Architecture
- Structure: A dedicated server serves multiple clients
- Clients don't talk to each other, only to the server.
- Server has a fixed IP address.
- Examples: Web(HTPP), FTP, Telnet, Email

Peer-to-peer (P2P) Architecture
- No central server, peers (hosts) talk directly to each other.
- Dynamic and decentralized, peers can join/leave at any time
- Benefits:
	- Self-scalable, more peers = more capacity
	- Cost-effective, no need for large server infrastructure
- Challenges:
	- Security
	- Performance
	- Reliability

Process Communication
- Processes (programs running on hosts) exchange messages over the network.

Socket
- A socket is the interface between the application layer and the transport layer
- Its like a door through which messages are sent/received
- Its the API used for programming network communication
![[Pasted image 20250520153904.png]]
Addressing Processes
- To send data to specific process, you need:
	- The IP address (to identify the host)
	- A port number (to identify the process on the host)
- Common port numbers:
	- HTTP: 80
	- SMTP: 25

### 2.2 Transport Services (TCP & UDP)
----
When building a networked application, your protocol choice depends on:
- Reliable data transfer: Needed when no data loss is acceptable (like file transfers or email). Not needed for apps that can tolerate some loss (video streaming)
- Throughput. The rate of data delivery. Important for bandwidth-sensitive apps (large downloads or high-quality streams)
- Timing: Low delay or timing guarantees are needed for real-time apps (VoIP, gaming, video conferencing)
- Security: Includes encryption, data integrity and authentication. Some applications require secure communication (banking, messaging)

UDP vs TCP

| Feature     | UDP                                 | TCP                                |
| ----------- | ----------------------------------- | ---------------------------------- |
| Connection  | Connectionless                      | Connection-oriented                |
| Reliability | No guarantee of delivery            | Guarantees reliable delivery       |
| Ordering    | No ordering                         | Maintains order of packets         |
| Speed       | Fast, low overhead                  | Slowe, more overhead               |
| Use cases   | Video streaming, online games, VoIP | Web browsing, file transfer. email |
>[!WARNING]
>Neither TCP nor UDP guarantees throughput or timing


TLS - Transport Layer Security
- Enhances TCP with:
	- Encryption (confidentiality)
	- Data integrity
	- End-point authentication
- Used for secure applications (HTTPS)
- Require extra code (TLS libraries) on both client and server
- Uses a special socket API, similar to TCP

>[!NOTE]
>Use TCP for reliability and if security (via TLS) is needed
>Use UDP if speed and low latency matter more than perfect reliabality
>Use TLS over TCP for apps needing security features


### 2.3 Application Layer Protocol: Web and HTTP
---
HTTP is an application-layer protocol used for transferring web resources (HTML, images, CSS, JS, etc) between a client (usually a browser) and a server.

How HTTP works:
- Client (browser) sends a request
	- GET /index.html HTPP/1.1
	- Host: example.com
- Server responds with data:
	- HTTP/1.1 200 OK
	- Content-TYPE: text/html
	- html ... /html

HTTP & TCP
- HTTP uses TCP to ensure reliable delivery.
- TCP handles:
	- Packet loss
	- Packet reordering
	- Retransmissions
- HTTP doesn't care how that happens - it just uses sockets to send/receive complete messages

- HTTP is stateless: each request is indepentent
- If a client sends two identical requests, the server treats them seperatly.
- Sessions (like login states) are managed using cookies, tokens, or sessions layered on top of HTTP.

#### 2.3.1 Non Persistent and Persistent Connections
Non-persistent:
- Opens a new TCP connection for each object (HTML, images, CSS, etc.)
Persistent:
- Refuses one TCP connection for multiple objects - more efficient

- HTTP/1.1 uses persistent connections by default.
- Client/servers can still be configured to use non-persistent if needed.

Round Trip Time (RTT)
- RTT = time for a tiny packet to go from client -> server -> client
- It includes:
	- Propagation delay
	- Queuing delay
	- Processing delay
![[Pasted image 20250521102907.png]]
TCP Three-Way handshake
- To establish a TCP connection:
	- 1. Client -> SYN
	- Server -> SYN-ACK
	- Client -> ACK
- This process takes 1 RTT

HTTP Request Timeline (with persistent connection)
- RTT 1: TCP handshake (setup connection)
- RTT2: Client sends HTTP requests + ACK -> Server responds with HTML
- + Transmission time: Time to send the HTML file data.
- Total delay = 2RTT + transmission time

#### 2.3.2 HTTP Message Format:
HTTP messages have two types, request messages and response messages.

- HTTP Request Message (from client to server)

~~~
GET /somedir/page.html HTTP/1.1
Host: www.someschool.edu
Connection: close
User-agent: Mozilla/5.0
Accept-language: fr
~~~
Parts:
- Request Line:
	- `GET /somedir/page.html HTTP/1.1`
	- -> Method, path, version
- Header lines:
	- Key-value pairs with extra info (browser type, language etc)
- Blank line:
	- Separates headers from body (if any)
- Entity Body (optional)
	- Used with POST/PUT to send data (like form info)

- HTTP Response Message (from server to client)

~~~
HTTP/1.1 200 OK
Connection: close
Date: Tue, 18 Aug 2015 15:44:04 GMT
Server: Apache/2.2.3 (CentOS)
Last-Modified: Tue, 18 Aug 2015 15:11:03 GMT
Content-Length: 6821
Content-Type: text/html

(data data data ...)
~~~

Parts:
- Status line:
	- `HTTP/1.1 200 OK`
		- Version, status code, reason phrase
- Header line:
	- Info about the server, content, connection etc
- Blank line
- Entity body:
	- Actual content (HTML, JSON etc)
- 

#### 2.3.3 Cookies
Cookies are a small piece of data stored in your browser by websites to remember who you are.

How cookies work
1. Server sends a cookie
	- When you visit a site for the first time the server sends a header.
	- `Set-Cookie: userID=12345`
2. Browser stores the Cookie
	- The browser saves this cookie locally.
3. Browser sends Cookie BACK
	- On future requests to the same site, your browser automatically includes `Cookie: userID=12345`
4. Server identifies you
	- The server uses the cookie ID to look up your info (like in a database) so it knows who you are.

![[Pasted image 20250521104713.png]]

Cookies are used for:
- Session management - stay logged in across pages.
- Personalization - show your language, theme, etc.
- Tracking - know what you've viewed (used in ads, shopping carts, etc)

Privacy concerns:
- Cookies can track user across session and websites.
- Some third-party cookies are used for ads and profiling, which is why many browsers now block them by default.

#### 2.3.4 Web Caching
Stores copies of HTTP objects, to speed up future requests

- Faster loading time for users
- Less traffic to origin servers
- Reduced bandwidth usage
- Server costs for ISPs and institutions
- Used heavily by CDNs to serve content from locations close to users.

When a browser request a web page:
- If the object is in the cache and fresh -> its served from the cache.
- If not, the cache fetches it from the origin server, stores it, then serves it to the client

`Conditional GET` checks for freshness by comparing the `If-Modified-Since` header with object modification date

If an object hasn't changed, a `304 Not Modified response` allows the cache to serve the locally cached object.