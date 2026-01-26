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
Programs swaps between CPU-burst and I/O wait
OS can schedule CPU-bursts as sub-work, start I/O and run another process while the first one waits.
![[file-20260126163528014.png]]
![[file-20260126163533980.png]]

### Priority scheduling + starvation
Each process gets a priority, lower number usually means higher priority
Can be pre-emptive or not.
Can cause starvation, a solution to this is aging (increase priority the longer you wait)

### MLFQ (Multi-Level Feedback Queue)
The goal is to have low response time and better turnaround time.

The idea is that you have more queues with different priority with RR inside the same queue
Priority changes based on behaviour without knowing the runtime

#### The rules:
1-2: Higher priority wins, same priority -> RR
3: new task starts at the top
4: if you use up the time slot on a level you move down
5: sometimes everything gets boosted up to reduce starvation and react to changes in behaviour
![[file-20260126163946226.png]]


### Fairness and proportional share
RR is fair in that everyone gets their time, but not necessary at the requested percent
Lottery scheduling is when processes gets tickets, and the amount of tickets is the amount of CPU.
A = 75 tickets, B = 25 tickets -> 75%/25% over time

### Completely Fair Scheduler
Linux-scheduler for normal task is CFS
Picks the process with the lowest virtual runtime
Each process gets a time slice based on sched_latency, the amount of processes and priority

Nice -> weight -> time slice
Nice goes from -20 to 19

#### Data structure
CFS uses red-black tree sorted on vruntime
insert/delete/update : O(log N)
find smallest: O(1)
![[file-20260126164314638.png]]


#### I/O and sleep
when the process sleeps, the vruntime does not increase
When it wakes up, it can get "too" prioritized. The solution is to set the wakeup-process vruntime to minimum in the tree.

### Multiprocessor scheduling (more cores) + cache affinity
Modern systems: multicore/multiprocessor/SMT
![[file-20260126164456087.png]]

Each cpu has a cache which is much faster than RAM
Cache affinity: a process goes quicker if its run on the same CPU as before

![[file-20260126164544000.png]]

#### SQMS (Single Queue Multiprocessor Scheduling)
One shared run queue, often as a core as manager.
Easy.
locking + scales bad + cache affinity problems
![[file-20260126164640910.png]]

#### MQMS (Multi queue multiprocessor scheduling)
One queue per CPU
Better cache affinity, more scalable
Can cause load imbalance (some cpu's are empty while others has queue)
![[file-20260126164753175.png]]

#### Solutions to load imbalance
Migration: Move jobs between CPU's
Work-stealing: An empty CPU steals work

![[file-20260126164850869.png]]

![[file-20260126164856642.png]]

#### Processor affinity
Soft affinity, tries to keep you on the same CPU but can move
Hard-affinity: locked to a cpu-set