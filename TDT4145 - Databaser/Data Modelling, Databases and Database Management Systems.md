### Nested queries
![[Pasted image 20260123095805.png]]


### Set membership
SQL allows testing tuples for membership in relation
IN and NOT IN, SOME and ALL
![[Pasted image 20260123095850.png]]


![[Pasted image 20260123095917.png]]

![[Pasted image 20260123095928.png]]
![[Pasted image 20260123095937.png]]

EXIST, true if argument is nonempty
NOT EXIST

Correlated evaluation is not very efficient



transaction consists of a sequency of query and/or update statements and is a unit of work, begins implicitly when an SQL statement is executed. Transaction must end with either commit work or rollback work.

### ACID
to preserve integrity of data the DBMS must ensure ACID.
![[Pasted image 20260123100825.png]]
Atomicity
- If transaction fails after step 3 and before step 6, money will be "lost" leading to an inconsistent database state
Consistency
- Sum of A and B is unchanged by the execution of the transaction
Isolation
- If between 3 and 6 another transaction accesses the database, it will see an inconsistent database
Durability
- after t1 is over, the changes must persist

Integrity constraints guard against accidental damage.


### Constraints
Constraints on a Single Relation
NOT NULL
PRIMARY KEY
UNIQUE
CHECK(P)

### Assertions
predicate expressing a condition that we wish the database always to satisfy
CREATE ASSERTION assertion_name CHECK predicate

when assertion is created, system tests it for validity
- if assertion is valid, then any future modification to the database is allowed only if it does not cause that assertion to be violated

predicate can also contain a subquery
- most used dbms does not support subqueries

### Referal integrity
Relations between tables are consistent
foreign key in one table must point to an already existing primary key in another
cant refer to data that doesnt exist
