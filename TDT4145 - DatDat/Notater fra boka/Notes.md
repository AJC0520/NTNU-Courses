## 3.2
Normal relational algebra = sets
SQL = multisets (bag) -> duplicates are allowed


In SQL:
`UNION` -> removes duplicates (set)
`UNION ALL` -> keeps duplicates (multiset)

γ = grouping + aggregation

```
dept_name y average(salary) (instructor)
```

Betyr:
grupper på dept_name
regn ut average(salary) per gruppe

SQL:
```sql
SELECT dept_name, AVG(salary)
FROM instructor
GROUP BY dept_name
```

Hvis ingen grouping-attributter:
```
y average(salary) (instructor)
```

-> Hele tabellen er en gruppe
-> Gir gjennomsnittet for alle instructors

## 4.1
Relational algebra support:
- the left outer-join operation ⟕θ
- the right outer-join operation ⟖θ
- full outer-join operation ⟗θ
- natural join ⋈
- natural join versions of the left, right and full outer-join operations, denoted by ⟕,⟖, and ⟗


