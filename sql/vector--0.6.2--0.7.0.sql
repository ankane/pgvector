-- complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "ALTER EXTENSION vector UPDATE TO '0.7.0'" to load this file. \quit

CREATE TYPE intvec;

CREATE FUNCTION intvec_in(cstring, oid, integer) RETURNS intvec
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION intvec_out(intvec) RETURNS cstring
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION intvec_typmod_in(cstring[]) RETURNS integer
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION intvec_recv(internal, oid, integer) RETURNS intvec
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION intvec_send(intvec) RETURNS bytea
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE TYPE intvec (
	INPUT     = intvec_in,
	OUTPUT    = intvec_out,
	TYPMOD_IN = intvec_typmod_in,
	RECEIVE   = intvec_recv,
	SEND      = intvec_send,
	STORAGE   = external
);

CREATE FUNCTION l2_distance(intvec, intvec) RETURNS float8
	AS 'MODULE_PATHNAME', 'intvec_l2_distance' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION inner_product(intvec, intvec) RETURNS float8
	AS 'MODULE_PATHNAME', 'intvec_inner_product' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION cosine_distance(intvec, intvec) RETURNS float8
	AS 'MODULE_PATHNAME', 'intvec_cosine_distance' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION l1_distance(intvec, intvec) RETURNS float8
	AS 'MODULE_PATHNAME', 'intvec_l1_distance' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION intvec_l2_squared_distance(intvec, intvec) RETURNS float8
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION intvec_negative_inner_product(intvec, intvec) RETURNS float8
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION intvec(intvec, integer, boolean) RETURNS intvec
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE FUNCTION array_to_intvec(integer[], integer, boolean) RETURNS intvec
	AS 'MODULE_PATHNAME' LANGUAGE C IMMUTABLE STRICT PARALLEL SAFE;

CREATE CAST (intvec AS intvec)
	WITH FUNCTION intvec(intvec, integer, boolean) AS IMPLICIT;

CREATE CAST (integer[] AS intvec)
	WITH FUNCTION array_to_intvec(integer[], integer, boolean) AS ASSIGNMENT;

CREATE OPERATOR <-> (
	LEFTARG = intvec, RIGHTARG = intvec, PROCEDURE = l2_distance,
	COMMUTATOR = '<->'
);

CREATE OPERATOR <#> (
	LEFTARG = intvec, RIGHTARG = intvec, PROCEDURE = intvec_negative_inner_product,
	COMMUTATOR = '<#>'
);

CREATE OPERATOR <=> (
	LEFTARG = intvec, RIGHTARG = intvec, PROCEDURE = cosine_distance,
	COMMUTATOR = '<=>'
);

CREATE OPERATOR CLASS intvec_l2_ops
	FOR TYPE intvec USING hnsw AS
	OPERATOR 1 <-> (intvec, intvec) FOR ORDER BY float_ops,
	FUNCTION 1 intvec_l2_squared_distance(intvec, intvec);

CREATE OPERATOR CLASS intvec_ip_ops
	FOR TYPE intvec USING hnsw AS
	OPERATOR 1 <#> (intvec, intvec) FOR ORDER BY float_ops,
	FUNCTION 1 intvec_negative_inner_product(intvec, intvec);

CREATE OPERATOR CLASS intvec_cosine_ops
	FOR TYPE intvec USING hnsw AS
	OPERATOR 1 <=> (intvec, intvec) FOR ORDER BY float_ops,
	FUNCTION 1 cosine_distance(intvec, intvec);
