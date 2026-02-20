### 16.5.1

A normal view only saves the query, not the result

```sql
CREATE VIEW department_total_salary AS
SELECT dept_name, SUM(salary)
FROM instructor
GROUP BY dept_name;
```

```sql
SELECT * FROM department_total_salary;
```

the query runs every time
The positive side is that its always updated
it can however be slow since it has to sum up everything each time.


#### Materialized view
A materialized view is saved physical as a table and the result is already computed.

Instead of summing up the instructors each time, the database only needs to do one lookup. Its a lot quicker, but has risk of inconsistent data.

solution: view maintenance

manual:
each time salary updates, also update total salary
- easy to forget
- bad design

triggers:
- make triggers on INSERT, DELETE, UPDATE
- trigger updates the materialized view.

naiv solution is to recompute the whole view each time and the better solution is to only update what changed. (incremental view maintenance)

#### Immediate vs deferred
immediate:
- updates in real time
- happens in the same transaction
- always consistent
- slower updates

deferred (updates leter)
- quicker updates
- view could be temporarily wrong.

