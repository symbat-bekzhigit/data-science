-- TODO: use explain / analyze, create an index

-- 1. Drop an existing index:
-- in case you've created an index already, add the following query at the beginning of your file:

drop index if exists athlete_event_name_idx;

-- 2. Write a simple query:
-- write a query to find all rows that contain the athlete Michael Fred Phelps, II (use the name column)
-- display all columns
-- no specific sort order is required

SELECT *
FROM athlete_event
WHERE name = 'Michael Fred Phelps, II';

-- 3. Using EXPLAIN ANALYZE:
-- Rewrite your query, but prefix with EXPLAIN ANALYZE to show how much time it takes to run your query
-- include the output of the query in a comment beneath your EXPLAIN ANALYZE statement

EXPLAIN ANALYZE
SELECT *
FROM athlete_event
WHERE name = 'Michael Fred Phelps, II';


/*                                                          QUERY PLAN                                                          
------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..8213.36 rows=3 width=137) (actual time=94.227..96.790 rows=30 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on athlete_event  (cost=0.00..7213.06 rows=1 width=137) (actual time=81.644..87.442 rows=10 loops=3)
         Filter: (name = 'Michael Fred Phelps, II'::text)
         Rows Removed by Filter: 90362
 Planning Time: 0.889 ms
 Execution Time: 96.863 ms
(8 rows) */




-- 4. Add an index:
-- write a query to add an index to the name column of the athlete_event table
-- make sure to name your index athlete_event_name_idx

CREATE INDEX athlete_event_name_idx ON athlete_event(name);



-- 5. Verifying improved performance:
-- repeat your EXPLAIN ANALYZE query from (3)
-- again, include the output of the query in a comment beneath your EXPLAIN ANALYZE statement

EXPLAIN ANALYZE
SELECT *
FROM athlete_event
WHERE name = 'Michael Fred Phelps, II';


 /*                                                              QUERY PLAN                                                                
------------------------------------------------------------------------------------------------------------------------------------------
 Index Scan using athlete_event_name_idx on athlete_event  (cost=0.42..16.44 rows=3 width=137) (actual time=0.497..0.524 rows=30 loops=1)
   Index Cond: (name = 'Michael Fred Phelps, II'::text)
 Planning Time: 2.566 ms
 Execution Time: 1.537 ms
(4 rows) */


-- 6. Ignoring an index:
-- write a query using the name column in the where clause
-- try to come up with some other operation or filter so that the index is not used (that is, an Index Scan is not used)

EXPLAIN ANALYZE
SELECT *
FROM athlete_event
WHERE LOWER(name) = 'michael fred phelps, ii';

/*                                                           QUERY PLAN                                                           
--------------------------------------------------------------------------------------------------------------------------------
 Gather  (cost=1000.00..8631.08 rows=1356 width=137) (actual time=41.608..54.350 rows=30 loops=1)
   Workers Planned: 2
   Workers Launched: 2
   ->  Parallel Seq Scan on athlete_event  (cost=0.00..7495.48 rows=565 width=137) (actual time=38.940..46.556 rows=10 loops=3)
         Filter: (lower(name) = 'michael fred phelps, ii'::text)
         Rows Removed by Filter: 90362
 Planning Time: 0.146 ms
 Execution Time: 55.327 ms
(8 rows) */
