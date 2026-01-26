### What is an operatingsystem?
OS is the layer between hardware and programs.
It has to main jobs:
- Abstraction: To make hardware look easy and the same for programs (CPU, memory, disk)
- Resource management: protect, efficiency, fair

Resource is a typical OS abstraction
- CPU -> process/threads
- memory -> address space / pages
- disk -> files

### OS structure
#### Monolithic kernel: 
everything in kernel space
(linux,unix,android,xv6)
- Fast/shared state
- less robust, bug in driver can crash everything
![[file-20260126160020178.png]]

#### Microkernel
less in kernel, more in user space (services)
more secure and robust
more overhead and complexity (ipc)

![[file-20260126160155183.png]]


#### Hybrid
miks
windows and appleos

### User mode vs Kernel mode + system calls

Programs cant get free access to hardware, not secure.

To modes fix this:
- User mode: normal programs
- Kernel mode: OS-core, privileged

System call is the door in to the kernel, the program asks OS to do something, like `write()`

![[file-20260126160356159.png]]

write() in user mode -> triggers a trap/exception -> os looks in the system call table -> runs sys_write() in kernel -> returns.

### Boot
Power-on reset: CPU starts on a hard coded address in ROM.
Hardware/QEMU loads bootloader from first sector on the disk (fs.img) to memory.

Task of bootloader:
1. initialise CPU + basic memory
2. find kernel on the disk
3. load kernel to RAM
4. jump to kernel entry point

XV6: entry.S sets up a stack per CPU and calls C-code (main) init.
- Virtualization: page table
- Concurrency: locks + scheduler
- Persistence: disk + file system
- userinit() -> makes first user-process (shell)


