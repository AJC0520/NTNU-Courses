#### features of good relational designs
primary goal is to create set of schemas that store information without unnecessary redundancy while still allowing for easy data retrieval


#### bad designs:
- repetition of information
- inability to represent certain facts


to fix redundancy issues, use decomposition.
- breaking a large schema into several smaller ones

not all decompositions are good, a design must ensure lossless decomposition

a decomposition is lossless if for every legal instance the natural join of the projections onto the new schemas returns the exact original relation.

a decomposition is lossy (bad) if the natural join of the projections result in a proper subset of the original relation.


#### normalization theory
used to derive a set of schemas that are in good form.

1. evaluation: determining if a schema is in a specific normal form (BCNF, 3NF)
2. refinement: if the schema is in a bad form, it is decomposed into smaller schemas that are good.


legal instance: an instance of a relation that satisfy all real-world constraints
constraints on schema: we specify constraints on a relation schema to ensure that only legal instances can exist in the database

functional dependencies are generalizations of the notion of a key. describe a relationship where one set of attributes uniquely determines the value of another set.

$\alpha \rightarrow \beta$
means if two rows have the same value for $\alpha$, they must have the same value for $\beta$

$\alpha$ decided $\beta$


dept_name -> budget holds because each department has exactly one unique budget amount.

K is a superkey if K -> R, (K decides the row)
 

#### boyce-codd normal form (BCNF)

Strict normal form designed to eliminate all redundancy that can be discovered through functional dependencies

A relation schema R is in BNCF if for all functional dependencies in the closure F+ of the form $\alpha \rightarrow \beta$ , at least one of the following is true:

- the dependency is trivial ($\beta \subset \alpha$)
- $\alpha$ is a superkey for the schema R

The goal is to ensure that information is not repeated unnecessarily. 

Decomposing in_dep(ID, name, salary, dept_name, building, budget) into instructor and department  results in schemas that are in BCNF because their only non-trivial FDs have a superkey on the left side.

BCNF: If something decides something else, it needs to be a key.

If a schema violates BCNF due to non-trivial dependency, it is replaced by two smaller schemas. One that has the dependency and one with the rest.

R(A,B,C)
FD: A -> B
R1 = (A,B)
R2 = (A,C)

R(A,B,C)
FD:
A -> B
B -> C
R1(B,C)
R2(A,B)
Both are now in BCNF, but  to check A -> C we need to join them, which is expensive.


Sometimes we can get BCNF, but not preserve all FDs directly.


#### third normal form (3NF)
3NF is a slightly relaxed version of BNCF that ensures every schema has a decomposition that is both lossless and dependency-preserving.

A relation schema R is in 3NF if:
- $\alpha \rightarrow \beta$ is a trivial dependency
- $\alpha$ is a superkey for R
- Each attribute A in $\beta - \alpha$ is contained in a candidate key for R. (each attribute on the right side is a part of the candidate key)

R(A,B,C)
FDs:
AB -> C
C -> B

Candidate keys:
AB, AC


3NF exists because you sometimes cant get BCNF, lossless and dependency-preserving at the same time, but you can with 3NF.

#### comparison of BCNF and 3NF
BCNF advantages: it eliminates more redundancy than 3NF and prevents update anomalies more effectively.

3NF advantages: It is always possible to obtain a 3NF design without sacrificing losslessness on dependency preservation.

While 3NF may suffer from repetition of information or require null values, BNCF is often preferred in practice because SQL makes it difficult to enforce non-key functional dependencies efficiently anyway.

#### multivalued dependency
$\alpha ↠ \beta$
$\alpha$ decides multiple independent values of $\beta$

FD: one value
MVD: multiple independent values

Instructor(ID, Department, Hobby)

ID ↠ department
ID ↠ hobby

both are unrelated.

4NF:
For every non trivial MVD
$\alpha ↠ \beta$
$\alpha$ must be a superkey

ALL 4NF are BCNF, but not all BCNF is 4NF
















