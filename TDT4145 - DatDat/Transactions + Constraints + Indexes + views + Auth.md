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

```
BEGIN TRANSACTION;
INSERT INTO married_person VALUES ('00001','Tommy','00002');
INSERT INTO married_person VALUES ('00002','Gina','00001');
END TRANSACTION;
```

### Indexes
speed up lookups on attributes so you don't scan the whole table
```
CREATE index studentID_index on student(ID);
```

### Views (definition + use)
A virtual relation to hide complexity or sensitive data.
```
CREATE VIEW faculty AS
SELECT id, name, dept_name
FROM instructor;

SELECT name
FROM faculty
WHERE dept_name = "Biology"
```

Views vs WITH: views stick around until dropped, WITH is only inside that query
Views can be built on other views (dependency chaings)
Materialized vs non-materialized view + maintenance approaches are discussed.

### Updating views
Updates/inserts into views are usually allowed only for simple views (one base table, no aggregates, no GROUP BY, etc.)

```
CREATE VIEW faculty AS
SELECT id, name, dept_name
FROM instructor;

INSERT INTO faculty VALUES ('30765', 'Green', 'Music');
```

This creates issues because `salary` exists in `instructor`

WITH CHECK OPTION can prevent inserts/updates that don't satisfy the view predicate.

### Authorization: privileges, GRANT, roles
List privileges: SELECT, INSERT, UPDATE, DELETE, ALL PRIVILEGES
schema privileges: INDEX, RESOURCE, ALTERATION, DROP

GRANT form:
```
GRANT <privilege list> ON <relation or view> TO <user list>
```
granting on a view does not grant privileges on underlying tables

Roles:
```
CREATE ROLE instructor
GRANT instructor TO theodoc
```

