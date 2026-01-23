### DDL: `CREATE TABLE` + domains + constraints
```
CREATE TABLE rel(
	A1 D1,
	A2, D2,
	...
	(integrity-constraint-1),
	...
	)
```

#### Common domain types:
Numeric
	- int
	- smallint
	- numeric(p,d)
	- real
	- double precision
	- float(n)
text:
	- char(n) (fixed)
	- varchar(n) (variable)

#### Integrity constraints:
- **PRIMARY KEY** (...)
- **FOREGIN KEY** (...) **REFERENCES** other_table
- **NOT NULL**

```
CREATE TABLE instructor(
	id char(5),
	name varchar(20) NOT NULL,
	dept_name varchar(20),
	salary numeric(8,2),
	PRIMARY KEY (id),
	FOREIGN KEY (dept_name) REFERENCES department
);
```


#### Updating table
 **INSERT** **INTO** ... **VALUES** (...)
 ```
 INSERT INTO instructor VALUES ('22222', 'Einstein', 'Physics', '95000')
 
 INSERT INTO instructor(id, name, dept_name salary)
 VALUES ('22222', 'Einstein', 'Physics', '95000');
 
 INSERT INTO instructor(id, name)
 VALUES ('22222', 'Einstein');
 ```
 
**DELETE** **FROM** table
```
DELETE FROM instructor;
DELETE FROM instructor WHERE dept_name = 'Finance';
```

**DROP TABLE** table
**ALTER TABLE** r **ADD / ALTER TABLE** r **DROP**
```
DROP TABLE student;

ALTER TABLE instructor ADD office varchar(20);
```

```
UPDATE instructor SET salary = salary * 1.05;
UPDATE instructor SET salary = salary * 1.05 WHERE salary < 70000;
```


#### Basic query structure + duplicates
##### Core shape
```
SELECT A1, ..., An
FROM r1, ..., rm
WHERE P;
```

SQL keeps duplicates by default -> use **DISTINCT** when you want set behavior

You can select literals and expressions (e.g., salary/12)
#### Filtering + strings
**WHERE** uses **AND**, **OR**, **NOT** comparisons(<, <=, >, >=, =, <>) and **BETWEEN**.

String matching: **LIKE**
% = any substring
_ = any single character
patterns are case sensitive

```
SELECT ...
FROM ...


WHERE ... LIKE '%dar%' // Contains "dar"
WHERE ... LIKE 'Intro%' // Starts with "Intro"
WHERE ... LIKE '___' // Exactly 3 chars
```


#### Sorting + Top-k
**ORDER BY** col [ACS|DESC]
**LIMIT** k for top-k queries

```
SELECT name
FROM instructor
ORDER by SALARY DESC
LIMIT 2;
```

#### Set operations
**UNION, INTERSECT, EXCEPT**
Add ALL to keep duplicates

```
SELECT course_id FROM section WHERE semester='Fall' AND year=2017
UNION ALL
(SELECT course_id FROM section WHERE semester='Spring' AND year=2018);
```

#### Aggregates + GROUP BY + HAVING
Aggregates: `avg`, `min`,`max`,`sum`, `count`
**GROUP BY** non-aggregate selected columns must appear in **GROUP BY**
**HAVING** filters after grouping (unlike **WHERE** which filters before grouping)
Query evaluation order FROM -> WHERE -> GROUP BY -> HAVING -> SELECT

```
SELECT dept_name, avg(salary)
FROM instructor
GROUP BY dept_name
```

```
SELECT dept_name
FROM instructor
GROUP BY dept_name
HAVING avg(salary) > 42000
```


#### NULL
**NULL** = unknown / missing value. Comparisons with **NULL** become **UNKNOWN** (except **IS NULL / IS NOT NULL**)
3-valued logic:
true AND unknown = unknown, false AND unknown = false
unknown OR true = true, unknown OR false = unknown
In **WHERE**, **UNKNOWN** is treated as false -> row is filtered out
Aggregates usually ignore **NULL**
- count(salary) ignores null, but count(\*) counts rows






