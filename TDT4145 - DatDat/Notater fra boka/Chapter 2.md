Relational database consists of a collection of tables, each of which is assigned a unique name.

Set of permitted values = domain of that attribute.
A domain is atomic if elements of the domain are considered to be indivisible units.

null = unknown or doesnt exist

database schema = logical design of database
database instance = snapshot of the data in the database at a given instant in time.

### Keys
No two tuples in a relation are allowed to be exactly the same.

Superkey = a set of one or more attributes that allow us to identify uniquely a tuple in the relation.

If K is a superkey then any subset of K is a superkey.

Candidate keys = minimal superkey
{id} and {name, dept_name} are candidate keys
{id, name} does not form a candidate key since ID alone is a candidate key-

Primary key = chosen candidate key

foreign keys = msut be primary key of the referenced relation.

referential integrity constraint = verdier  i en tabell må finnes i en annen tabell, men trenger ikke være primary key.77


### Query language
1. Imperative
	1. How something is done, step by step
2. Functional
	1. Evaluation of functions
3. Declarative
	1. What you want, not how (sql)


### Join
If we do instructors x teaches we get every single combination, also those who do not belong together.

Therefore we combine it with a project to get the JOIN operator. 

r ⋈θ s = σθ(r × s)


### Union
for a union operation to make sense:
1. must ensure that the input relations to the union operations have the same number of attributes
2. when the attributes have associated types, the types must be the same

same for set


