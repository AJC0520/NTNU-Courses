An architecture for database system
![[Pasted image 20260106130342.png]]


logical schema
- overall logical structure of the database
- analogous to the type of information of a variable in a program

physical schema
- the overall physical structure of the database

instance:
- the actual content of the database at a particular point in time
- analogous to the value of a variable


### Physical data independence
ability to modify the physical schema without changing the logical schema
applications depend on the logical schema

in general, the interfaces between the various levels and components should be well defined so that changes in some parts do not seriously influence others.


### Database design
three phases:
- conceptual database design
	- produces the initial model of the mini-world in a conceptual data model
- logical database design
	- transforms the conceptual schema into the data model supported by the DBMS
- physical database design
	- design indexes, table distribution, buffer sizes, etc to maximize the performance of the system

### Data definition language
specifications notation for defining the database schema
ddl compiler generates table templates stored in the data directory
data dictionary contains metadata
- database schema
- integrity constraints
	- like an ID
- authorization

have to store what we have stored
![[Pasted image 20260106131057.png]]

## How do database management systems facilitate access to data?

### Data manipulation language
Language for accessing and updating the data organized by the appropriate data model

procedural dml
- require user to specify what data is needed and how to get that data

declarative dml
- require a user to specify what data is needed without specifying how to get that data

information retrieval portion of a DML is a query language.

#### SQL query language
sql is declerative
- a query takes as input several tables and always returns a single table

find all instructors in comp. sci. dept
SELECT name
FROM instructor
WHERE dept_name = 'Comp. Sci.'

most basic structure ^^

![[Pasted image 20260106131811.png]]

SELECT name
FROM instructor, department
WHERE instructor.dept_name = department.dept_name
AND department.budget > 9100

SQL is not a turing machine equivalent language
	it is not a programming language, it is a query language

To be able to compute complex functions, SQL is usually embedded in some higher-level language.

Application programs generally access databases through one of:
- language extensions to allow embedded SQL
- Application program interface which allows SQL queries to be sent to a database.

the more complex the query, the bigger the savings

## How does database management system work?

centralized databases
client-server
parallel databases
distributed databases

a database is partitioned into modules that deal with each of the responsibilities of the overall system. 

the functional components of a DBMS can be divided into:
- storage manager
- query processor component
- transaction management component.

### Storage manager
 provides the interface between low level data stored in the database and the queries submitted to the system.

responsible:
- interaction with the os file manager
- efficient storing ,retrieving and updating of data

storage manager components include:
- authorization and integrity manager
- transaction manager
- file manager
- buffer manager

Implements:
- data files -- store the database itself
- data dictionary -- stores metadata about the structure of the database
- indices -- provide fast access to data items. Index provides pointers to those data items that hold a particular value
### Query processor

components include:
- DDL interpreter
- DML compiler
- Query evaluation engine

![[Pasted image 20260106134533.png]]

### Transaction manager
Ensure correctness of data

Its a collection of operations that performs a single logical function in a database

Transaction-management component ensures that the database remains in a consistent state despite system failures and transaction failures.

Concurrency control manager controls the interaction among the concurrent transactions to ensure consistency of the database. 


### Database applications
Usually partitioned into two or three parts
- two-tier architecture: the application resides at the client machine, where it invokes database system functionality at the server machine
- three-tier architecture: client machine acts as a front end and does not contain any direct database calls.
	- the client communicates with an application server usually through a form interface
	- application server in turn, communicates with a database system to access data
![[Pasted image 20260106135316.png]]

### Database users
Naive users
- interact with the system by invoking one of the application programs that have been written previously.
application programmers
- professionals who write application programs
sophisticated users
- interact with the system without writing programs using database query language
specialized users
- write specialized database application that do not fit into the traditional data processing framework.