### CPU-virtualization
One physical CPU is shared among many programs by running small bits from each one, context switching.
Each program think they are running alone.
![[file-20260126160858627.png]]


### Program vs process
Program is a static file on the disk
Process is a program that lives (loaded into memory and runs)

### Address space
A process usually has:
- Code/text - instructions
- Data - global variables
- Heap - dynamic memory
- stack - local variables, return addresses, call frames
	- CPU registers, PC

![[file-20260126161030061.png]]

### Process Control Block - what the OS saves about a process
The process is represented by a PCB with attributes like PID, state, parent, open files...

### Process state
READY, ready waiting for CPU
RUNNING, running on cpu
BLOCKED, waiting for something (often I/O)
ZOMBIE, done but lives until parent has retrieved exit-status

![[file-20260126161258974.png]]

### Process-API
#### fork()
One call, two returns. Both parent and child continues after fork()
Return:
- parent gets PID from child
- child gets 0
- error: -1
Child is a copy of parent, but with own PID and own memory address

![[file-20260126161425744.png]]

#### wait()
Parent can wait until child is finished
![[file-20260126161617878.png]]

#### exec()
Swaps the process data + code with a new program (starts a new program)
exec() does not return if everything works, only when error
![[file-20260126161752530.png]]

### Why fork + exec instead of one CreateProcess
Gives you the option to swap things between the fork and exec, especially I/O redirection and pipes.

### Pipe + process-tree
Pipe is a one-way channel. One processwriter, and another one reads.
![[file-20260126161955851.png]]

Process tree: processes have parent/child relations. (init is often PID=1)
![[file-20260126162042298.png]]

### Threads
We have many cores and want to take use of the parallelism without paying a "cpu-price"
Processes are isolated but heavy

#### What is a thread?
"Like a process", but more threads shares the same address space inside one process.

#### Shared between threads in the same process
PID, code, data, heap, open files, cwd, etc
Individual per thread:
- TID, registerset (PC and stack pointer) and own stack
![[file-20260126162258979.png]]
