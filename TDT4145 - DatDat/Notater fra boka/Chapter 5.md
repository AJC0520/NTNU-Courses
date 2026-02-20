SQL functions are used to return specific values.
Can be invoked directly withing other SQL statements such as in SELECT or WHERE clause.

Table functions: specialized version of a function that returns an entire relation as a result

procedures: generally uses IN and OUT parameters to pass and return values and are invoked using the CALL statement.


Define a trigger:
- Event: the specific modification that sets of the trigger
- condition: a test that must be satisfied for the triggers action to proceed
- action: the actual operations to be carried out when the trigger is executed.

triggers are used for tasks that standard sql features cannot handle:
- enforcing complex integrity constraints
- automatic tasks and alerts
- referential integrity

triggers can be set to exec AFTER an event or BEFORE. BEFORE triggers are useful for correcting or validating data

avoid triggers when alternatives exist because they can make the database structure harder to understand and maintain.:
- standard constraints: ON DELETE CASCADE
- Materialized views: modern DBMS maintains automatically
- replication: in built in most dbsm

risks;
- infinite chains
- performance
- nonstandard syntax


recursive queries are used to retreive data that has hierarchical or transitive structure.

procedural iteration
- function can be written to find the direct prerequisites, store them in a temp table
- repeat loop finds the prereq of those prereqs
- the loop continues until a cycle is completed where no new prereqs are found


