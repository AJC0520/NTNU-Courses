### Transactions + COMMIT/ROLLBACK
A transaction is a unit of work (sequence of queries/updates). It starts implicitly and must end with COMMIT (make permanent)  or ROLLBACK (undo)

```
BEGIN TRANSACTION;
UPDATE account SET balance = balance - 1000 WHERE id = 5624;
UPDATE account SET balance = balance + 1000 WHERE id = 2742;
END TRANSACTION;
```

### ACID properties
Atomicity: all-or-nothing (no money disappears halfway)
Consistency: preserves invariants, like A+B constant
Isolation: concurrent transactions shouldn't see partial state
Durability: committed changes persist

### Foreign keys + referential integrity + cascading actions
Foreign keys references the primary key by default, you can also specify referenced columns explicitly.

```
CREATE TABLE instructor (
	id char(5);
	---
	FOREIGN key (dept_name) REFERENCES department
		ON DELETE CASCADE
		ON UPDATE CASCADE
)
```

### Constraints + transactions: inserting cyclic references
CASE A: spouse can be NULL
```
BEGIN TRANSACTION;
INSERT INTO person VALUES ('00001','Tommy',NULL);
INSERT INTO person VALUES ('00002','Gina','00001');
UPDATE person SET spouse='00002' WHERE id='00001';
END TRANSACTION;
```

CASE B: spouse is NOT NULL (fails unless constraint is deferred)
```
CREATE TABLE married_person (
  id char(5),
  name varchar(40),
  spouse char(5) NOT NULL,
  PRIMARY KEY(id),
  FOREIGN KEY(spouse) REFERENCES married_person
    DEFERRABLE INITIALLY DEFERRED
);

```