### Basic types
- char(n) - fixed-length character string with user-specified length n
- varchar(n) - variable-length string with user-specified max-length n.
- int or integer
- smallint
- numeric(p,d) - fixed point number with p digits and d numbers to the right of the decimal point
	- numeric(3,1) allows 44.5
- real - floating point with double-precision
- float(n) - floating-point number with precision of at least n digits.

each type may include null
var(10) with HEI will append 7 spaces
if comparing to char with different length, extra spaces are added to the shorter one

### Schema definitions:
![[file-20260219181130063.png]]

drop table r will delete the entire schema
while delete from r will delete all the tuples

alter table r add A D
alter table r drop A

sql keeps duplicates as standard:
- add DISTINCT

rename is important in cases where we wish to compare tuples in the same relation.

```sql
SELECT DISTINCT T.name
FROM instructor AS T, instructor AS S
WHERE T.salary > S.salary AND S.dept_name='Biology';
```
We could not use instructor.salary since it would not be clear what it referenced.

We use T and S as copies of the relation instructor


union automatically eliminates duplicates, unlike select

If we want to retain all duplicates, we must write union all in place of union

SQL treats  as unknown the result of any comparison involving a null value. (other than predicates is null and is not null)

true and unknown is unknown
false and unknown is false
unknown and unknown is unknown

true or unknown is true
false or unknown is unknown
unknown or unknown is unknown

not unknown is unknown








