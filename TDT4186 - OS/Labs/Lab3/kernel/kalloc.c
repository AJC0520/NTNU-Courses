// Physical memory allocator, for user processes,
// kernel stacks, page-table pages,
// and pipe buffers. Allocates whole 4096-byte pages.

#include "types.h"
#include "param.h"
#include "memlayout.h"
#include "spinlock.h"
#include "riscv.h"
#include "defs.h"

uint64 MAX_PAGES = 0;
uint64 FREE_PAGES = 0;

void freerange(void *pa_start, void *pa_end);

extern char end[]; // first address after kernel.
                   // defined by kernel.ld.

struct run
{
    struct run *next;
};

struct
{
    struct spinlock lock;
    struct run *freelist;
} kmem;

// Reference counts for physical pages.
#define NPHYSPAGES ((PHYSTOP - KERNBASE) / PGSIZE)
static uint8 refcounts[NPHYSPAGES];
static struct spinlock reflock;

static uint64 pa_to_idx(uint64 pa)
{
    return (pa - KERNBASE) / PGSIZE;
}

void kref_inc(void *pa)
{
    acquire(&reflock);
    refcounts[pa_to_idx((uint64)pa)]++;
    release(&reflock);
}

// Decrement ref count; free the page if it reaches 0.
void kref_dec(void *pa)
{
    acquire(&reflock);
    int ref = --refcounts[pa_to_idx((uint64)pa)];
    release(&reflock);
    if (ref == 0)
        kfree(pa);
}

void kinit()
{
    initlock(&kmem.lock, "kmem");
    initlock(&reflock, "refcounts");
    freerange(end, (void *)PHYSTOP);
    MAX_PAGES = FREE_PAGES;
}

void freerange(void *pa_start, void *pa_end)
{
    char *p;
    p = (char *)PGROUNDUP((uint64)pa_start);
    for (; p + PGSIZE <= (char *)pa_end; p += PGSIZE)
    {
        kfree(p);
    }
}

// Free the page of physical memory pointed at by pa,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void kfree(void *pa)
{
    if (MAX_PAGES != 0)
        assert(FREE_PAGES < MAX_PAGES);
    struct run *r;

    if (((uint64)pa % PGSIZE) != 0 || (char *)pa < end || (uint64)pa >= PHYSTOP)
        panic("kfree");

    // Fill with junk to catch dangling refs.
    memset(pa, 1, PGSIZE);

    r = (struct run *)pa;

    acquire(&kmem.lock);
    r->next = kmem.freelist;
    kmem.freelist = r;
    FREE_PAGES++;
    release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    assert(FREE_PAGES > 0);
    struct run *r;

    acquire(&kmem.lock);
    r = kmem.freelist;
    if (r)
        kmem.freelist = r->next;
    release(&kmem.lock);

    if (r) {
        memset((char *)r, 5, PGSIZE); // fill with junk
        acquire(&reflock);
        refcounts[pa_to_idx((uint64)r)] = 1;
        release(&reflock);
    }
    FREE_PAGES--;
    return (void *)r;
}
