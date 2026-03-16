### Why paging?
Segmentation was an earlier approach to memory management. It allows non-contagious memory assignment, which gives flexible allocation. It does however suffer from external fragmentation and over time, free memory becomes scattered into small unusable gaps. Fixing this requires compaction which has significant performance overhead.

> Paging solves external fragmentation by dividing both physical memory and virtual memory into fixed-size, equal blocks. Because blocks are the same size, any free block fits any allocation - eliminating external fragmentation entirely.


### Paging fundamentals
#### Core concepts
- **Page Frame**: A fixed-size block of physical memory.
- **Page**: A fixed-size block of virtual memory. Pages and frames are the same size.
- **Page table:** A per-process data structure that maps virtual pages to physical frames.
- **Non-contiguous allocation:** Virtual pages can be mapped to any available physical frames. they do not need to be adjacent.

#### Benefits
- Flexibility: No assumptions needed about how heap and stack grow. Virtual address space abstraction is fully supported.
- Simplicity: All pages and frames are the same size, so allocation is straightforward, just maintain a free-list of frames.
- No external fragmentation: Because all blocks are the same size, any free frame fits any page.
- Internal fragmentation: A downside. If a process does not fully use its last page, the remaining space within that page is wasted.

#### Example
![[file-20260311102419142.png]]

A 64-byte process with a page size of 16 bytes. The virtual address space has 4 pages (0-3). Physical memory might have 8 frames. The OS maps:
Page 0 of AS -> Frame 3
Page 1 of AS -> Frame 7
Page 2 of AS -> Frame 5
Page 3 of AS -> Frame 2

The pages are scattered throughout physical memory, they are not contiguous. The page table records each of these mappings.

### Page translation & Address format
#### Virtual Address structure
Every virtual address is split into two parts:
- Virtual Page Number (VPN) - High bits
	- Used as an index into the page table to find the corresponding physical frame.
- Offset - low bits
	- The position within the page. This is copied unchanged into the physical address.

> Given: Virtual address space = $2^{m}$ bytes, Page size = $2^{n}$ bytes -> Offset bits = n -> page number bits = m - n

![[file-20260311102910294.png]]

![[file-20260311103059161.png]]

#### Example
Given 32-bit virtual address, 4KB ($2^{12}$) page size, 2GB physical memory. 
- Offset bits: $log_{2}(4KB)$ = 12 bits
- Page number bits: 32 - 12 = 20 bits -> $2^{20}$ = 1.048.576 possible virtual pages.
- Number of physical frames: 2GB/4KB = $2^{31-12} = 2^{19}$ = 524.288 frames.

#### XV6-SV39 Address format (RISC-V)
![[file-20260311103551280.png]]


| Field                      | Bits                         | Purpose                                         |
| -------------------------- | ---------------------------- | ----------------------------------------------- |
| EXT (extension)            | 25 bits                      | Sign-extension, not part of address translation |
| VPN (virtual page number)  | 27 bits (9+9+9 for 3 levels) | Index into the 3-level page table.              |
| Offset                     | 12 bits                      | Position within the 4KB page                    |
| Total virtual addresses    | 39 bits                      | Supports up to 512GB address space              |
| PPN (physical page number) | 44 bits                      | Physical frame number stored in the PTE         |
#### Translation steps
For each memory reference the hardware performs:
1. Extract the VPN from the virtual address (high bits)
2. Calculate the address of the PTE = PageTableBase + VPN x EntrySize
3. Memory access #1: Fetch the PTE from the in-memory page table
4. Extract the Physical Frame Number (PFN) from PTE
5. Compute physical address = PFN x PageSize + Offset
6. Memory access #2: Fetch/Write the actual data at the physical address.

> Every memory reference require TWO memory accesses, one to read the page table and one for the actual data. This doubles the effective memory access time.


### Page Table
#### Structure
Location:
- Stored in main memory. The page-table base register (PTBR) holds the starting physical address of the page table.
Per-process:
- Each process has its own page table (separate virtual address spaces)
Linear page table:
- The simplest form, a flat array indexed by VPN, entry at index VPN gives the PFN.


![[file-20260311104711181.png]]

#### Page Table Entry (PTE) fields
Each PTE is 64 bits:
- 10-54 (44 bits): Physical Page Number
- 0-9 (10 bits): Flags and other information

#### Inverted Page Tables
Instead of one page table per process, inverted page table has one entry per physical frame. Each entry records which process uses that frame and which virtual page it corresponds to.
![[file-20260316115752845.png]]

Memory saving, but long searching time, page sharing.


| Aspect       | Regular Per-Process                                 | Inverted                                  |
| ------------ | --------------------------------------------------- | ----------------------------------------- |
| Size         | Proportional to virtual address space (can be huge) | Proportional to physical memory (smaller) |
| Lookup speed | Fast, indexed directly by VPN                       | Slow, must search entire table            |
| Page sharing | Easy, two PTE points to the same frame              | Difficult to implement                    |
#### Page sharing
With per-process page table, page sharing is easy: two different PTEs in different processes can point to the same physical frame. This is how shared libraries are loaded once into physical memory but mapped into multiple processes virtual address space. 
![[file-20260316120037968.png]]
