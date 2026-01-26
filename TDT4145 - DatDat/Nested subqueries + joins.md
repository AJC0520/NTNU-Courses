### Where subqueries can appear
A subquery is a SELECT-FROM-WHERE inside another query. It can be nested in

- WHERE (set membership / comparisons / exists)
- FROM (temporary / derived table)
- SELECT (must return a single value)

```
UPDATE instructor
SET salary = salary 1 * 1.05
WHERE salary < (SELECT avg(salary) FROM instructor)
```

### Set membership
Use when you want "value is in the result set of this query
```
SELECT DISTINCT course_id
FROM section
WHERE semester = 'Fall' AND year = 2017
  AND course_id IN (
    SELECT course_id
    FROM section
    WHERE semester = 'Spring' AND year = 2018
  );
```

### Correlated subqueries + EXISTS
Uses a variable from the outer query -> it may be evaluated once per outer row

```
SELECT course_id
FROM section AS S
WHERE semester = "fall"
	AND year = 2017
	AND EXISTS (
		SELECT *
		FROM section as T
		WHERE semester = "Spring"
			AND year = 2018
			AND S.course_id = T.course_id
	)
```

Correlated evaluation is often inefficient, optimizer try to rewrite to joins when possible

### Set comparisons: SOME / ANY
`salary > SOME (...)` means "greater than at least one value in the subquery result"

```
SELECT name
FROM instructor
WHERE salary > SOME (
	SELECT salary
	FROM instructor
	WHERE dept_name = "Biology"
)
```

Join-style:
```
SELECT DISTINCT T.name
FROM instructor AS T, instructor AS S
WHERE T.salary > S.salary
	AND S.dept_name = "Biology"
```

### UNIQUE / NOT UNIQUE
testing for duplicates
UNQIUE(subquery) is true if the subquery result has no duplicates
```
SELECT T.course_id
FROM course AS T
WHERE UNIQUE (
  SELECT R.course_id
  FROM section AS R
  WHERE T.course_id = R.course_id
    AND R.year = 2017
);

```

### Subquery in FROM
temporary table inside the query
```
SELECT dept_name, avg_salary
FROM (
  SELECT dept_name, avg(salary) AS avg_salary
  FROM instructor
  GROUP BY dept_name
)
WHERE avg_salary > 42000;
```

### WITH (CTE)
Defines a temporary named relation visible inside that query.
```
WITH max_budget(value) AS (
  SELECT max(budget) FROM department
)
SELECT department.dept_name
FROM department, max_budget
WHERE department.budget = max_budget.value;

```

### Join expressions (types + conditions)
Join = cross product + matching condition. 
Types:
- Inner
- left outer
- right outer
- full outer
Conditions:
- NATURAL
- ON(predicate), USING(...)

### Outer join is huge for "include zero results"
print all courses, even those without prereqs
```
SELECT title, prereq_id
FROM course LEFT OUTER JOIN prereq USING(course_id);
```

Outer join + aggregation
Count courses per student including those with 0

```
SELECT id, count(course_id)
FROM student LEFT OUTER JOIN takes USING(id)
GROUP BY id;
```

Inner join order doesn't change the result, left/right outer join order does affect the result.
