Challenges in design process:
- managing complexity
	- no single person usually understands the complete data needs
- evaluating alternatives
	- choose between different representation and avoid bad designs, such as redundancy.


Implementation:

- Logical-design phase: Translating conceptual schema into the implementation-dependent data model of the specific DBMS. 
- Physical-design phase: Specifying the physical features of the database, such as the file organizations and the internal storage structures.

Entity sets
Entity is a thing
Entity set is a collection of entities of the same type that share the same properties or attributes. (all people who are instructors at a university forms the entity set instructor)

In ER-diagaram, entity sets are depicted as rectangles.

![[file-20260220143426316.png]]


#### Relationship sets
Is an association among several entities
![[file-20260220143702693.png]]

Set of relationships of the same type.
When entity sets are associated through a relationship, they are said to participate in that relationship set.

Degree:
Binary: a relationship set involving two entity sets
n-ary: a relationship set involving more than two entity sets

Represented by diamonds

#### Roles
the function that an entity plays in a relationship is called its role. Usually implicit, but specified when an entity set participates in a relationship more than once in different roles. Indicated by labels on the line connecting diamonds to rectangles.

![[file-20260220144355869.png]]

descriptive attributes: a relationship set can have its own attributes which are used to record information about the association itself rather than the individual entities.

![[file-20260220150015460.png]]


Composite attrivutes
can be divided into subparts which are themselves other attributes


### binary mapping cardinalities
For a binary relationship set between entity sets A and B, the mapping cardinality must be one of the following:

- one to one (1:1). Entity in A is associated with at most one entity in B and visca verca.
- one to many (1:N) Entity in A associated with any number (zero or more) of entities in B, however an entity in B is associated with at most one entity in A.
- many-to-one (N:1)
- Many to many (N:M)
![[file-20260222164531845.png]]

ER diagram notation:
direct line ->, cardinality of "one"
undirected line --, cardinality of "many"

in a one-to-many relationship from instructor to student a directed line would point toward instructor and an undirected line would point toward student.

Total participation: Every entity in the set must participate in at least one relationship in the relationship set. Represented by a double line.

Partial participation: Only some entities in the set may participate in the relationship. This is represented by a single line.

![[file-20260222164653038.png]]


ER diagram can use l..h notation
- Minimum of 1 indicates a total participation
- Maxmium of 1 indicates the entity participates in at most one relationship

A primary key is a minimal superkey (candidate key)

To distinguish among various relationships in a set, the model uses the union of the primary keys of the participating entity sets.

Many-to-many: the union of the primary keys of both entity sets is used as the primary key.

Many-to-one: the primary key of the many side is used as the primary key

one-to-one: the primary key of either entity set can be chosen.


#### primary key for weak entity sets
weak entity sets do not have sufficient attributes to form a primary key on their own. they are **existence dependent** on a strong entity set

The primary key of a weak entity set is formed by combining the primary key of the identifying strong entity set with the discriminator of the weak entity set.

![[file-20260222171351110.png]]

#### removing redundant attributes
Attributes should be replaced by relationship sets, when they represent associations between entities.

you might include dept_name as an attribute of the instructor entity set. However the connection between an instructor and their department is better represented by a relationship set.

##### benefits:
makes association between entities visible and formal rather than leaving it as a hidden link inside a text attribute.

representing associations as relationships helps designers avoid making restrictive assumptions too early. easier to decide stuff with mapping cardinalities

removing these attributes prevents the duplication of data, which reduces the risk of inconsistencies.

![[file-20260222180234707.png]]

#### reducing er diagrams to relational schemas
For every entity set and every relationship set in the ER design, a unique relation schema is created and assigned the same name as the corresponding set.

a strong entity set with simple attributes is represented by a schema that includes an attribute for each descriptive property of the entity set.

primary key of the entity set serves as the primary key for resulting relation schema.

the student with attributes id, name, tot_cred
becomes the schema:
``student(ID, name, tot_cred)`

##### composite attributes
composite attributes is an attribut that consist of several parts
name = {first_name, middle_initial, last_name}

In the database:
```sql
Instructor(
ID,
first_name
middle_initial,
last_name
)
```

##### multivalued attributes
when an entity can have multiple values of the same type
an instructor could have multiple phone numbers, but you can save multiple values in one cell

solution is to create its own table
instructor(id, name)
instructor_phone(id, phone_number)

##### derived attributes
values that can be computed from other values
age can be computed using birth-date

if you save age, it needs to be updated each year which leads to inconsistency.

derived attributes are not saved.


#### representation of weak entity sets
a weak entity set is represented by a schema that includes its own attributes plus the primary key of its identifying strong entity set.

primary key consists of the union of the identifying strong entity's primary key and the weak entity discriminator.

the section weak entity set becomes section(course_id, sec_id, semester, year)

a foreign-key constraint is added to ensure that the inherited primary key references the identifying strong entity schema.

#### representation of relationship sets
A relationship set R between entity sets is represented by schema containing the union of the primary keys of all participating entity sets, plus any descriptive attributes of the relationship.

the choice of primary key for this schema depends on the relationships cardinality

many-to-many: the union of all participating primary keys
many-to-one: primary key of the many side
one-to-one: primary key of either entity set

if an entity set participates multiple times, role indicators are used to distinguish attributes, such as prereq(course_id, prereq_id)

#### schema refinement
redundancy of weak entity relationship: the schema for a relationship set linking a weak entity set to its identifying strong entity set is redundant and should be removed, as the information is already captured within the weak entity schema.

combination of schemas:
- in many-to-one relationship from A to B, the relationship schema can be merged into the schema for the entity set A by adding the primary key of B as a new attribute.

schemas can be combined even with partial participation by using null values for the missing relationships.


#### common mistakes in ER diagram
primary key as attribute:
- using the primary key of one entity set as an attribute in another
- correct approach is to use a relationship set

redundant relationship attributes:
- list the primary keys of participating entities as attributes of the relationship diamond. unnecessary because those keys are already implicitly part of the relationship set.

misusing single-valued attributes:
- a relationship cannot handle multiple values for a single attribute unless its designed for it

repetition in large diagrams:
- attributres should only be shown in the first occurence to avoid inconsistencies


#### use of entity sets versus attributes
treating something as an entity set is generally better if it allows for more details to be stored or if it needs to be associated with multiple other entities. choice depends on structure.





