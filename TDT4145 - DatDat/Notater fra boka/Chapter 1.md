Database systems: 
- manage large bodies of information
- providing mechanisms for the manipulation of information
- must ensure the safety of the information stored despite system crashes or unauthorized access

Are used to manage collections of data that:
- are highly valuable
- relatively large
- accessed by multiple users and applications, often at the same time

Two modes in which databases are used:

1. To support online transaction processing.
- Large number of users, retreating small amounts of data and performs small updates. Primary mode of use for vast users.

1. To support data analytics
- Processing of data to draw conclusions, infer rules or decision procedures. 


### Purpose
Information in file-processing systems has disadvantages:
- Data redundancy and inconsistency
- Difficulty in accessing data
- Data isolation
- Integrity problems
- Atomicity problems
- Concurrent-access anomalies
- Security problems

### Integrity constaints
- Domain constraints
	- a domain of possible values must be associated with every attribute. Most elementary form of constraint. Tested easily. (varchar, integer etc)
- Referential integrity:
	- a value that appears in one relation for a given set of attributes also appears in a certain set of attributes in another relation
	- dept_name value in course must appear in the dept_name attribute of some record of the department relation.
	- Normal procedure is to reject the action that cause the violation.
- Authorization
	- read, insert, update, delete

### Transaction management
A transaction is a collection of operations that performs a single logical function. If the database was consistent when a transaction started, it must be it when it is successfully terminated.


### Users
- Naive
	- interacts using interfaces
- application programmers
	- develop user interfaces
- sophisticated users
	- requests using query language. Analyst etc
