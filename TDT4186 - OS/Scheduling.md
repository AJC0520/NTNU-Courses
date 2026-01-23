- Important problem in many contexts, like logistics, airports, game schedule etc.
- Policies that OS employs to determine the execution order of ready processes/threads
	- which core to execute on multicore systems
- The algorithms have diverse objectives and demonstrate different effects on the system performance

### Terms
(maximise)
**CPU utilization:***
 - Percentage of time CPU is busy executing jobs
**Throughput:***
- The number of processes completed in a given amount of time

(minimise)
**Turnaround time:***
- The time elapses between the arrival and completion of a process
	$$ T_t = T_c - T_a $$
**Waiting time:***
- The time a process spends in the ready queue
**Response Time:***
- Time elapses between the process arrival and its first output


#### FIFO
- Simple and basic
- First Come First Served
- Jobs are executed in arrival time order

![[Pasted image 20260120101345.png]]


- Convoy effect
	- A scheduling phenomenon in which a number of jobs wait for one job to get off a core, causing overall device and CPU utilization to be suboptimal.
- Aim to minimize average turnaround time

#### Shortest Job First (SJF)
- Jobs with the shortest execution time is scheduled first.

![[Pasted image 20260120101803.png]]


#### Shortest Time-To-Complete First (STCF)
- FIFO and SJF are both non-preemptive scheduleres
- STCF policy: Always switch to jobs with the shortest completion time
- STCF is a preemptive scheduler
- STCF may cause starvation

![[Pasted image 20260120101950.png]]


#### Response Time
Important performance metric, especially for interactive applications.
![[Pasted image 20260120102108.png]]


- FIFO: $$R = (0 + 30 + 50) / 3 = 26.7$$
- SJF: $$R = (0 + 10 + 30) / 3 = 13.3$$
#### Comparisons
Preemptive = can change the process of a cpu
Starvation = process waits forever

| Scheduler | Preemptive | Avg Turnaround | Avg Response | Starvation |
| --------- | ---------- | -------------- | ------------ | ---------- |
| FIFO      | No         | Poor           | Poor         | No         |
| SJF       | No         | Optimal        | Poor         | Yes        |
| STCF      | Yes        | Optimal        | Poor         | Yes        |
Optimal conditions:
- CPU-only jobs (No-I/O)
- Known runtime
- Same arrival times (SJF)

#### Round Robin (RR)
A fixed and small amoun of time units where each process executes for a time slice. It switches to another one regardless whether it as completed its execution or not.

If the job has not yet been completed, the incomplete job is added to the tail of the ready queue, FIFO queue.

![[Pasted image 20260120102642.png]]

- RR is a good scheduler in terms of response time
- Poor in terms of turnaround time
	- ![[Pasted image 20260120102726.png]]

- If there are n processes in the ready queue and the time quantum is q, no process wait more than (n-1)q time units
- Quantum size selection is imporant (usually 10-100ms)
	- Switching between processes comes at some overhead
	- Turnaround time depends on size of time quantum

![[Pasted image 20260120102949.png]]

- Starvation free
- RR is fair, simple and easy to implement and is used in modern OSs such as Linux and MacOS
- XV6 implements simple RR

#### Incorporating I/O
- Every program uses I/O
- Process execution consists of:
	- CPU execution
	- I/O wait

![[Pasted image 20260120103516.png]]![[Pasted image 20260120103525.png]]

- Treating each CPU burst as a sub-job
	- Schedule a CPU burst
	- Initialize the subsequent I/O burst, when the CPU burst completes
	- Switch to another process

![[Pasted image 20260120103638.png]]

#### Priority-Based Scheduling
Fair, but no differentiation

- A priority level is assigned to each process
	- FIFO, SJF, STCF are special priority-based scheduling algorithms
	- The process with the highest priority is always scheduled

- Priority-based scheduling:
	- Preemptive
	- Non-preemptive
- Different priority assignment methods
- Smaller number is usually higher priority
- May suffer from starvation, (solution)

#### Multi-level Feedback Queue (MLFQ)
Optimize turnaround time for batch programs
Minimize response time for interactive programs

MLFQ combines priority based scheduling and RR

Maintains a number of queues
- Each queue has a different priority level
- Jobs which are on the same queue have same priority
- Jobs are assigned to a queue

![[Pasted image 20260120104112.png]]

MLFQ varies the priority of a job instead of having a fixed priority.
MLFQ varies the priority of a job based on its observed behaviour

##### Rules:
- If pri(A) > pri(B), A runs
	- A&B are scheduled before C
- If pri(A) == pri(B), A & B run in RR
- When a job enters the system it is placed at the highest priority
- If a job uses up an entire time slice while running, its priority is reduced
- If a job gives up the CPU before the time slice is up, it stays on the same priority level

![[Pasted image 20260120104430.png]]![[Pasted image 20260120104455.png]]![[Pasted image 20260120104533.png]]
Problems with the current MLFQ:
- Starvation
- Game the scheduler
- Changed behaviour over time

![[Pasted image 20260120104639.png]]

After some time period S, move all the jobs in the system to the topmost queue
![[Pasted image 20260120104716.png]]

Beauty of MLFQ:
- It does not require prior knowledge on the CPU usage of a process

MLFQ scheduler is defined by parameters:
- Number of queues
- Time quantum of each queue
- How often should priority be boosted
- Scheduling algorithms for each queue

High priority queue
- Interactive proceses, response time
Low priority queue
- Batch processes
- Turnaround time

