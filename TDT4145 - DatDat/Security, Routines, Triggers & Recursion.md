### Authorization (access control)
Privileges (what a user is allowed to do)
You can grant privileges on relations (tables) or views:
- SELECT
- INSERT
- UPDATE
- ALL PRIVILEGES

There are also schema-modification authorizations
- INDEX
- RESOURCES
- ALTERATION
- DROP

### GRANT syntax
```
GRANT <privilege list> ON <relation or view> TO <user list>;
```

user list can be:
- a specific user-id
- public (all users)
- a role

The grantor must already hold the privilege (or be DBA)
Granting privileges on a view does NOT automatically grant privileges on the underlying base tables.
```
GRANT SELECT, UPDATE ON instructor TO alice
GRANT SELECT ON department TO public
```

### Roles
A role is like a permission bucket you can assign users to.
```
CREATE ROLE isntructor;
GRANT instructor TO theodoc;
```

Then you can grant privileges to the role, and everyone in it inherits them.

### Views + Authorization
```
CREATE VIEW hist_instructor AS
SELECT *
FROM instructor
WHERE dept_name = "History"
```

```
GRANT SELECT ON hist_instructor to hist_staff
```

Now hist_staff can do:
```
SELECT * FROM hist_instructor
```

But they might still fail if they dont have the required permissions (depending on DB rules) and privileges on the view dont spill over to the base table automatically

### Advanced SQL Data Types
DATE - yyyy/mm/dd
TIME - "09:00:30"
TIMESTAMP - date + time -> "yyyy-dd-mm time"
INTERVAL - duration/period -> INTERVAL "1" DAY

Subtracting date/time values gives an interval, and interval can be added to timestamps
```
SELECT DATE "2026-01-27" + INTERVAL "1" DAY;
```

#### Large objects
BLOB - binary large object (images, videos)
CLOB - character large objects (huge text)

Often queries return a pointer/reference, not the full object payload

#### Custom domains (types + constraints)
Domains are like types with rules
```
CREATE DOMAIN degree_level VARCHAR(10)
CONSTRAINT degree_level_test
CHECK (VALUE IN("Bachelors", "Masters", "Doctorate"))
```

So any column using degree_level auto-enforces that allowed set

#### User-defined types
```
CREATE TYPE Dollars AS NUMERIC(12, 2) FINAL;

CREATE TABLE department (
	dept_name VARCHAR(20),
	building VARCHAR(15),
	budget Dollars
);
```

Good for readability + consistent usage.

#### Functions and procedures
##### Functions
A function returns exactly one value (or a table) via RETURN.

Example: number of instructors in a department
```
CREATE FUNCTION dept_count (dept_name VARCHAR(20))
RETURNS INTEGER
BEGIN
	DECLARE d_count INTEGER
	SELECT COUNT(*) INTO d_count
	FROM instructor
	WHERE instructor.dept_name = dept_name
	RETURN d_count;
END
```

Use it inside SQL:
```
SELECT dept_name, budget
FROM department
WHERE dept_count(dept)
```

#### Table functions
Return a table as output

```
CREATE FUNCTION instructor_of (dept_name CHAR(20))
RETURN TABLE (
  ID        VARCHAR(5),
  name      VARCHAR(20),
  dept_name VARCHAR(20),
  salary    NUMERIC(8,2)
)
RETURN TABLE (
  SELECT ID, name, dept_name, salary
  FROM instructor
  WHERE instructor.dept_name = instructor_of.dept_name
);
```

Call it like:
```
SELECT *
FROM TABLE(instructor_of("Music"))
```

#### Procedures 
Procedures don't return via RETURN. They output using parameters like OUT.
```
CREATE PROCEDURE dept_count_proc(
	IN dept_name VARCHAR(20),
	OUT d_count INTEGER
)
BEGIN
	SELECT COUNT(*) INTO d_count
	FROM instructor
	WHERE instructor.dept_name = dept_count_proc.dept_name;
END
```

```
CALL dept_count_proc("History", ?);
```

#### Functions vs Procedures

| Functions                                             | Procedures                                       |
| ----------------------------------------------------- | ------------------------------------------------ |
| must return one thing                                 | returns via OUT/INOUT params                     |
| works inside SQL expressions                          | called via CALL                                  |
| standard discourages functions that modify data       | procedures are meant for modifying data          |
| transaction control is usually forbidden in functions | transaction controlled are allowed in procedures |

####  Procedural language constructs (inside routines)
SQL standard-style constructs:

**WHILE**
```
WHILE <boolean> DO
	<statements>;
END WHILE	
```

**REPEAT**
```
REPEAT
	<statements>;
UNTIL <boolean>
END REPEAT
```

**FOR** over query results
```
FOR r AS <SQL query> DO
	<statements>;
END FOR
```

**IF / ELSEIF / ELSE**
```
IF <cond> THEN
	...
ELSEIF <cond> THEN
	...
ELSE
	...
END IF 
```

Exceptions + handlers
```
DECLARE exception_name CONDITION;
DECLARE EXIT HANDLER FOR exception_name
BEGIN
	...
END
```

### Triggers
#### What is a trigger?
A trigger is code the DB runs automatically as a side effect of some modification.

To design one, you specify:
1. When it fires (event + timing)
2. Condition (optional WHEN clause)
3. Action (what to run)

Example trigger idea: after a students grade changes from F/null to a passing grade, update their total credits.

Key ingredients:
- AFTER UPDATE OF ...
- references to NEW ROW and OLD ROW
- FOR EACH ROW
- WHEN ...
- BEGIN ATOMIC ... END

### Recursive Queries
#### Recursive CTE pattern
```
WITH RECURSIVE rectable(A1, A2, ..., An) AS (
	<SFW query 1> -- base case
	UNION ALL
	<SFW query 2> -- recursive step
)
SELECT ...
FROM rectable.
```

- The recursive step must not contain DISTINCT
- Must use UNION [all]
- Recursive step is typically a join that involves the recursive table
- Recursion stops when no new rows are produced - and its your responsibility to ensure it terminates.

#### Example: transitive prerequisites
Goal is to find prerequisites, directly or indirectly.
```
WITH RECURSIVE rec_prereq(course_id, prereq_id) AS (
	SELECT course_id, prereq_id
	FROM prereq
	UNION
	SELECT rec_prereq.course_id, prereq.prereq_id
    FROM rec_prereq, prereq
    WHERE rec_prereq.prereq_id = prereq.course_id
)
SELECT *
FROM rec_prereq;
```

#### Example: flight connections (limit number of connections)
Base: direct flights. Recursive steps extends path by one hop. Add a chg counter to cap the depth.
```
WITH RECURSIVE conns(source, dest, chg) AS (
	SELECT source, dest, 0
	FROM flights
	UNION ALL
	SELECT conns.source, flights.dest, conns.chg + 1
	FROM conns
	JOIN flights ON conns.dest = flights.soruce
	WHERE conns.chg < 3
)
SELECT *
FROM conns;
```
