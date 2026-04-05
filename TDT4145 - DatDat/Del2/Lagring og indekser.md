![[Pasted image 20260405124002.png]]

Klientlaget øverst representerer hvordan applikasjoner snakker med databasen. Java bruker JDBC og C# bruker SqlCommand, begge sender rå SQL-strenger ned i motoren.

SQL-kompilatoren parser SQL og oversetter den til et relasjonsalgebrauttrykk. Den spør SQL-katalogen (metadatastore med skjemainfo som tabellnavn, kolonnetyper, constraints) for å validere spørringen og løse opp navn.

Optimizer tar algebrauttrykket og finner den mest effektive måten å kjøre det på, og produserer en eksekveringsplan. Den bruker statistikk for å estimere kostander og velge gode join rekkefølger og aksessveier.

Executor kjører planen steg for steg. Kordinerer med tre sidesystemer.
- Spaceadm håndterer hvordan diskplass allokeres og frigjøres.
- Files er abstraksjonen over de faktiske OS-filene som inneholder data.
- Locks håndterer samtidighetskontroll, slik at transaksjoner ikke tråkker på hverandre.

DI/O-bufferen sitter mellom executor og disken. I stedet for å gå til disk ved hver lese/skriveoperasjon, caches sider i minnet her. Dette er en av de største ytelsesmekanismene i en database.

Loggen kjører parallelt og registrerer hver endring før den treffer disken. Dette er hvordan databaser overlever krasj og støtter rollback.

Lagringslaget nederst er det som faktisk ligger på disk. Logfiler ligger også separat her.

## Database servers vs embedded DB

#### Server-based
MySQL, PostgreSQL runs as a separate process, accessed via network. Multiple applications share the same database, this is the key advantage. It multiplies the "value" of the data since any systems can use it.

#### Embedded
SQLite 3. Runs as a library inside your application process. Simpler to deploy, no network needed, but only one application can realistically use it.

> Server = shared access + higher complexity
> Embedded = simple + isolated

## Database Storage Overview
Databases can be stored in:
- Regular files with Direct I/O (most common) - bypasses OS page cache for predictability.
- Raw devices - completely bypasses the OS buffer.
- MMAP segments - maps file into virtual memory.

#### Table storage structures:
- Heapfile
- B+-trees
- Hashfile
- LSM-trees

#### Index structures (on attributes)
- For fast lookup and range queries
- For enforcing PRIMARY KEY / UNIQUE constraints
- Types: Hashing, B+- trees, R-trees (multiple dimensional)

Clustered index: when storage and index are combined, data rows are physically stored inside the index structure itself.

Normally index and table are separate. Index leaf nodes contain a pointer. To get full row you do a second disk access to heapfile using the ID. (unclustered)

In clustered, you collapse the two together. The leaf nodes of the index are the table, they store the full record directly. No separate heapfile, no second lookup. Physical order of rows on disk matches the index order.

> Table = where all the data lives, index = pointer into the table. A heapfile stores a table, a B+-tree or hashfile can store an index on top of it.

## Record (Post) storage
A row in a table = a record (post) stored in a file. Tuple, row and record are interchangeable.

#### Field (attribute) types:
- Integer, long integer, floating point - 4 or 8 bytes
- String - 1 or 2 bytes per char, also called TEXT
- Date/time
- BLOBs - very long fields
- JSON - stored as text

The SQL catalog describes how each table/record is stored: field names, data types, lengths, constraints. This metadata is used by the query optimizer and executor.

## Record (Post) Layout  (2 methods)
Two approaches for laying out a record physically.
#### Fixed offsets
Each field is stored at a known byte offset. Works well for fixed-length fields. 

Accessing a field = calculate offset, read bytes.
#### Pointer/offset directory.
A header section contains offsets pointing to each fields start position within the record. 

`110 | Per | Hansen | perh`, arrows from an offset table point to each field. This is used for variable-length fields so you can jump directly to any field without scanning.

> Variable-length fields need the pointer approach. Fixed-length fields can use fixed offsets.


## Block Layout (slotted page)
This is how records are arranged inside a disk block/page.

- Block has a page header at the top.
- Records (tuples) are inserted from the top downward into "tuple space"
- A page directory grows upward from the bottom of the block
- The directory contains slot entries (offset to each tuple)
- Free space is in the middle between the two growing structures.

This is called a slotted page layout. The directory lets you find any record by its slot number without scanning the whole block. When a record is deleted, its slot can be reused. When a variable-length record grows/shrinks, only its pointer needs updating.

## Buffer (buffer pool)
The buffer is RAM that caches frequently used disk blocks. Key properties:
- Pinning: DB pins blocks in RAM so OS virtual memory manager cannot evict them. DB needs total control over which blocks are in memory.
- Adaptive cache algorithms: Different access patterns (sequential scan vs. point lookup) are treated differently to avoid cache pollution.
- Pre-fetching: when a sequential scan is detected, DB can proactively load upcoming block before they are needed.
- Hash-based lookup: to find if a block is in the buffer, a hash table keyed on BlockID is used. Blocks with the same hash bucket are linked in RAM.
- Writing to disk: Blocks are flushed to disk during checkpointing (as part of crash recovery) or independent based on buffer pressure.

> Pin blocks are important because OS might swap them to disk otherwise, undermining the DB's own cache strategy.

## Heap files
A heapfile is the simplest table storage: a unordered, unsorted collection of records.

New records are appended at the end. Internally implemented with two linked lists of blocks: one for blocks with free space, one for full blocks. A header block points to both lists.

Records are accessed via RecordId = (BlockId, slot number within block)

Pros:
- Easy to insert (appending)
- Good for full table scans
- Good write performance

Cons:
- Bad for attribute-based searches (must scan everything)
- Bad for range queries

Usually combined with indexes for fast lookup.

> RecordID is the physical address of a record. Heapfiles require indexes on top for non-scan access


## Hash-based indexes
Excellent for exact-match lookup on a search key.

It works by applying a hash function h(K) to the search key K. The result determines which bucket (block) the record belongs to.

`h(K) = K MOD M` maps key K into one of M buckets.

A good hash function spreads records evenly, but it depends on data distribution.

Handling overflow:
- Open addressing - store the record in the next available block in the file. Can also chain.
- Separate overflow - link extra overflow blocks to the full bucket in a chain.
- Multiple hashing  - when collision occurs, apply a second hash function.

> Hash indexes are great for equality, but useless for range queries since there is no ordering. This is a key comparison point vs B+- trees.




