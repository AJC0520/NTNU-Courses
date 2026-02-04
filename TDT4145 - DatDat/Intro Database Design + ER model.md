### Why design matters
#### Web app context
A typical database application has:
- Client side: browser/UI
- Server side: web server + application code + DBMS
- The DBMS stores and retrieves the data reliably and efficiently

#### Layered Architecture
Larger app are split into layers:
- Presentation/UI layer: screens, forms, interaction
- BLL: rules + operations
- Data-access layer: the interface between business logic and the relational DB

Business logic is coded into object-oriented code, while the DB is relational, so good design helps keep everything consistent and maintainable

### Database design phases
#### Phase 1: Requirements
The goal is to fully understand what data users need and what tasks, "transactions", they will perform.
- Identity data to store
- Identify operations (queries/updates) the system must support

#### Phase 2: Conceptual design
- Choose a data model
- Build a conceptual schema (high-level description of the enterprise)
- This schema captures what the data means, not how its stored

#### Phase 3: Implementation-focused design
Logical design:
- Decide the actual relation schemas, how attributes are distributed
- This is where "what tables should we have" becomes a CS design problem.
Physical design:
- Decide physical storage layout, indexes, etc.

### Design pitfalls
Two big problems:
1. Redundancy
	- Same fact stored multiple places -> update anomalies -> inconsistently
	- Example: department name stored both in student and in an association table and they diverge
2. Incompleteness
	- Schema can't express important parts of reality

Avoiding bad designs isnt enough, there can be many good one so you must choose wisely.


### Two main design approaches
A) ER model
Models an enterprise as:
- Entity sets (things)
- Relationship sets (associations among things)

Usually captured in an ER diagram

B) Normalization theory
A formal way to detect "bad" relational design

### Why ER diagrams are worth it
![[file-20260203102228108.png]]
ER diagrams help you:
- Understand the conceptual structure first
- Avoid wrong assumptions early
- Communication better with teammates/stakeholder
- Keep long-term documentation

### ER vs Relational Model
Form the comparison slide
- ER model: conceptual modeling, diagram-based
- Relational model: logical/physical modeling, table-based

ER can make some constraints explicit that might be only implicit in a relational schema.

### Core ER concepts
#### Entity + Entity set
- Entity: a distinguishable object (person, company, course)
- Entity set: a set of similar entities (all students, all courses)

Entities are described by attributes

instructor = (ID, name, salary)
course = (course_id, title, credits)

Notation
- entity set = rectangle
- attributes listed inside
- primary key attributes are underlined

#### Relationship + Relationship set
Relationship: An association among entities
Relationship set: a mathematical relation over entity sets
Think: a set of tuples (e1, e2, en)

Example: advisor
- Relationship set advisor connects student and instructor
- An instance might be (44553, 22222) $\in$ advisor, meaning student 44553 is advised by instructor 22222

![[file-20260203162704932.png]]

Relationship set = diamond
connects participating entity rectangles

Relationship can have attributes too
advisor might have attribute date (when advising started)

Notation: an attribute box attached to the relationship via dashed line
![[file-20260203162939875.png]]

#### Roles
Same entity set can participate twice in a relationship, in different roles.
`prereq(course, course`
- one role is "the course"
- the other role is "the prerequisite course"
- labels like course_id and prereq_id clarify roles
#### Degree of relationship
Binary(degree  2) most common
non-binary (degree >= 3) rarer but sometimes clearer

Example: ternary `proj_guide(instructor, student, project`
Meaning: a specific student works on a specific project under a specific instructor

### Attributes in ER
Attribute types:
simple vs composite
single-valued vs mutlivalued
derived attributes
domain, allowed values of an attribute

### Composite attributes
composite attributes can be broken into subparts
name = (first_name, middle_initial, last_name)

### Cardinality + participation constraints
Cardinality describes how many entities can be associated via a relationship
For binary relationship, the classic four types:
- 1-1
- 1-many
- many-1
- many-many

![[file-20260203163501153.png]]
![[file-20260203163511061.png]]

#### Total vs partial participation
Participation says whether every entity must participate in a relationship
Total participation
- every entity in the set participates at least once
- every section must be related to some course
Partial participation
- some entities may participate zero times
- an instructor might advise no students

#### Min-max notation

### Weak entity sets
A section is uniquely identified by:
- course_id, semester, year, sec_id

so sections are tied to a course

If you create relationship sec_course(section, course) and also store course_id inside section, you have redundancy (the relationship repeats what course_id) already indicates

But if you remove the relationship, the connection becomes implicit
If you remove course_id from section, then section may lose the ability to be uniquely identified on its own.

A weak entity set depends on another identifying entity
the connection relationship is an identifying relationship

weak entity set: double rectangle
identifying relationship: double diamond
![[file-20260203164227549.png]]

Discriminator (partial key)
weak entities are uniquely identified by:
owners key + discriminator
the discriminator is underlined with a dashed underline in ER

Even if you "drop" course_id as an attribute in the ER weak entity depiction, when you convert to relational tables later, course_id will stil appear in the section table

### Primary keys in ER
#### Entity set keys
A key is a set of attributes that uniquely identifies entities.
- No two entities in an entity set can have identical values for all attributes
- primary key is the chosen key


#### Relationship set keys
General rule
- For a relationship set R, involving E1, En a common primary key is the union of the primary keys for participating entity sets
- If the relationship has it own attributes, they may be included depending on identification needs.
But the minimal key depends on cardinality:
- Many-many: union of both sides keys is minimal -> use that
- One-many / many-one: key of the many side is enough
- One-one: either sides key is enough

If one instructor advises many student, then student_id alone can identify each advisor relationship instance.

Weak entity 




