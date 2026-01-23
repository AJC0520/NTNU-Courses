#### Suppose there is exactly one packet switch between a sending host and a receiving host. The transmission rates between the sending host and the switch and between the switch and the receiving host are R1 and R2, respectively. Assuming that the switch uses store-and-forward packet switching, what is the total end-to-end delay to send a packet of length L? (Ignore queuing, propagation delay, and processing delay.)

Transmission delay: Time taken to send the entire packet onto the link.
Store-and-forward: The switch has to receive the entire packet before forwarding it to the next link.

L = packet length
R1 = transmission rate from sending host to the switch
R2 = transmission rate from the switch to the receiving host


Transmission delay from sending host to the switch (time to send packet from host to switch)
$$Delay_1 = \frac{L}{R_1}$$

Transmission delay from the switch to the receiving host (time for switch to forward packet to receiving host)
$$ Delay_2 = \frac{L}{R2}$$
Total delay for packet to travel from the sending host to the receiving host via the switch is therefore:
$$Total = Delay_1 + Delay_2$$


#### What advantage does a circuit-switched network have over a packet-switched network? What advantages does TDM have over FDM in a circuit-switched network?

Advantages with circuit-switched network over packet-switched network:
* Dedicated communication paths between sender and receiver guarantees a constant and predictable transmission rate, which is preferable for real-time communication like voice calls.
* No delays due to routing or packet switching since the path is reserved for the entire session. Which results in lower latency and more consistent communication
* No need for packet buffering or reordering since data follows a dedicated route. This means that there is no possibility of packet loss or delay.
* Uses simpler communication protocols because there is no need for complex routing, addressing or reassembly of data packets. The end-to-end path is fixed, which reduces the need for error handling and congestion control mechanisms.

Advantages of TDM (Time division multiplexing) over FDM (frequency division multiplexing) in a circuit-switched network:

* TDM allows multiple signals to share the same frequency band by assigning each signal a specific time slot. For systems with high number of users, is this a more efficient utilizing of available bandwidth as it doesn't require large portions to be reserved for each user like FDM.
* TDM operates in time slots -> each users data is transmitted at different times, which reduces the potential for interference between users.
* TDM works well with users who transmit at low data rates since multiple users can share the same time slots without wasting resources.


#### Suppose users share a 2 Mbps link. Also suppose each user transmits continuously at 1 Mbps when transmitting, but each user transmits only 20 percent of the time. (See the discussion of statistical multiplexing in Section 1.3.)
##### a. When circuit switching is used, how many users can be supported?
Circuit switching = each users needs a dedicated portion of the link bandwidth.

Since each user needs 1mbps, and there is 2mbps total link capacity, max 2 users can be supported.

$$ \frac{2mbps}{1mbps} = 2$$

##### b. For the remainder of this problem, suppose packet switching is used. Why will there be essentially no queuing delay before the link if two or fewer users transmit at the same time? Why will there be a queuing delay if three users transmit at the same time?

Packet-switched network = multiple users can share the same link.

There will be no queuing delay because at two users(max) both will use max 1mbps which is equal to the links capacity.

If three or more users uses the bandwith at the same time the bandwith requirment is 3mbps which exceeds the links capacity of 2mbps. Leaving 1mbps worth of packets waiting in a queue.

##### c. Find the probability that a given user is transmitting.

The probability is 20%

##### d. Suppose now there are three users. Find the probability that at any giventime, all three users are transmitting simultaneously. Find the fraction of time during which the queue grows.

The fraction of time during which the queue grows is equal to the probability that all three users are transmitting which is:
$$\frac{20}{100}*\frac{20}{100}*\frac{20}{100} = 0.008 $$


#### Why will two ISPs at the same level of the hierarchy often peer with each other? How does an IXP earn money?

* Peering allows ISPs to exchange traffic between their networks, which reduces costs since they bypass higher-level transit ISPs
* Peering creates a direct route for traffic between to ISPs, which results in lower latency and faster data transfer.

IXP (internet exchange point) earn money by:
* Port fees - charging ISPs and other network participants for access to ports on their equipment.
* Membership fees
* Cross-connect fees
* value-added services

#### Why is a content provider considered a different Internet entity today? How does a content provider connect to other ISPs? Why?

content providers such as google, netflix, amazon are considered different because:

- They manage and own large-scale data centres and CDNs to distribute their content efficiently to users.
- They generate a significant portion of internet traffic.

They connect to ISPs through direct peering, private networks, and IXPs to reduce costs, optimize performance, and scale effectively.






