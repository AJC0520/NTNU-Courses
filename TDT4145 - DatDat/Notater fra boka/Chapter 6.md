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