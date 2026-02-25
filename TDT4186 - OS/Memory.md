### Why memory matters
#### Program execution reminder
A program must be loaded from disk into memory to run, once loaded it becomes a **process**

#### Memory Hierarchy

![[file-20260225123332674.png]]

From fastest/smallest to slowest/largest:
- Registers
- L1,L2,L3 cache
- Main memory RAM
- SSD
- Disk

Tradeoffs:
Better performance = more cost
Bigger size = cheaper cost per GB

### The need for memory abstraction
Early systems had no abstraction:
- Programs directly accessed physical memory
- Only one process at a time (uniprogramming)

Problems with this:
- Inefficient CPU usage
- Overwriting memory
- No protection
![[file-20260225123633628.png]]

Modern systems use multiprogramming:
Multiple processes share
- hardware resources
- cpu
- memory

Without abstaction
- processes can overwrite each other
- OS memory can be corrupted
![[file-20260225125358562.png]]
### Address space
An address space is **the set of memory adresses a process can use**

It is:
- An abstraction of physical memory
- The programs view of memory

![[file-20260225125723758.png]]

#### The components of address space
##### Code (text segment)
- Program instructions
- Static
- Does not change during execution

##### Heap
- Dynamic allocated memory
- Managed by programmer
- Examples:
	- Malloc()
	- new
- Must be explicitly freed

##### Stack
- Managed automatically (compiler/runtime)
- Stores:
	- Local variables
	- Function parameters
	- Return values
- LIFO
- Uses stack pointer
	- Push -> increment/decrement pointer
	- Pop -> reverse
![[file-20260225125804704.png]]

### Virtual memory
The OS virtualizes memory by using virtual addresses
Each process:
- thinks it starts at address 0
- has its own virtual address space
- is unaware of others

But physically: each process is placed anywhere in RAM

![[file-20260225130013569.png]]



#### Goals of virtual memory:
##### Transparency
Processes don't know memory is shared
##### Protection
Cannot access other processes memory or OS memory
##### Efficiency
Is time- and space-efficient

#### Virtual vs Physical Address
##### Virtual
Is what the programmer sees
Used by CPU

##### Physical
Actual RAM location

Every memory must translate:
Virtual -> Physical
Which is done by Memory Management Unit (MMU)

### Address translation
Compiler assumption:
- Compiler assumes process starts at address 0
- OS places it somewhere else in physical memory
- So addresses must be relocated
![[file-20260225130511530.png]]


### Relocation Methods
#### Static relocation (load-time)
OS rewrites addresses when loading a program
No hardware support needed

Problem:
- Cannot move process after loading
- Inflexible
- Require rewriting code

#### Dynamic relocation (hardware supported)
Uses base register, bound register, MMU

### Dynamic Relocation
![[file-20260225130758320.png]]

Each process has:
- Base register -> starting physical address
- Bound register -> size of process

Physical address = Virtual address + Base

Protection check:
![[file-20260225130924416.png]]
If virtual address >= bound -> trap (error)

##### Example:
Given:
- Base = 32KB
- Size = 16KB
- Virtual address = 128

Physical address:
128 + 32KB = 32896

Largest accessible address:
32KB + 16KB = 48KB

The **problem** of dynamic relocation is fragmentation (memory inefficiency)

### Fragmentation
#### Internal fragmentation
Occurs in fixed partitions
Definition: Allocated memory is larger than needed

Unused space inside partition

Example:
- Partition 16KB
- Process needs: 10KB
- 6KB wasted internally
![[file-20260225133428131.png]]

#### External fragmentation
Occurs in variable partitions
Definition: Enough total memory exist, but not contiguous

Memory is scattered into holes.
![[file-20260225133439130.png]]

### Memory allocation strategies
#### Fixed partition
Memory is divided into fixed-sized blocks
One base register per process.

Advantage: Simple, fast context switch
Disadvantage: Internal fragmentation

#### Variable partition
Allocate exactly what process needs.
Use base + bound
OS maintains list of free holes

Allocation algorithms:
![[file-20260225133600577.png]]

First fit -> first hole large enough
Best fit -> smallest hole large enough
Worst fit -> largest hole

#### Compaction
Solution to external fragmentation is to move processes to combine holes to create one large free block.
Problem: its expensive and high overhead

![[file-20260225133732162.png]]

### Segmentation
Instead of having only one pair of registers, divide the address space into several logic segments.
![[file-20260225133924873.png]]

Each segment has:
- Base
- Size
- Growth direction
- Protection bit

#### Segment-based addressing
Virtual address split into:
- Segment bits
- Offset
![[file-20260225134104531.png]]

Top bits determine segment:
- 00 -> Code
- 01 -> Heap
- 10 -> Stack

#### Translation in segment
![[file-20260225134500996.png]]
![[file-20260225134512043.png]]


To address virtual address 100:
Physical address:
100 is a program code address, add base from code
32K + 100 = 32868

To address virtual address 5000:
Physical address:
5000 is heap address
5000 - 4096(size of code) = 904 inside the heap
904 + 34K = 35720


#### Stack grows backward
Code & heap grow upward
Stack grows downwards
![[file-20260225135128405.png]]

Hardware must check growth direction and validate bounds properly

#### Segmentation fault
![[file-20260225135229089.png]]
If process accesses address outside segment bounds, hardware detects violations and OS raises segmentation fault

#### Segmentation sharing
- Code segments can be shared across processes which require hardware support.

#### Protection bits
Each segment has permissions:
- Read
- Write
- Execute

#### Limitations
Segmentations still suffers from external fragmentation, but is helpful in reducing wasted memory




