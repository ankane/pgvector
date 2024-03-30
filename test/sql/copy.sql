CREATE TABLE t (val vector(3), val2 intvec(3));
INSERT INTO t (val, val2) VALUES ('[0,0,0]', '[0,0,0]'), ('[1,2,3]', '[1,2,3]'), ('[1,1,1]', '[1,1,1]'), (NULL, NULL);

CREATE TABLE t2 (val vector(3), val2 intvec(3));

\copy t TO 'results/data.bin' WITH (FORMAT binary)
\copy t2 FROM 'results/data.bin' WITH (FORMAT binary)

SELECT * FROM t2 ORDER BY val;

DROP TABLE t;
DROP TABLE t2;
