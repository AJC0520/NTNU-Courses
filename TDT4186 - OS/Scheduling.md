### What is scheduling?
OS decides who gets access to the CPU now and in multicore also what core.

CPU-utilization: how much the cpu actually works
Throughput: how many jobs are done per time unit
turnaround time: from delivery to done
waiting time: time in ready queue
response time: from delivery to first response

### Classic algorithm
#### FIFO / FCFS
Run in the order of delivery, problem is convoy effect: one long task can hold back all the small task which will result in bad flow

#### SJF
Shortest job first
Good for average turnaround when you know the runtime and everything starts at the same time.
Non-preemtive, which means that one long task will block shorter ones that comes after

#### STCF
Shortest time to complete first
Preemptive SJF: always run the one with the least remaining time
Can cause starvation where the longer task will lose to an infinite stream of shorter ones

#### Round Robin (RR)
Time quantum, time slice, rotates in queues
Good for response time, but often worse turnaround due to switching
Max waitingtime: if n in queue and quantum q, no one waits more than (n-1)q
The choice of q is important (10.-100ms) because context switching has overhead
![[file-20260126163237639.png]]

### When we include I/O
