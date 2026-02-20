Natural join:
- Finds all attributes that share the same name in both relation
- Match on these at the same time
- Remove duplicates

Outer join
- Preservers tuples that would be lost in a join, by creating null values.

	1. Left outer join
		- Preserves tuples only in the relation named before
	2. Right outer join
		- Preserves tuples only in the relation named after
	3. Full outer join
		- Preserves tuples in both relation

## Views
materialized views: if the actual relations used in the view definition changes, the view is kept up-to-date.

materialized views can be used to answer query very quickly, but must be weighed against the storage cost and the added overhead for updates.

modifications are generally not accepted on views.

A view is updateable if the following conditions are all satisfied:
- the from clause has only one database relation
- the select clause contains only one attribute names of the relation and does not have any expressions, aggregates or distinct specifications
- Any attribute not listed in the select clause can be set to null, (doesnt have a not null constraint and is not part of a primary key)
- the query does not have a group by or having clause


## Transactions
Transaction consists of a sequence of query and/or update statements.

A transaction beings implicitly when an SQL statement is executed. One of the following must end the transaction:
- Commit work: commits the current transaction. makes the updates performed become permanent. after the transaction is committed a new one is started.
- rollback work: causes the current transaction to be rolled back. Undoes the update performed by the sql statements. the database is restorted to what it was before the first statement of the transaction was executed.

If a transaction has executed commit work, it can no longer be undone by rollback work.

### Additional types
date: a calendar date: 2018-04-25
time: 09:30:00
timestamp: combination of date and time: 2018-04-25 10:29:01.45






