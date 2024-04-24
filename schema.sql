--
-- PostgreSQL database dump
--

-- Dumped from database version 16.2
-- Dumped by pg_dump version 16.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: pgrouting; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgrouting WITH SCHEMA public;


--
-- Name: EXTENSION pgrouting; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgrouting IS 'pgRouting Extension';


--
-- Name: get_nearest_hospitals(double precision, double precision, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_nearest_hospitals(input_lat double precision, input_lng double precision, offset_limit integer) RETURNS TABLE(hospital_name text, latitude text, longitude text, hospital_address text, phone_no text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT
        h.name::text, -- Convert to text
        ST_Y(h.location::geometry)::text AS lat, -- Convert to text
        ST_X(h.location::geometry)::text AS lng, -- Convert to text
        h.address::text, -- Convert to text
        h.phone_no::text -- Convert to text
    FROM hospitals h
    ORDER BY h.location <-> ST_SetSRID(ST_Point(input_lng, input_lat), 4326)
    LIMIT 5 OFFSET offset_limit;
END;
$$;


ALTER FUNCTION public.get_nearest_hospitals(input_lat double precision, input_lng double precision, offset_limit integer) OWNER TO postgres;

--
-- Name: get_shortest_path(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_shortest_path(start_id integer, end_id integer) RETURNS TABLE(seq integer, node integer, edge integer, cost double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM pgr_dijkstra(
        'SELECT gid AS id, source, target, cost FROM public.georgia_roads',
        start_id, end_id, directed := true
    );
END;
$$;


ALTER FUNCTION public.get_shortest_path(start_id integer, end_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: flood_zones; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.flood_zones (
    id integer NOT NULL,
    area public.geography(Polygon,4326)
);


ALTER TABLE public.flood_zones OWNER TO postgres;

--
-- Name: flood_zones_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.flood_zones_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.flood_zones_id_seq OWNER TO postgres;

--
-- Name: flood_zones_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.flood_zones_id_seq OWNED BY public.flood_zones.id;


--
-- Name: georgia_roads; Type: TABLE; Schema: public; Owner: mbollam
--

CREATE TABLE public.georgia_roads (
    gid integer NOT NULL,
    osm_id character varying(12),
    code smallint,
    fclass character varying(28),
    name character varying(100),
    ref character varying(20),
    oneway character varying(1),
    maxspeed smallint,
    layer double precision,
    bridge character varying(1),
    tunnel character varying(1),
    geom public.geometry(MultiLineString,4326),
    cost double precision,
    source integer,
    target integer
);


ALTER TABLE public.georgia_roads OWNER TO mbollam;

--
-- Name: georgia_roads_gid_seq; Type: SEQUENCE; Schema: public; Owner: mbollam
--

CREATE SEQUENCE public.georgia_roads_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.georgia_roads_gid_seq OWNER TO mbollam;

--
-- Name: georgia_roads_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mbollam
--

ALTER SEQUENCE public.georgia_roads_gid_seq OWNED BY public.georgia_roads.gid;


--
-- Name: georgia_roads_vertices_pgr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.georgia_roads_vertices_pgr (
    id bigint NOT NULL,
    cnt integer,
    chk integer,
    ein integer,
    eout integer,
    the_geom public.geometry(Point,4326)
);


ALTER TABLE public.georgia_roads_vertices_pgr OWNER TO postgres;

--
-- Name: georgia_roads_vertices_pgr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.georgia_roads_vertices_pgr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.georgia_roads_vertices_pgr_id_seq OWNER TO postgres;

--
-- Name: georgia_roads_vertices_pgr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.georgia_roads_vertices_pgr_id_seq OWNED BY public.georgia_roads_vertices_pgr.id;


--
-- Name: hospitals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hospitals (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    location public.geography(Point,4326),
    address character varying(255),
    phone_no character varying(20),
    state character varying(20)
);


ALTER TABLE public.hospitals OWNER TO postgres;

--
-- Name: hospitals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.hospitals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.hospitals_id_seq OWNER TO postgres;

--
-- Name: hospitals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.hospitals_id_seq OWNED BY public.hospitals.id;


--
-- Name: person; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.person (
    id integer NOT NULL,
    firstname character varying(25),
    lastname character varying(20)
);


ALTER TABLE public.person OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_id_seq OWNER TO postgres;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: roads; Type: TABLE; Schema: public; Owner: mbollam
--

CREATE TABLE public.roads (
    gid integer NOT NULL,
    linearid character varying(22),
    fullname character varying(100),
    rttyp character varying(1),
    mtfcc character varying(5),
    geom public.geometry(MultiLineString,4326),
    source integer,
    target integer,
    cost double precision
);


ALTER TABLE public.roads OWNER TO mbollam;

--
-- Name: roads_gid_seq; Type: SEQUENCE; Schema: public; Owner: mbollam
--

CREATE SEQUENCE public.roads_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roads_gid_seq OWNER TO mbollam;

--
-- Name: roads_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mbollam
--

ALTER SEQUENCE public.roads_gid_seq OWNED BY public.roads.gid;


--
-- Name: roads_vertices_pgr; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roads_vertices_pgr (
    id bigint NOT NULL,
    cnt integer,
    chk integer,
    ein integer,
    eout integer,
    the_geom public.geometry(Point,4326)
);


ALTER TABLE public.roads_vertices_pgr OWNER TO postgres;

--
-- Name: roads_vertices_pgr_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roads_vertices_pgr_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.roads_vertices_pgr_id_seq OWNER TO postgres;

--
-- Name: roads_vertices_pgr_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.roads_vertices_pgr_id_seq OWNED BY public.roads_vertices_pgr.id;


--
-- Name: flood_zones id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flood_zones ALTER COLUMN id SET DEFAULT nextval('public.flood_zones_id_seq'::regclass);


--
-- Name: georgia_roads gid; Type: DEFAULT; Schema: public; Owner: mbollam
--

ALTER TABLE ONLY public.georgia_roads ALTER COLUMN gid SET DEFAULT nextval('public.georgia_roads_gid_seq'::regclass);


--
-- Name: georgia_roads_vertices_pgr id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.georgia_roads_vertices_pgr ALTER COLUMN id SET DEFAULT nextval('public.georgia_roads_vertices_pgr_id_seq'::regclass);


--
-- Name: hospitals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospitals ALTER COLUMN id SET DEFAULT nextval('public.hospitals_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: roads gid; Type: DEFAULT; Schema: public; Owner: mbollam
--

ALTER TABLE ONLY public.roads ALTER COLUMN gid SET DEFAULT nextval('public.roads_gid_seq'::regclass);


--
-- Name: roads_vertices_pgr id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roads_vertices_pgr ALTER COLUMN id SET DEFAULT nextval('public.roads_vertices_pgr_id_seq'::regclass);


--
-- Name: flood_zones flood_zones_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.flood_zones
    ADD CONSTRAINT flood_zones_pkey PRIMARY KEY (id);


--
-- Name: georgia_roads georgia_roads_pkey; Type: CONSTRAINT; Schema: public; Owner: mbollam
--

ALTER TABLE ONLY public.georgia_roads
    ADD CONSTRAINT georgia_roads_pkey PRIMARY KEY (gid);


--
-- Name: georgia_roads_vertices_pgr georgia_roads_vertices_pgr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.georgia_roads_vertices_pgr
    ADD CONSTRAINT georgia_roads_vertices_pgr_pkey PRIMARY KEY (id);


--
-- Name: hospitals hospitals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hospitals
    ADD CONSTRAINT hospitals_pkey PRIMARY KEY (id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: roads roads_pkey; Type: CONSTRAINT; Schema: public; Owner: mbollam
--

ALTER TABLE ONLY public.roads
    ADD CONSTRAINT roads_pkey PRIMARY KEY (gid);


--
-- Name: roads_vertices_pgr roads_vertices_pgr_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roads_vertices_pgr
    ADD CONSTRAINT roads_vertices_pgr_pkey PRIMARY KEY (id);


--
-- Name: georgia_roads_geom_idx; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX georgia_roads_geom_idx ON public.georgia_roads USING gist (geom);


--
-- Name: georgia_roads_source_idx; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX georgia_roads_source_idx ON public.georgia_roads USING btree (source);


--
-- Name: georgia_roads_target_idx; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX georgia_roads_target_idx ON public.georgia_roads USING btree (target);


--
-- Name: georgia_roads_vertices_pgr_the_geom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX georgia_roads_vertices_pgr_the_geom_idx ON public.georgia_roads_vertices_pgr USING gist (the_geom);


--
-- Name: idx_flood_zones_area; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_flood_zones_area ON public.flood_zones USING gist (area);


--
-- Name: idx_georgia_roads_geom; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX idx_georgia_roads_geom ON public.georgia_roads USING gist (geom);


--
-- Name: idx_hospitals_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hospitals_location ON public.hospitals USING gist (location);


--
-- Name: idx_roads_geom; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX idx_roads_geom ON public.roads USING gist (geom);


--
-- Name: idx_roads_source; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX idx_roads_source ON public.roads USING btree (source);


--
-- Name: idx_roads_target; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX idx_roads_target ON public.roads USING btree (target);


--
-- Name: roads_geom_idx; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX roads_geom_idx ON public.roads USING gist (geom);


--
-- Name: roads_source_idx; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX roads_source_idx ON public.roads USING btree (source);


--
-- Name: roads_target_idx; Type: INDEX; Schema: public; Owner: mbollam
--

CREATE INDEX roads_target_idx ON public.roads USING btree (target);


--
-- Name: roads_vertices_pgr_the_geom_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX roads_vertices_pgr_the_geom_idx ON public.roads_vertices_pgr USING gist (the_geom);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO mbollam;


--
-- Name: FUNCTION box2d_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box2d_in(cstring) TO mbollam;


--
-- Name: FUNCTION box2d_out(public.box2d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box2d_out(public.box2d) TO mbollam;


--
-- Name: FUNCTION box2df_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box2df_in(cstring) TO mbollam;


--
-- Name: FUNCTION box2df_out(public.box2df); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box2df_out(public.box2df) TO mbollam;


--
-- Name: FUNCTION box3d_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box3d_in(cstring) TO mbollam;


--
-- Name: FUNCTION box3d_out(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box3d_out(public.box3d) TO mbollam;


--
-- Name: FUNCTION geography_analyze(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_analyze(internal) TO mbollam;


--
-- Name: FUNCTION geography_in(cstring, oid, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_in(cstring, oid, integer) TO mbollam;


--
-- Name: FUNCTION geography_out(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_out(public.geography) TO mbollam;


--
-- Name: FUNCTION geography_recv(internal, oid, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_recv(internal, oid, integer) TO mbollam;


--
-- Name: FUNCTION geography_send(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_send(public.geography) TO mbollam;


--
-- Name: FUNCTION geography_typmod_in(cstring[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_typmod_in(cstring[]) TO mbollam;


--
-- Name: FUNCTION geography_typmod_out(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_typmod_out(integer) TO mbollam;


--
-- Name: FUNCTION geometry_analyze(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_analyze(internal) TO mbollam;


--
-- Name: FUNCTION geometry_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_in(cstring) TO mbollam;


--
-- Name: FUNCTION geometry_out(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_out(public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_recv(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_recv(internal) TO mbollam;


--
-- Name: FUNCTION geometry_send(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_send(public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_typmod_in(cstring[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_typmod_in(cstring[]) TO mbollam;


--
-- Name: FUNCTION geometry_typmod_out(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_typmod_out(integer) TO mbollam;


--
-- Name: FUNCTION gidx_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gidx_in(cstring) TO mbollam;


--
-- Name: FUNCTION gidx_out(public.gidx); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gidx_out(public.gidx) TO mbollam;


--
-- Name: FUNCTION spheroid_in(cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.spheroid_in(cstring) TO mbollam;


--
-- Name: FUNCTION spheroid_out(public.spheroid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.spheroid_out(public.spheroid) TO mbollam;


--
-- Name: FUNCTION box3d(public.box2d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box3d(public.box2d) TO mbollam;


--
-- Name: FUNCTION geometry(public.box2d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(public.box2d) TO mbollam;


--
-- Name: FUNCTION box(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box(public.box3d) TO mbollam;


--
-- Name: FUNCTION box2d(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box2d(public.box3d) TO mbollam;


--
-- Name: FUNCTION geometry(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(public.box3d) TO mbollam;


--
-- Name: FUNCTION geography(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography(bytea) TO mbollam;


--
-- Name: FUNCTION geometry(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(bytea) TO mbollam;


--
-- Name: FUNCTION bytea(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.bytea(public.geography) TO mbollam;


--
-- Name: FUNCTION geography(public.geography, integer, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography(public.geography, integer, boolean) TO mbollam;


--
-- Name: FUNCTION geometry(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(public.geography) TO mbollam;


--
-- Name: FUNCTION box(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box(public.geometry) TO mbollam;


--
-- Name: FUNCTION box2d(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box2d(public.geometry) TO mbollam;


--
-- Name: FUNCTION box3d(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box3d(public.geometry) TO mbollam;


--
-- Name: FUNCTION bytea(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.bytea(public.geometry) TO mbollam;


--
-- Name: FUNCTION geography(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography(public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry(public.geometry, integer, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(public.geometry, integer, boolean) TO mbollam;


--
-- Name: FUNCTION json(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.json(public.geometry) TO mbollam;


--
-- Name: FUNCTION jsonb(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.jsonb(public.geometry) TO mbollam;


--
-- Name: FUNCTION path(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.path(public.geometry) TO mbollam;


--
-- Name: FUNCTION point(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.point(public.geometry) TO mbollam;


--
-- Name: FUNCTION polygon(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.polygon(public.geometry) TO mbollam;


--
-- Name: FUNCTION text(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.text(public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry(path); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(path) TO mbollam;


--
-- Name: FUNCTION geometry(point); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(point) TO mbollam;


--
-- Name: FUNCTION geometry(polygon); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(polygon) TO mbollam;


--
-- Name: FUNCTION geometry(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry(text) TO mbollam;


--
-- Name: FUNCTION _pgr_alphashape(text, alpha double precision, OUT seq1 bigint, OUT textgeom text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_alphashape(text, alpha double precision, OUT seq1 bigint, OUT textgeom text) TO mbollam;


--
-- Name: FUNCTION _pgr_array_reverse(anyarray); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_array_reverse(anyarray) TO mbollam;


--
-- Name: FUNCTION _pgr_articulationpoints(edges_sql text, OUT seq integer, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_articulationpoints(edges_sql text, OUT seq integer, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_astar(edges_sql text, combinations_sql text, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_astar(edges_sql text, combinations_sql text, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_astar(edges_sql text, start_vids anyarray, end_vids anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, normal boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_astar(edges_sql text, start_vids anyarray, end_vids anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, normal boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bdastar(text, text, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bdastar(text, text, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bdastar(text, anyarray, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bdastar(text, anyarray, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bddijkstra(text, text, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bddijkstra(text, text, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bddijkstra(text, anyarray, anyarray, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bddijkstra(text, anyarray, anyarray, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bellmanford(edges_sql text, combinations_sql text, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bellmanford(edges_sql text, combinations_sql text, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bellmanford(edges_sql text, from_vids anyarray, to_vids anyarray, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bellmanford(edges_sql text, from_vids anyarray, to_vids anyarray, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_biconnectedcomponents(edges_sql text, OUT seq bigint, OUT component bigint, OUT edge bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_biconnectedcomponents(edges_sql text, OUT seq bigint, OUT component bigint, OUT edge bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_binarybreadthfirstsearch(edges_sql text, combinations_sql text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_binarybreadthfirstsearch(edges_sql text, combinations_sql text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_binarybreadthfirstsearch(edges_sql text, from_vids anyarray, to_vids anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_binarybreadthfirstsearch(edges_sql text, from_vids anyarray, to_vids anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bipartite(edges_sql text, OUT node bigint, OUT color bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bipartite(edges_sql text, OUT node bigint, OUT color bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_boost_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_boost_version() TO mbollam;


--
-- Name: FUNCTION _pgr_breadthfirstsearch(edges_sql text, from_vids anyarray, max_depth bigint, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_breadthfirstsearch(edges_sql text, from_vids anyarray, max_depth bigint, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_bridges(edges_sql text, OUT seq integer, OUT edge bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_bridges(edges_sql text, OUT seq integer, OUT edge bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_build_type(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_build_type() TO mbollam;


--
-- Name: FUNCTION _pgr_checkcolumn(text, text, text, is_optional boolean, dryrun boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_checkcolumn(text, text, text, is_optional boolean, dryrun boolean) TO mbollam;


--
-- Name: FUNCTION _pgr_checkquery(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_checkquery(text) TO mbollam;


--
-- Name: FUNCTION _pgr_checkverttab(vertname text, columnsarr text[], reporterrs integer, fnname text, OUT sname text, OUT vname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_checkverttab(vertname text, columnsarr text[], reporterrs integer, fnname text, OUT sname text, OUT vname text) TO mbollam;


--
-- Name: FUNCTION _pgr_chinesepostman(edges_sql text, only_cost boolean, OUT seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_chinesepostman(edges_sql text, only_cost boolean, OUT seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_compilation_date(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_compilation_date() TO mbollam;


--
-- Name: FUNCTION _pgr_compiler_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_compiler_version() TO mbollam;


--
-- Name: FUNCTION _pgr_connectedcomponents(edges_sql text, OUT seq bigint, OUT component bigint, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_connectedcomponents(edges_sql text, OUT seq bigint, OUT component bigint, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_contraction(edges_sql text, contraction_order bigint[], max_cycles integer, forbidden_vertices bigint[], directed boolean, OUT type text, OUT id bigint, OUT contracted_vertices bigint[], OUT source bigint, OUT target bigint, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_contraction(edges_sql text, contraction_order bigint[], max_cycles integer, forbidden_vertices bigint[], directed boolean, OUT type text, OUT id bigint, OUT contracted_vertices bigint[], OUT source bigint, OUT target bigint, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_createindex(tabname text, colname text, indext text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_createindex(tabname text, colname text, indext text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_createindex(sname text, tname text, colname text, indext text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_createindex(sname text, tname text, colname text, indext text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_cuthillmckeeordering(text, OUT seq bigint, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_cuthillmckeeordering(text, OUT seq bigint, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_dagshortestpath(text, text, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dagshortestpath(text, text, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dagshortestpath(text, anyarray, anyarray, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dagshortestpath(text, anyarray, anyarray, directed boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_depthfirstsearch(edges_sql text, root_vids anyarray, directed boolean, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_depthfirstsearch(edges_sql text, root_vids anyarray, directed boolean, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstra(edges_sql text, combinations_sql text, directed boolean, only_cost boolean, normal boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstra(edges_sql text, combinations_sql text, directed boolean, only_cost boolean, normal boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstra(edges_sql text, combinations_sql text, directed boolean, only_cost boolean, n_goals bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstra(edges_sql text, combinations_sql text, directed boolean, only_cost boolean, n_goals bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstra(edges_sql text, start_vids anyarray, end_vids anyarray, directed boolean, only_cost boolean, normal boolean, n_goals bigint, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstra(edges_sql text, start_vids anyarray, end_vids anyarray, directed boolean, only_cost boolean, normal boolean, n_goals bigint, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstra(edges_sql text, start_vids anyarray, end_vids anyarray, directed boolean, only_cost boolean, normal boolean, n_goals bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstra(edges_sql text, start_vids anyarray, end_vids anyarray, directed boolean, only_cost boolean, normal boolean, n_goals bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstranear(text, anyarray, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstranear(text, anyarray, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstranear(text, anyarray, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstranear(text, anyarray, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstranear(text, bigint, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstranear(text, bigint, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_dijkstravia(edges_sql text, via_vids anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_dijkstravia(edges_sql text, via_vids anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_drivingdistance(edges_sql text, start_vids anyarray, distance double precision, directed boolean, equicost boolean, OUT seq integer, OUT from_v bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_drivingdistance(edges_sql text, start_vids anyarray, distance double precision, directed boolean, equicost boolean, OUT seq integer, OUT from_v bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_drivingdistancev4(text, anyarray, double precision, boolean, boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_drivingdistancev4(text, anyarray, double precision, boolean, boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_edgecoloring(edges_sql text, OUT edge_id bigint, OUT color_id bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_edgecoloring(edges_sql text, OUT edge_id bigint, OUT color_id bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_edgedisjointpaths(text, text, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_edgedisjointpaths(text, text, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_edgedisjointpaths(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_edgedisjointpaths(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_edwardmoore(edges_sql text, combinations_sql text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_edwardmoore(edges_sql text, combinations_sql text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_edwardmoore(edges_sql text, from_vids anyarray, to_vids anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_edwardmoore(edges_sql text, from_vids anyarray, to_vids anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_endpoint(g public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_endpoint(g public.geometry) TO mbollam;


--
-- Name: FUNCTION _pgr_floydwarshall(edges_sql text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_floydwarshall(edges_sql text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_get_statement(o_sql text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_get_statement(o_sql text) TO mbollam;


--
-- Name: FUNCTION _pgr_getcolumnname(tab text, col text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_getcolumnname(tab text, col text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_getcolumnname(sname text, tname text, col text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_getcolumnname(sname text, tname text, col text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_getcolumntype(tab text, col text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_getcolumntype(tab text, col text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_getcolumntype(sname text, tname text, cname text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_getcolumntype(sname text, tname text, cname text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_gettablename(tab text, reporterrs integer, fnname text, OUT sname text, OUT tname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_gettablename(tab text, reporterrs integer, fnname text, OUT sname text, OUT tname text) TO mbollam;


--
-- Name: FUNCTION _pgr_git_hash(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_git_hash() TO mbollam;


--
-- Name: FUNCTION _pgr_hawickcircuits(text, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_hawickcircuits(text, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_iscolumnindexed(tab text, col text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_iscolumnindexed(tab text, col text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_iscolumnindexed(sname text, tname text, cname text, reporterrs integer, fnname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_iscolumnindexed(sname text, tname text, cname text, reporterrs integer, fnname text) TO mbollam;


--
-- Name: FUNCTION _pgr_iscolumnintable(tab text, col text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_iscolumnintable(tab text, col text) TO mbollam;


--
-- Name: FUNCTION _pgr_isplanar(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_isplanar(text) TO mbollam;


--
-- Name: FUNCTION _pgr_johnson(edges_sql text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_johnson(edges_sql text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_kruskal(text, anyarray, fn_suffix text, max_depth bigint, distance double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_kruskal(text, anyarray, fn_suffix text, max_depth bigint, distance double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_ksp(text, text, integer, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_ksp(text, text, integer, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_ksp(edges_sql text, start_vid bigint, end_vid bigint, k integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_ksp(edges_sql text, start_vid bigint, end_vid bigint, k integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_ksp(text, anyarray, anyarray, integer, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_ksp(text, anyarray, anyarray, integer, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_lengauertarjandominatortree(edges_sql text, root_vid bigint, OUT seq integer, OUT vid bigint, OUT idom bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_lengauertarjandominatortree(edges_sql text, root_vid bigint, OUT seq integer, OUT vid bigint, OUT idom bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_lib_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_lib_version() TO mbollam;


--
-- Name: FUNCTION _pgr_linegraph(text, directed boolean, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT reverse_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_linegraph(text, directed boolean, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT reverse_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_linegraphfull(text, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT edge bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_linegraphfull(text, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT edge bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_makeconnected(text, OUT seq bigint, OUT start_vid bigint, OUT end_vid bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_makeconnected(text, OUT seq bigint, OUT start_vid bigint, OUT end_vid bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_maxcardinalitymatch(edges_sql text, directed boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_maxcardinalitymatch(edges_sql text, directed boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_maxflow(edges_sql text, combinations_sql text, algorithm integer, only_flow boolean, OUT seq integer, OUT edge_id bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_maxflow(edges_sql text, combinations_sql text, algorithm integer, only_flow boolean, OUT seq integer, OUT edge_id bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_maxflow(edges_sql text, sources anyarray, targets anyarray, algorithm integer, only_flow boolean, OUT seq integer, OUT edge_id bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_maxflow(edges_sql text, sources anyarray, targets anyarray, algorithm integer, only_flow boolean, OUT seq integer, OUT edge_id bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_maxflowmincost(edges_sql text, combinations_sql text, only_cost boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_maxflowmincost(edges_sql text, combinations_sql text, only_cost boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_maxflowmincost(edges_sql text, sources anyarray, targets anyarray, only_cost boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_maxflowmincost(edges_sql text, sources anyarray, targets anyarray, only_cost boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_msg(msgkind integer, fnname text, msg text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_msg(msgkind integer, fnname text, msg text) TO mbollam;


--
-- Name: FUNCTION _pgr_onerror(errcond boolean, reporterrs integer, fnname text, msgerr text, hinto text, msgok text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_onerror(errcond boolean, reporterrs integer, fnname text, msgerr text, hinto text, msgok text) TO mbollam;


--
-- Name: FUNCTION _pgr_operating_system(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_operating_system() TO mbollam;


--
-- Name: FUNCTION _pgr_parameter_check(fn text, sql text, big boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_parameter_check(fn text, sql text, big boolean) TO mbollam;


--
-- Name: FUNCTION _pgr_pgsql_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_pgsql_version() TO mbollam;


--
-- Name: FUNCTION _pgr_pickdeliver(text, text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT stop_id bigint, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_pickdeliver(text, text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT stop_id bigint, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_pickdelivereuclidean(text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_pickdelivereuclidean(text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_pointtoid(point public.geometry, tolerance double precision, vertname text, srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_pointtoid(point public.geometry, tolerance double precision, vertname text, srid integer) TO mbollam;


--
-- Name: FUNCTION _pgr_prim(text, anyarray, order_by text, max_depth bigint, distance double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_prim(text, anyarray, order_by text, max_depth bigint, distance double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_quote_ident(idname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_quote_ident(idname text) TO mbollam;


--
-- Name: FUNCTION _pgr_sequentialvertexcoloring(edges_sql text, OUT vertex_id bigint, OUT color_id bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_sequentialvertexcoloring(edges_sql text, OUT vertex_id bigint, OUT color_id bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_startpoint(g public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_startpoint(g public.geometry) TO mbollam;


--
-- Name: FUNCTION _pgr_stoerwagner(edges_sql text, OUT seq integer, OUT edge bigint, OUT cost double precision, OUT mincut double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_stoerwagner(edges_sql text, OUT seq integer, OUT edge bigint, OUT cost double precision, OUT mincut double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_strongcomponents(edges_sql text, OUT seq bigint, OUT component bigint, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_strongcomponents(edges_sql text, OUT seq bigint, OUT component bigint, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_topologicalsort(edges_sql text, OUT seq integer, OUT sorted_v bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_topologicalsort(edges_sql text, OUT seq integer, OUT sorted_v bigint) TO mbollam;


--
-- Name: FUNCTION _pgr_transitiveclosure(edges_sql text, OUT seq integer, OUT vid bigint, OUT target_array bigint[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_transitiveclosure(edges_sql text, OUT seq integer, OUT vid bigint, OUT target_array bigint[]) TO mbollam;


--
-- Name: FUNCTION _pgr_trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trsp(text, text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trsp(text, text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trsp(text, text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trsp(text, text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trsp(text, text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trsp(text, text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trsp(sql text, source_eid integer, source_pos double precision, target_eid integer, target_pos double precision, directed boolean, has_reverse_cost boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trsp(sql text, source_eid integer, source_pos double precision, target_eid integer, target_pos double precision, directed boolean, has_reverse_cost boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trsp_withpoints(text, text, text, text, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT departure bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trsp_withpoints(text, text, text, text, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT departure bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trsp_withpoints(text, text, text, anyarray, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT departure bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trsp_withpoints(text, text, text, anyarray, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT departure bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trspv4(text, text, text, boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trspv4(text, text, text, boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trspv4(text, text, anyarray, anyarray, boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trspv4(text, text, anyarray, anyarray, boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trspvia(text, text, anyarray, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trspvia(text, text, anyarray, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trspvia_withpoints(text, text, text, anyarray, boolean, boolean, boolean, character, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trspvia_withpoints(text, text, text, anyarray, boolean, boolean, boolean, character, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_trspviavertices(sql text, vids integer[], directed boolean, has_rcost boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT id3 integer, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_trspviavertices(sql text, vids integer[], directed boolean, has_rcost boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT id3 integer, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_tsp(matrix_row_sql text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_tsp(matrix_row_sql text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_tspeuclidean(coordinates_sql text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_tspeuclidean(coordinates_sql text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_turnrestrictedpath(text, text, bigint, bigint, integer, directed boolean, heap_paths boolean, stop_on_first boolean, strict boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_turnrestrictedpath(text, text, bigint, bigint, integer, directed boolean, heap_paths boolean, stop_on_first boolean, strict boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_versionless(v1 text, v2 text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_versionless(v1 text, v2 text) TO mbollam;


--
-- Name: FUNCTION _pgr_vrponedepot(text, text, text, integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT stop_id bigint, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_vrponedepot(text, text, text, integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT stop_id bigint, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpoints(edges_sql text, points_sql text, combinations_sql text, directed boolean, driving_side character, details boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpoints(edges_sql text, points_sql text, combinations_sql text, directed boolean, driving_side character, details boolean, only_cost boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpoints(edges_sql text, points_sql text, start_pids anyarray, end_pids anyarray, directed boolean, driving_side character, details boolean, only_cost boolean, normal boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpoints(edges_sql text, points_sql text, start_pids anyarray, end_pids anyarray, directed boolean, driving_side character, details boolean, only_cost boolean, normal boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpointsdd(edges_sql text, points_sql text, start_pid anyarray, distance double precision, directed boolean, driving_side character, details boolean, equicost boolean, OUT seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpointsdd(edges_sql text, points_sql text, start_pid anyarray, distance double precision, directed boolean, driving_side character, details boolean, equicost boolean, OUT seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpointsddv4(text, text, anyarray, double precision, character, boolean, boolean, boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpointsddv4(text, text, anyarray, double precision, character, boolean, boolean, boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpointsksp(text, text, text, integer, character, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpointsksp(text, text, text, integer, character, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpointsksp(edges_sql text, points_sql text, start_pid bigint, end_pid bigint, k integer, directed boolean, heap_paths boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpointsksp(edges_sql text, points_sql text, start_pid bigint, end_pid bigint, k integer, directed boolean, heap_paths boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpointsksp(text, text, anyarray, anyarray, integer, character, boolean, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpointsksp(text, text, anyarray, anyarray, integer, character, boolean, boolean, boolean, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpointsvia(sql text, via_edges bigint[], fraction double precision[], directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpointsvia(sql text, via_edges bigint[], fraction double precision[], directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _pgr_withpointsvia(text, text, anyarray, boolean, boolean, boolean, character, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._pgr_withpointsvia(text, text, anyarray, boolean, boolean, boolean, character, boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _postgis_deprecate(oldname text, newname text, version text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._postgis_deprecate(oldname text, newname text, version text) TO mbollam;


--
-- Name: FUNCTION _postgis_index_extent(tbl regclass, col text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._postgis_index_extent(tbl regclass, col text) TO mbollam;


--
-- Name: FUNCTION _postgis_join_selectivity(regclass, text, regclass, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._postgis_join_selectivity(regclass, text, regclass, text, text) TO mbollam;


--
-- Name: FUNCTION _postgis_pgsql_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._postgis_pgsql_version() TO mbollam;


--
-- Name: FUNCTION _postgis_scripts_pgsql_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._postgis_scripts_pgsql_version() TO mbollam;


--
-- Name: FUNCTION _postgis_selectivity(tbl regclass, att_name text, geom public.geometry, mode text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._postgis_selectivity(tbl regclass, att_name text, geom public.geometry, mode text) TO mbollam;


--
-- Name: FUNCTION _postgis_stats(tbl regclass, att_name text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._postgis_stats(tbl regclass, att_name text, text) TO mbollam;


--
-- Name: FUNCTION _st_3ddfullywithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_3ddfullywithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION _st_3ddwithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_3ddwithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION _st_3dintersects(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_3dintersects(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_asgml(integer, public.geometry, integer, integer, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_asgml(integer, public.geometry, integer, integer, text, text) TO mbollam;


--
-- Name: FUNCTION _st_asx3d(integer, public.geometry, integer, integer, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_asx3d(integer, public.geometry, integer, integer, text) TO mbollam;


--
-- Name: FUNCTION _st_bestsrid(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_bestsrid(public.geography) TO mbollam;


--
-- Name: FUNCTION _st_bestsrid(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_bestsrid(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION _st_contains(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_contains(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_containsproperly(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_containsproperly(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_coveredby(geog1 public.geography, geog2 public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_coveredby(geog1 public.geography, geog2 public.geography) TO mbollam;


--
-- Name: FUNCTION _st_coveredby(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_coveredby(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_covers(geog1 public.geography, geog2 public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_covers(geog1 public.geography, geog2 public.geography) TO mbollam;


--
-- Name: FUNCTION _st_covers(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_covers(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_crosses(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_crosses(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_dfullywithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_dfullywithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION _st_distancetree(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_distancetree(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION _st_distancetree(public.geography, public.geography, double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_distancetree(public.geography, public.geography, double precision, boolean) TO mbollam;


--
-- Name: FUNCTION _st_distanceuncached(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_distanceuncached(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION _st_distanceuncached(public.geography, public.geography, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_distanceuncached(public.geography, public.geography, boolean) TO mbollam;


--
-- Name: FUNCTION _st_distanceuncached(public.geography, public.geography, double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_distanceuncached(public.geography, public.geography, double precision, boolean) TO mbollam;


--
-- Name: FUNCTION _st_dwithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_dwithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION _st_dwithin(geog1 public.geography, geog2 public.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_dwithin(geog1 public.geography, geog2 public.geography, tolerance double precision, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION _st_dwithinuncached(public.geography, public.geography, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_dwithinuncached(public.geography, public.geography, double precision) TO mbollam;


--
-- Name: FUNCTION _st_dwithinuncached(public.geography, public.geography, double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_dwithinuncached(public.geography, public.geography, double precision, boolean) TO mbollam;


--
-- Name: FUNCTION _st_equals(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_equals(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_expand(public.geography, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_expand(public.geography, double precision) TO mbollam;


--
-- Name: FUNCTION _st_geomfromgml(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_geomfromgml(text, integer) TO mbollam;


--
-- Name: FUNCTION _st_intersects(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_intersects(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_linecrossingdirection(line1 public.geometry, line2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_linecrossingdirection(line1 public.geometry, line2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_longestline(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_longestline(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_maxdistance(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_maxdistance(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_orderingequals(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_orderingequals(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_overlaps(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_overlaps(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_pointoutside(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_pointoutside(public.geography) TO mbollam;


--
-- Name: FUNCTION _st_sortablehash(geom public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_sortablehash(geom public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_touches(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_touches(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _st_voronoi(g1 public.geometry, clip public.geometry, tolerance double precision, return_polygons boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_voronoi(g1 public.geometry, clip public.geometry, tolerance double precision, return_polygons boolean) TO mbollam;


--
-- Name: FUNCTION _st_within(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._st_within(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION _trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _v4trsp(text, text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._v4trsp(text, text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION _v4trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public._v4trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION addauth(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.addauth(text) TO mbollam;


--
-- Name: FUNCTION addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.addgeometrycolumn(table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) TO mbollam;


--
-- Name: FUNCTION addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.addgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying, new_srid integer, new_type character varying, new_dim integer, use_typmod boolean) TO mbollam;


--
-- Name: FUNCTION addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.addgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer, new_type character varying, new_dim integer, use_typmod boolean) TO mbollam;


--
-- Name: FUNCTION box3dtobox(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.box3dtobox(public.box3d) TO mbollam;


--
-- Name: FUNCTION checkauth(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.checkauth(text, text) TO mbollam;


--
-- Name: FUNCTION checkauth(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.checkauth(text, text, text) TO mbollam;


--
-- Name: FUNCTION checkauthtrigger(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.checkauthtrigger() TO mbollam;


--
-- Name: FUNCTION contains_2d(public.box2df, public.box2df); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.contains_2d(public.box2df, public.box2df) TO mbollam;


--
-- Name: FUNCTION contains_2d(public.box2df, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.contains_2d(public.box2df, public.geometry) TO mbollam;


--
-- Name: FUNCTION contains_2d(public.geometry, public.box2df); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.contains_2d(public.geometry, public.box2df) TO mbollam;


--
-- Name: FUNCTION disablelongtransactions(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.disablelongtransactions() TO mbollam;


--
-- Name: FUNCTION dropgeometrycolumn(table_name character varying, column_name character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dropgeometrycolumn(table_name character varying, column_name character varying) TO mbollam;


--
-- Name: FUNCTION dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dropgeometrycolumn(schema_name character varying, table_name character varying, column_name character varying) TO mbollam;


--
-- Name: FUNCTION dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dropgeometrycolumn(catalog_name character varying, schema_name character varying, table_name character varying, column_name character varying) TO mbollam;


--
-- Name: FUNCTION dropgeometrytable(table_name character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dropgeometrytable(table_name character varying) TO mbollam;


--
-- Name: FUNCTION dropgeometrytable(schema_name character varying, table_name character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dropgeometrytable(schema_name character varying, table_name character varying) TO mbollam;


--
-- Name: FUNCTION dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.dropgeometrytable(catalog_name character varying, schema_name character varying, table_name character varying) TO mbollam;


--
-- Name: FUNCTION enablelongtransactions(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.enablelongtransactions() TO mbollam;


--
-- Name: FUNCTION equals(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.equals(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION find_srid(character varying, character varying, character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.find_srid(character varying, character varying, character varying) TO mbollam;


--
-- Name: FUNCTION geog_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geog_brin_inclusion_add_value(internal, internal, internal, internal) TO mbollam;


--
-- Name: FUNCTION geography_cmp(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_cmp(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_distance_knn(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_distance_knn(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_eq(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_eq(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_ge(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_ge(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_gist_compress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_compress(internal) TO mbollam;


--
-- Name: FUNCTION geography_gist_consistent(internal, public.geography, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_consistent(internal, public.geography, integer) TO mbollam;


--
-- Name: FUNCTION geography_gist_decompress(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_decompress(internal) TO mbollam;


--
-- Name: FUNCTION geography_gist_distance(internal, public.geography, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_distance(internal, public.geography, integer) TO mbollam;


--
-- Name: FUNCTION geography_gist_penalty(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_penalty(internal, internal, internal) TO mbollam;


--
-- Name: FUNCTION geography_gist_picksplit(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_picksplit(internal, internal) TO mbollam;


--
-- Name: FUNCTION geography_gist_same(public.box2d, public.box2d, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_same(public.box2d, public.box2d, internal) TO mbollam;


--
-- Name: FUNCTION geography_gist_union(bytea, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gist_union(bytea, internal) TO mbollam;


--
-- Name: FUNCTION geography_gt(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_gt(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_le(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_le(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_lt(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_lt(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_overlaps(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_overlaps(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION geography_spgist_choose_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_spgist_choose_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geography_spgist_compress_nd(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_spgist_compress_nd(internal) TO mbollam;


--
-- Name: FUNCTION geography_spgist_config_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_spgist_config_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geography_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_spgist_inner_consistent_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geography_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_spgist_leaf_consistent_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geography_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geography_spgist_picksplit_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geom2d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geom2d_brin_inclusion_add_value(internal, internal, internal, internal) TO mbollam;


--
-- Name: FUNCTION geom3d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geom3d_brin_inclusion_add_value(internal, internal, internal, internal) TO mbollam;


--
-- Name: FUNCTION geom4d_brin_inclusion_add_value(internal, internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geom4d_brin_inclusion_add_value(internal, internal, internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_above(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_above(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_below(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_below(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_cmp(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_cmp(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_contained_3d(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_contained_3d(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_contains(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_contains(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_contains_3d(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_contains_3d(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_contains_nd(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_contains_nd(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_distance_box(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_distance_box(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_distance_centroid(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_distance_centroid(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_distance_centroid_nd(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_distance_centroid_nd(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_distance_cpa(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_distance_cpa(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_eq(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_eq(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_ge(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_ge(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_gist_compress_2d(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_compress_2d(internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_compress_nd(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_compress_nd(internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_consistent_2d(internal, public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_consistent_2d(internal, public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION geometry_gist_consistent_nd(internal, public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_consistent_nd(internal, public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION geometry_gist_decompress_2d(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_decompress_2d(internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_decompress_nd(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_decompress_nd(internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_distance_2d(internal, public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_distance_2d(internal, public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION geometry_gist_distance_nd(internal, public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_distance_nd(internal, public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION geometry_gist_penalty_2d(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_penalty_2d(internal, internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_penalty_nd(internal, internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_penalty_nd(internal, internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_picksplit_2d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_picksplit_2d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_picksplit_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_picksplit_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_same_2d(geom1 public.geometry, geom2 public.geometry, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_same_2d(geom1 public.geometry, geom2 public.geometry, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_same_nd(public.geometry, public.geometry, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_same_nd(public.geometry, public.geometry, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_sortsupport_2d(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_sortsupport_2d(internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_union_2d(bytea, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_union_2d(bytea, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gist_union_nd(bytea, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gist_union_nd(bytea, internal) TO mbollam;


--
-- Name: FUNCTION geometry_gt(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_gt(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_hash(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_hash(public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_le(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_le(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_left(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_left(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_lt(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_lt(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_overabove(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_overabove(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_overbelow(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_overbelow(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_overlaps(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_overlaps(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_overlaps_3d(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_overlaps_3d(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_overlaps_nd(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_overlaps_nd(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_overleft(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_overleft(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_overright(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_overright(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_right(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_right(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_same(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_same(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_same_3d(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_same_3d(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_same_nd(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_same_nd(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_sortsupport(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_sortsupport(internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_choose_2d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_choose_2d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_choose_3d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_choose_3d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_choose_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_choose_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_compress_2d(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_compress_2d(internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_compress_3d(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_compress_3d(internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_compress_nd(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_compress_nd(internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_config_2d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_config_2d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_config_3d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_config_3d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_config_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_config_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_inner_consistent_2d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_inner_consistent_2d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_inner_consistent_3d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_inner_consistent_3d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_inner_consistent_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_inner_consistent_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_leaf_consistent_2d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_leaf_consistent_2d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_leaf_consistent_3d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_leaf_consistent_3d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_leaf_consistent_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_leaf_consistent_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_picksplit_2d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_picksplit_2d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_picksplit_3d(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_picksplit_3d(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_spgist_picksplit_nd(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_spgist_picksplit_nd(internal, internal) TO mbollam;


--
-- Name: FUNCTION geometry_within(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_within(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION geometry_within_nd(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometry_within_nd(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION geometrytype(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometrytype(public.geography) TO mbollam;


--
-- Name: FUNCTION geometrytype(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geometrytype(public.geometry) TO mbollam;


--
-- Name: FUNCTION geomfromewkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geomfromewkb(bytea) TO mbollam;


--
-- Name: FUNCTION geomfromewkt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.geomfromewkt(text) TO mbollam;


--
-- Name: FUNCTION get_nearest_hospitals(input_lat double precision, input_lng double precision, offset_limit integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_nearest_hospitals(input_lat double precision, input_lng double precision, offset_limit integer) TO mbollam;


--
-- Name: FUNCTION get_proj4_from_srid(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_proj4_from_srid(integer) TO mbollam;


--
-- Name: FUNCTION get_shortest_path(start_id integer, end_id integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.get_shortest_path(start_id integer, end_id integer) TO mbollam;


--
-- Name: FUNCTION gettransactionid(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gettransactionid() TO mbollam;


--
-- Name: FUNCTION gserialized_gist_joinsel_2d(internal, oid, internal, smallint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gserialized_gist_joinsel_2d(internal, oid, internal, smallint) TO mbollam;


--
-- Name: FUNCTION gserialized_gist_joinsel_nd(internal, oid, internal, smallint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gserialized_gist_joinsel_nd(internal, oid, internal, smallint) TO mbollam;


--
-- Name: FUNCTION gserialized_gist_sel_2d(internal, oid, internal, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gserialized_gist_sel_2d(internal, oid, internal, integer) TO mbollam;


--
-- Name: FUNCTION gserialized_gist_sel_nd(internal, oid, internal, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.gserialized_gist_sel_nd(internal, oid, internal, integer) TO mbollam;


--
-- Name: FUNCTION is_contained_2d(public.box2df, public.box2df); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_contained_2d(public.box2df, public.box2df) TO mbollam;


--
-- Name: FUNCTION is_contained_2d(public.box2df, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_contained_2d(public.box2df, public.geometry) TO mbollam;


--
-- Name: FUNCTION is_contained_2d(public.geometry, public.box2df); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.is_contained_2d(public.geometry, public.box2df) TO mbollam;


--
-- Name: FUNCTION lockrow(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.lockrow(text, text, text) TO mbollam;


--
-- Name: FUNCTION lockrow(text, text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.lockrow(text, text, text, text) TO mbollam;


--
-- Name: FUNCTION lockrow(text, text, text, timestamp without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.lockrow(text, text, text, timestamp without time zone) TO mbollam;


--
-- Name: FUNCTION lockrow(text, text, text, text, timestamp without time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.lockrow(text, text, text, text, timestamp without time zone) TO mbollam;


--
-- Name: FUNCTION longtransactionsenabled(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.longtransactionsenabled() TO mbollam;


--
-- Name: FUNCTION overlaps_2d(public.box2df, public.box2df); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_2d(public.box2df, public.box2df) TO mbollam;


--
-- Name: FUNCTION overlaps_2d(public.box2df, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_2d(public.box2df, public.geometry) TO mbollam;


--
-- Name: FUNCTION overlaps_2d(public.geometry, public.box2df); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_2d(public.geometry, public.box2df) TO mbollam;


--
-- Name: FUNCTION overlaps_geog(public.geography, public.gidx); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_geog(public.geography, public.gidx) TO mbollam;


--
-- Name: FUNCTION overlaps_geog(public.gidx, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_geog(public.gidx, public.geography) TO mbollam;


--
-- Name: FUNCTION overlaps_geog(public.gidx, public.gidx); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_geog(public.gidx, public.gidx) TO mbollam;


--
-- Name: FUNCTION overlaps_nd(public.geometry, public.gidx); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_nd(public.geometry, public.gidx) TO mbollam;


--
-- Name: FUNCTION overlaps_nd(public.gidx, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_nd(public.gidx, public.geometry) TO mbollam;


--
-- Name: FUNCTION overlaps_nd(public.gidx, public.gidx); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.overlaps_nd(public.gidx, public.gidx) TO mbollam;


--
-- Name: FUNCTION pgis_asflatgeobuf_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asflatgeobuf_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asflatgeobuf_transfn(internal, anyelement) TO mbollam;


--
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asflatgeobuf_transfn(internal, anyelement, boolean) TO mbollam;


--
-- Name: FUNCTION pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asflatgeobuf_transfn(internal, anyelement, boolean, text) TO mbollam;


--
-- Name: FUNCTION pgis_asgeobuf_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asgeobuf_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asgeobuf_transfn(internal, anyelement) TO mbollam;


--
-- Name: FUNCTION pgis_asgeobuf_transfn(internal, anyelement, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asgeobuf_transfn(internal, anyelement, text) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_combinefn(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_combinefn(internal, internal) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_deserialfn(bytea, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_deserialfn(bytea, internal) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_serialfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_serialfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_transfn(internal, anyelement) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_transfn(internal, anyelement, text) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_transfn(internal, anyelement, text, integer) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_transfn(internal, anyelement, text, integer, text) TO mbollam;


--
-- Name: FUNCTION pgis_asmvt_transfn(internal, anyelement, text, integer, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_asmvt_transfn(internal, anyelement, text, integer, text, text) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_accum_transfn(internal, public.geometry) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_accum_transfn(internal, public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_accum_transfn(internal, public.geometry, double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_accum_transfn(internal, public.geometry, double precision, integer) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_clusterintersecting_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_clusterintersecting_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_clusterwithin_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_clusterwithin_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_collect_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_collect_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_coverageunion_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_coverageunion_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_makeline_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_makeline_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_polygonize_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_polygonize_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_union_parallel_combinefn(internal, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_union_parallel_combinefn(internal, internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_union_parallel_deserialfn(bytea, internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_union_parallel_deserialfn(bytea, internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_union_parallel_finalfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_union_parallel_finalfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_union_parallel_serialfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_union_parallel_serialfn(internal) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_union_parallel_transfn(internal, public.geometry) TO mbollam;


--
-- Name: FUNCTION pgis_geometry_union_parallel_transfn(internal, public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgis_geometry_union_parallel_transfn(internal, public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION pgr_alphashape(public.geometry, alpha double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_alphashape(public.geometry, alpha double precision) TO mbollam;


--
-- Name: FUNCTION pgr_analyzegraph(text, double precision, the_geom text, id text, source text, target text, rows_where text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_analyzegraph(text, double precision, the_geom text, id text, source text, target text, rows_where text) TO mbollam;


--
-- Name: FUNCTION pgr_analyzeoneway(text, text[], text[], text[], text[], two_way_if_null boolean, oneway text, source text, target text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_analyzeoneway(text, text[], text[], text[], text[], two_way_if_null boolean, oneway text, source text, target text) TO mbollam;


--
-- Name: FUNCTION pgr_articulationpoints(text, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_articulationpoints(text, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION pgr_astar(text, text, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astar(text, text, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astar(text, anyarray, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astar(text, anyarray, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astar(text, anyarray, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astar(text, anyarray, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astar(text, bigint, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astar(text, bigint, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astar(text, bigint, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astar(text, bigint, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astarcost(text, text, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astarcost(text, text, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astarcost(text, anyarray, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astarcost(text, anyarray, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astarcost(text, anyarray, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astarcost(text, anyarray, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astarcost(text, bigint, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astarcost(text, bigint, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astarcost(text, bigint, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astarcost(text, bigint, bigint, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_astarcostmatrix(text, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_astarcostmatrix(text, anyarray, directed boolean, heuristic integer, factor double precision, epsilon double precision, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastar(text, text, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastar(text, text, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastar(text, anyarray, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastar(text, anyarray, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastar(text, anyarray, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastar(text, anyarray, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastar(text, bigint, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastar(text, bigint, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastar(text, bigint, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastar(text, bigint, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastarcost(text, text, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastarcost(text, text, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastarcost(text, anyarray, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastarcost(text, anyarray, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastarcost(text, anyarray, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastarcost(text, anyarray, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastarcost(text, bigint, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastarcost(text, bigint, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastarcost(text, bigint, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastarcost(text, bigint, bigint, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bdastarcostmatrix(text, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bdastarcostmatrix(text, anyarray, directed boolean, heuristic integer, factor numeric, epsilon numeric, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstra(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstra(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstra(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstra(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstra(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstra(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstra(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstra(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstra(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstra(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstracost(text, text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstracost(text, text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstracost(text, anyarray, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstracost(text, anyarray, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstracost(text, anyarray, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstracost(text, anyarray, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstracost(text, bigint, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstracost(text, bigint, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstracost(text, bigint, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstracost(text, bigint, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bddijkstracostmatrix(text, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bddijkstracostmatrix(text, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bellmanford(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bellmanford(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bellmanford(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bellmanford(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bellmanford(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bellmanford(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bellmanford(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bellmanford(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bellmanford(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bellmanford(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_biconnectedcomponents(text, OUT seq bigint, OUT component bigint, OUT edge bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_biconnectedcomponents(text, OUT seq bigint, OUT component bigint, OUT edge bigint) TO mbollam;


--
-- Name: FUNCTION pgr_binarybreadthfirstsearch(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_binarybreadthfirstsearch(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_binarybreadthfirstsearch(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_binarybreadthfirstsearch(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_binarybreadthfirstsearch(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_binarybreadthfirstsearch(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_binarybreadthfirstsearch(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_binarybreadthfirstsearch(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_binarybreadthfirstsearch(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_binarybreadthfirstsearch(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bipartite(text, OUT vertex_id bigint, OUT color_id bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bipartite(text, OUT vertex_id bigint, OUT color_id bigint) TO mbollam;


--
-- Name: FUNCTION pgr_boykovkolmogorov(text, text, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_boykovkolmogorov(text, text, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_boykovkolmogorov(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_boykovkolmogorov(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_boykovkolmogorov(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_boykovkolmogorov(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_boykovkolmogorov(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_boykovkolmogorov(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_boykovkolmogorov(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_boykovkolmogorov(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_breadthfirstsearch(text, anyarray, max_depth bigint, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_breadthfirstsearch(text, anyarray, max_depth bigint, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_breadthfirstsearch(text, bigint, max_depth bigint, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_breadthfirstsearch(text, bigint, max_depth bigint, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_bridges(text, OUT edge bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_bridges(text, OUT edge bigint) TO mbollam;


--
-- Name: FUNCTION pgr_chinesepostman(text, OUT seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_chinesepostman(text, OUT seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_chinesepostmancost(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_chinesepostmancost(text) TO mbollam;


--
-- Name: FUNCTION pgr_connectedcomponents(text, OUT seq bigint, OUT component bigint, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_connectedcomponents(text, OUT seq bigint, OUT component bigint, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION pgr_contraction(text, bigint[], max_cycles integer, forbidden_vertices bigint[], directed boolean, OUT type text, OUT id bigint, OUT contracted_vertices bigint[], OUT source bigint, OUT target bigint, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_contraction(text, bigint[], max_cycles integer, forbidden_vertices bigint[], directed boolean, OUT type text, OUT id bigint, OUT contracted_vertices bigint[], OUT source bigint, OUT target bigint, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_createtopology(text, double precision, the_geom text, id text, source text, target text, rows_where text, clean boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_createtopology(text, double precision, the_geom text, id text, source text, target text, rows_where text, clean boolean) TO mbollam;


--
-- Name: FUNCTION pgr_createverticestable(text, the_geom text, source text, target text, rows_where text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_createverticestable(text, the_geom text, source text, target text, rows_where text) TO mbollam;


--
-- Name: FUNCTION pgr_cuthillmckeeordering(text, OUT seq bigint, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_cuthillmckeeordering(text, OUT seq bigint, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION pgr_dagshortestpath(text, text, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dagshortestpath(text, text, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dagshortestpath(text, anyarray, anyarray, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dagshortestpath(text, anyarray, anyarray, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dagshortestpath(text, anyarray, bigint, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dagshortestpath(text, anyarray, bigint, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dagshortestpath(text, bigint, anyarray, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dagshortestpath(text, bigint, anyarray, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dagshortestpath(text, bigint, bigint, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dagshortestpath(text, bigint, bigint, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_degree(text, text, dryrun boolean, OUT node bigint, OUT degree bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_degree(text, text, dryrun boolean, OUT node bigint, OUT degree bigint) TO mbollam;


--
-- Name: FUNCTION pgr_depthfirstsearch(text, anyarray, directed boolean, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_depthfirstsearch(text, anyarray, directed boolean, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_depthfirstsearch(text, bigint, directed boolean, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_depthfirstsearch(text, bigint, directed boolean, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstra(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstra(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstra(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstra(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstra(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstra(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstra(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstra(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstra(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstra(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstracost(text, text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstracost(text, text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstracost(text, anyarray, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstracost(text, anyarray, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstracost(text, anyarray, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstracost(text, anyarray, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstracost(text, bigint, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstracost(text, bigint, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstracost(text, bigint, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstracost(text, bigint, bigint, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstracostmatrix(text, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstracostmatrix(text, anyarray, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranear(text, anyarray, bigint, directed boolean, cap bigint, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranear(text, anyarray, bigint, directed boolean, cap bigint, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranear(text, bigint, anyarray, directed boolean, cap bigint, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranear(text, bigint, anyarray, directed boolean, cap bigint, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranear(text, text, directed boolean, cap bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranear(text, text, directed boolean, cap bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranear(text, anyarray, anyarray, directed boolean, cap bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranear(text, anyarray, anyarray, directed boolean, cap bigint, global boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranearcost(text, anyarray, bigint, directed boolean, cap bigint, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranearcost(text, anyarray, bigint, directed boolean, cap bigint, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranearcost(text, bigint, anyarray, directed boolean, cap bigint, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranearcost(text, bigint, anyarray, directed boolean, cap bigint, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranearcost(text, text, directed boolean, cap bigint, global boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranearcost(text, text, directed boolean, cap bigint, global boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstranearcost(text, anyarray, anyarray, directed boolean, cap bigint, global boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstranearcost(text, anyarray, anyarray, directed boolean, cap bigint, global boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_dijkstravia(text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_dijkstravia(text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_drivingdistance(text, bigint, double precision, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_drivingdistance(text, bigint, double precision, directed boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_drivingdistance(text, anyarray, double precision, directed boolean, equicost boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_drivingdistance(text, anyarray, double precision, directed boolean, equicost boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edgecoloring(text, OUT edge_id bigint, OUT color_id bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edgecoloring(text, OUT edge_id bigint, OUT color_id bigint) TO mbollam;


--
-- Name: FUNCTION pgr_edgedisjointpaths(text, text, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edgedisjointpaths(text, text, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edgedisjointpaths(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edgedisjointpaths(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edgedisjointpaths(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edgedisjointpaths(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edgedisjointpaths(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edgedisjointpaths(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edgedisjointpaths(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edgedisjointpaths(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edmondskarp(text, text, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edmondskarp(text, text, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_edmondskarp(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edmondskarp(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_edmondskarp(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edmondskarp(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_edmondskarp(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edmondskarp(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_edmondskarp(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edmondskarp(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_edwardmoore(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edwardmoore(text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edwardmoore(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edwardmoore(text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edwardmoore(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edwardmoore(text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edwardmoore(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edwardmoore(text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_edwardmoore(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_edwardmoore(text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_extractvertices(text, dryrun boolean, OUT id bigint, OUT in_edges bigint[], OUT out_edges bigint[], OUT x double precision, OUT y double precision, OUT geom public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_extractvertices(text, dryrun boolean, OUT id bigint, OUT in_edges bigint[], OUT out_edges bigint[], OUT x double precision, OUT y double precision, OUT geom public.geometry) TO mbollam;


--
-- Name: FUNCTION pgr_findcloseedges(text, public.geometry[], double precision, cap integer, partial boolean, dryrun boolean, OUT edge_id bigint, OUT fraction double precision, OUT side character, OUT distance double precision, OUT geom public.geometry, OUT edge public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_findcloseedges(text, public.geometry[], double precision, cap integer, partial boolean, dryrun boolean, OUT edge_id bigint, OUT fraction double precision, OUT side character, OUT distance double precision, OUT geom public.geometry, OUT edge public.geometry) TO mbollam;


--
-- Name: FUNCTION pgr_findcloseedges(text, public.geometry, double precision, cap integer, partial boolean, dryrun boolean, OUT edge_id bigint, OUT fraction double precision, OUT side character, OUT distance double precision, OUT geom public.geometry, OUT edge public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_findcloseedges(text, public.geometry, double precision, cap integer, partial boolean, dryrun boolean, OUT edge_id bigint, OUT fraction double precision, OUT side character, OUT distance double precision, OUT geom public.geometry, OUT edge public.geometry) TO mbollam;


--
-- Name: FUNCTION pgr_floydwarshall(text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_floydwarshall(text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_full_version(OUT version text, OUT build_type text, OUT compile_date text, OUT library text, OUT system text, OUT postgresql text, OUT compiler text, OUT boost text, OUT hash text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_full_version(OUT version text, OUT build_type text, OUT compile_date text, OUT library text, OUT system text, OUT postgresql text, OUT compiler text, OUT boost text, OUT hash text) TO mbollam;


--
-- Name: FUNCTION pgr_hawickcircuits(text, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_hawickcircuits(text, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_isplanar(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_isplanar(text) TO mbollam;


--
-- Name: FUNCTION pgr_johnson(text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_johnson(text, directed boolean, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskal(text, OUT edge bigint, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskal(text, OUT edge bigint, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskalbfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskalbfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskalbfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskalbfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskaldd(text, anyarray, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskaldd(text, anyarray, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskaldd(text, anyarray, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskaldd(text, anyarray, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskaldd(text, bigint, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskaldd(text, bigint, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskaldd(text, bigint, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskaldd(text, bigint, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskaldfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskaldfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_kruskaldfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_kruskaldfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_ksp(text, text, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_ksp(text, text, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_ksp(text, anyarray, anyarray, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_ksp(text, anyarray, anyarray, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_ksp(text, anyarray, bigint, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_ksp(text, anyarray, bigint, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_ksp(text, bigint, anyarray, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_ksp(text, bigint, anyarray, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_ksp(text, bigint, bigint, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_ksp(text, bigint, bigint, integer, directed boolean, heap_paths boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_lengauertarjandominatortree(text, bigint, OUT seq integer, OUT vertex_id bigint, OUT idom bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_lengauertarjandominatortree(text, bigint, OUT seq integer, OUT vertex_id bigint, OUT idom bigint) TO mbollam;


--
-- Name: FUNCTION pgr_linegraph(text, directed boolean, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT reverse_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_linegraph(text, directed boolean, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT reverse_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_linegraphfull(text, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT edge bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_linegraphfull(text, OUT seq integer, OUT source bigint, OUT target bigint, OUT cost double precision, OUT edge bigint) TO mbollam;


--
-- Name: FUNCTION pgr_makeconnected(text, OUT seq bigint, OUT start_vid bigint, OUT end_vid bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_makeconnected(text, OUT seq bigint, OUT start_vid bigint, OUT end_vid bigint) TO mbollam;


--
-- Name: FUNCTION pgr_maxcardinalitymatch(text, OUT edge bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxcardinalitymatch(text, OUT edge bigint) TO mbollam;


--
-- Name: FUNCTION pgr_maxcardinalitymatch(text, directed boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxcardinalitymatch(text, directed boolean, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint) TO mbollam;


--
-- Name: FUNCTION pgr_maxflow(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflow(text, text) TO mbollam;


--
-- Name: FUNCTION pgr_maxflow(text, anyarray, anyarray); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflow(text, anyarray, anyarray) TO mbollam;


--
-- Name: FUNCTION pgr_maxflow(text, anyarray, bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflow(text, anyarray, bigint) TO mbollam;


--
-- Name: FUNCTION pgr_maxflow(text, bigint, anyarray); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflow(text, bigint, anyarray) TO mbollam;


--
-- Name: FUNCTION pgr_maxflow(text, bigint, bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflow(text, bigint, bigint) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost(text, text, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost(text, text, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT source bigint, OUT target bigint, OUT flow bigint, OUT residual_capacity bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost_cost(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost_cost(text, text) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost_cost(text, anyarray, anyarray); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost_cost(text, anyarray, anyarray) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost_cost(text, anyarray, bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost_cost(text, anyarray, bigint) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost_cost(text, bigint, anyarray); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost_cost(text, bigint, anyarray) TO mbollam;


--
-- Name: FUNCTION pgr_maxflowmincost_cost(text, bigint, bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_maxflowmincost_cost(text, bigint, bigint) TO mbollam;


--
-- Name: FUNCTION pgr_nodenetwork(text, double precision, id text, the_geom text, table_ending text, rows_where text, outall boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_nodenetwork(text, double precision, id text, the_geom text, table_ending text, rows_where text, outall boolean) TO mbollam;


--
-- Name: FUNCTION pgr_pickdeliver(text, text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT stop_id bigint, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_pickdeliver(text, text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT stop_id bigint, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision) TO mbollam;


--
-- Name: FUNCTION pgr_pickdelivereuclidean(text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_pickdelivereuclidean(text, text, factor double precision, max_cycles integer, initial_sol integer, OUT seq integer, OUT vehicle_seq integer, OUT vehicle_id bigint, OUT stop_seq integer, OUT stop_type integer, OUT order_id bigint, OUT cargo double precision, OUT travel_time double precision, OUT arrival_time double precision, OUT wait_time double precision, OUT service_time double precision, OUT departure_time double precision) TO mbollam;


--
-- Name: FUNCTION pgr_prim(text, OUT edge bigint, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_prim(text, OUT edge bigint, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primbfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primbfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primbfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primbfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primdd(text, anyarray, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primdd(text, anyarray, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primdd(text, anyarray, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primdd(text, anyarray, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primdd(text, bigint, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primdd(text, bigint, double precision, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primdd(text, bigint, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primdd(text, bigint, numeric, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primdfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primdfs(text, anyarray, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_primdfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_primdfs(text, bigint, max_depth bigint, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_pushrelabel(text, text, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_pushrelabel(text, text, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_pushrelabel(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_pushrelabel(text, anyarray, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_pushrelabel(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_pushrelabel(text, anyarray, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_pushrelabel(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_pushrelabel(text, bigint, anyarray, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_pushrelabel(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_pushrelabel(text, bigint, bigint, OUT seq integer, OUT edge bigint, OUT start_vid bigint, OUT end_vid bigint, OUT flow bigint, OUT residual_capacity bigint) TO mbollam;


--
-- Name: FUNCTION pgr_sequentialvertexcoloring(text, OUT vertex_id bigint, OUT color_id bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_sequentialvertexcoloring(text, OUT vertex_id bigint, OUT color_id bigint) TO mbollam;


--
-- Name: FUNCTION pgr_stoerwagner(text, OUT seq integer, OUT edge bigint, OUT cost double precision, OUT mincut double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_stoerwagner(text, OUT seq integer, OUT edge bigint, OUT cost double precision, OUT mincut double precision) TO mbollam;


--
-- Name: FUNCTION pgr_strongcomponents(text, OUT seq bigint, OUT component bigint, OUT node bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_strongcomponents(text, OUT seq bigint, OUT component bigint, OUT node bigint) TO mbollam;


--
-- Name: FUNCTION pgr_topologicalsort(text, OUT seq integer, OUT sorted_v bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_topologicalsort(text, OUT seq integer, OUT sorted_v bigint) TO mbollam;


--
-- Name: FUNCTION pgr_transitiveclosure(text, OUT seq integer, OUT vid bigint, OUT target_array bigint[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_transitiveclosure(text, OUT seq integer, OUT vid bigint, OUT target_array bigint[]) TO mbollam;


--
-- Name: FUNCTION pgr_trsp(text, text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp(text, text, text, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp(text, text, anyarray, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp(text, text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp(text, text, anyarray, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp(text, text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp(text, text, bigint, anyarray, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp(text, text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp(text, text, bigint, bigint, directed boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp(text, integer, integer, boolean, boolean, restrictions_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp(text, integer, integer, boolean, boolean, restrictions_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp(text, integer, double precision, integer, double precision, boolean, boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp(text, integer, double precision, integer, double precision, boolean, boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp_withpoints(text, text, text, text, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp_withpoints(text, text, text, text, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp_withpoints(text, text, text, anyarray, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp_withpoints(text, text, text, anyarray, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp_withpoints(text, text, text, anyarray, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp_withpoints(text, text, text, anyarray, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp_withpoints(text, text, text, bigint, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp_withpoints(text, text, text, bigint, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trsp_withpoints(text, text, text, bigint, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trsp_withpoints(text, text, text, bigint, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trspvia(text, text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trspvia(text, text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trspvia_withpoints(text, text, text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trspvia_withpoints(text, text, text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trspviaedges(text, integer[], double precision[], boolean, boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT id3 integer, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trspviaedges(text, integer[], double precision[], boolean, boolean, turn_restrict_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT id3 integer, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_trspviavertices(text, anyarray, boolean, boolean, restrictions_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT id3 integer, OUT cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_trspviavertices(text, anyarray, boolean, boolean, restrictions_sql text, OUT seq integer, OUT id1 integer, OUT id2 integer, OUT id3 integer, OUT cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_tsp(text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_tsp(text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_tspeuclidean(text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_tspeuclidean(text, start_id bigint, end_id bigint, max_processing_time double precision, tries_per_temperature integer, max_changes_per_temperature integer, max_consecutive_non_changes integer, initial_temperature double precision, final_temperature double precision, cooling_factor double precision, randomize boolean, OUT seq integer, OUT node bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_turnrestrictedpath(text, text, bigint, bigint, integer, directed boolean, heap_paths boolean, stop_on_first boolean, strict boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_turnrestrictedpath(text, text, bigint, bigint, integer, directed boolean, heap_paths boolean, stop_on_first boolean, strict boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_version() TO mbollam;


--
-- Name: FUNCTION pgr_vrponedepot(text, text, text, integer, OUT oid integer, OUT opos integer, OUT vid integer, OUT tarrival integer, OUT tdepart integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_vrponedepot(text, text, text, integer, OUT oid integer, OUT opos integer, OUT vid integer, OUT tarrival integer, OUT tdepart integer) TO mbollam;


--
-- Name: FUNCTION pgr_withpoints(text, text, text, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpoints(text, text, text, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpoints(text, text, anyarray, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpoints(text, text, anyarray, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpoints(text, text, anyarray, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpoints(text, text, anyarray, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT start_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpoints(text, text, bigint, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpoints(text, text, bigint, anyarray, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT end_pid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpoints(text, text, bigint, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpoints(text, text, bigint, bigint, directed boolean, driving_side character, details boolean, OUT seq integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointscost(text, text, text, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointscost(text, text, text, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointscost(text, text, anyarray, anyarray, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointscost(text, text, anyarray, anyarray, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointscost(text, text, anyarray, bigint, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointscost(text, text, anyarray, bigint, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointscost(text, text, bigint, anyarray, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointscost(text, text, bigint, anyarray, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointscost(text, text, bigint, bigint, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointscost(text, text, bigint, bigint, directed boolean, driving_side character, OUT start_pid bigint, OUT end_pid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointscostmatrix(text, text, anyarray, directed boolean, driving_side character, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointscostmatrix(text, text, anyarray, directed boolean, driving_side character, OUT start_vid bigint, OUT end_vid bigint, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsdd(text, text, bigint, double precision, directed boolean, driving_side character, details boolean, OUT seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsdd(text, text, bigint, double precision, directed boolean, driving_side character, details boolean, OUT seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsdd(text, text, bigint, double precision, character, directed boolean, details boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsdd(text, text, bigint, double precision, character, directed boolean, details boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsdd(text, text, anyarray, double precision, directed boolean, driving_side character, details boolean, equicost boolean, OUT seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsdd(text, text, anyarray, double precision, directed boolean, driving_side character, details boolean, equicost boolean, OUT seq integer, OUT start_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsdd(text, text, anyarray, double precision, character, directed boolean, details boolean, equicost boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsdd(text, text, anyarray, double precision, character, directed boolean, details boolean, equicost boolean, OUT seq bigint, OUT depth bigint, OUT start_vid bigint, OUT pred bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsksp(text, text, text, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsksp(text, text, text, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsksp(text, text, anyarray, anyarray, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsksp(text, text, anyarray, anyarray, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsksp(text, text, anyarray, bigint, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsksp(text, text, anyarray, bigint, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsksp(text, text, bigint, anyarray, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsksp(text, text, bigint, anyarray, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsksp(text, text, bigint, bigint, integer, directed boolean, heap_paths boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsksp(text, text, bigint, bigint, integer, directed boolean, heap_paths boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsksp(text, text, bigint, bigint, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsksp(text, text, bigint, bigint, integer, character, directed boolean, heap_paths boolean, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION pgr_withpointsvia(text, text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.pgr_withpointsvia(text, text, anyarray, directed boolean, strict boolean, u_turn_on_edge boolean, driving_side character, details boolean, OUT seq integer, OUT path_id integer, OUT path_seq integer, OUT start_vid bigint, OUT end_vid bigint, OUT node bigint, OUT edge bigint, OUT cost double precision, OUT agg_cost double precision, OUT route_agg_cost double precision) TO mbollam;


--
-- Name: FUNCTION populate_geometry_columns(use_typmod boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.populate_geometry_columns(use_typmod boolean) TO mbollam;


--
-- Name: FUNCTION populate_geometry_columns(tbl_oid oid, use_typmod boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.populate_geometry_columns(tbl_oid oid, use_typmod boolean) TO mbollam;


--
-- Name: FUNCTION postgis_addbbox(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_addbbox(public.geometry) TO mbollam;


--
-- Name: FUNCTION postgis_cache_bbox(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_cache_bbox() TO mbollam;


--
-- Name: FUNCTION postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_constraint_dims(geomschema text, geomtable text, geomcolumn text) TO mbollam;


--
-- Name: FUNCTION postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_constraint_srid(geomschema text, geomtable text, geomcolumn text) TO mbollam;


--
-- Name: FUNCTION postgis_constraint_type(geomschema text, geomtable text, geomcolumn text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_constraint_type(geomschema text, geomtable text, geomcolumn text) TO mbollam;


--
-- Name: FUNCTION postgis_dropbbox(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_dropbbox(public.geometry) TO mbollam;


--
-- Name: FUNCTION postgis_extensions_upgrade(target_version text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_extensions_upgrade(target_version text) TO mbollam;


--
-- Name: FUNCTION postgis_full_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_full_version() TO mbollam;


--
-- Name: FUNCTION postgis_geos_compiled_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_geos_compiled_version() TO mbollam;


--
-- Name: FUNCTION postgis_geos_noop(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_geos_noop(public.geometry) TO mbollam;


--
-- Name: FUNCTION postgis_geos_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_geos_version() TO mbollam;


--
-- Name: FUNCTION postgis_getbbox(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_getbbox(public.geometry) TO mbollam;


--
-- Name: FUNCTION postgis_hasbbox(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_hasbbox(public.geometry) TO mbollam;


--
-- Name: FUNCTION postgis_index_supportfn(internal); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_index_supportfn(internal) TO mbollam;


--
-- Name: FUNCTION postgis_lib_build_date(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_lib_build_date() TO mbollam;


--
-- Name: FUNCTION postgis_lib_revision(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_lib_revision() TO mbollam;


--
-- Name: FUNCTION postgis_lib_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_lib_version() TO mbollam;


--
-- Name: FUNCTION postgis_libjson_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_libjson_version() TO mbollam;


--
-- Name: FUNCTION postgis_liblwgeom_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_liblwgeom_version() TO mbollam;


--
-- Name: FUNCTION postgis_libprotobuf_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_libprotobuf_version() TO mbollam;


--
-- Name: FUNCTION postgis_libxml_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_libxml_version() TO mbollam;


--
-- Name: FUNCTION postgis_noop(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_noop(public.geometry) TO mbollam;


--
-- Name: FUNCTION postgis_proj_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_proj_version() TO mbollam;


--
-- Name: FUNCTION postgis_scripts_build_date(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_scripts_build_date() TO mbollam;


--
-- Name: FUNCTION postgis_scripts_installed(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_scripts_installed() TO mbollam;


--
-- Name: FUNCTION postgis_scripts_released(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_scripts_released() TO mbollam;


--
-- Name: FUNCTION postgis_srs(auth_name text, auth_srid text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_srs(auth_name text, auth_srid text) TO mbollam;


--
-- Name: FUNCTION postgis_srs_all(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_srs_all() TO mbollam;


--
-- Name: FUNCTION postgis_srs_codes(auth_name text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_srs_codes(auth_name text) TO mbollam;


--
-- Name: FUNCTION postgis_srs_search(bounds public.geometry, authname text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_srs_search(bounds public.geometry, authname text) TO mbollam;


--
-- Name: FUNCTION postgis_svn_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_svn_version() TO mbollam;


--
-- Name: FUNCTION postgis_transform_geometry(geom public.geometry, text, text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_transform_geometry(geom public.geometry, text, text, integer) TO mbollam;


--
-- Name: FUNCTION postgis_transform_pipeline_geometry(geom public.geometry, pipeline text, forward boolean, to_srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_transform_pipeline_geometry(geom public.geometry, pipeline text, forward boolean, to_srid integer) TO mbollam;


--
-- Name: FUNCTION postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_type_name(geomname character varying, coord_dimension integer, use_new_name boolean) TO mbollam;


--
-- Name: FUNCTION postgis_typmod_dims(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_typmod_dims(integer) TO mbollam;


--
-- Name: FUNCTION postgis_typmod_srid(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_typmod_srid(integer) TO mbollam;


--
-- Name: FUNCTION postgis_typmod_type(integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_typmod_type(integer) TO mbollam;


--
-- Name: FUNCTION postgis_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_version() TO mbollam;


--
-- Name: FUNCTION postgis_wagyu_version(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.postgis_wagyu_version() TO mbollam;


--
-- Name: FUNCTION st_3dclosestpoint(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dclosestpoint(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3ddfullywithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3ddfullywithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_3ddistance(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3ddistance(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3ddwithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3ddwithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_3dintersects(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dintersects(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3dlength(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dlength(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3dlineinterpolatepoint(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dlineinterpolatepoint(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_3dlongestline(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dlongestline(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3dmakebox(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dmakebox(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3dmaxdistance(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dmaxdistance(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3dperimeter(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dperimeter(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_3dshortestline(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dshortestline(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_addmeasure(public.geometry, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_addmeasure(public.geometry, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_addpoint(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_addpoint(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_addpoint(geom1 public.geometry, geom2 public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_addpoint(geom1 public.geometry, geom2 public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_affine(public.geometry, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_affine(public.geometry, double precision, double precision, double precision, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_affine(public.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_affine(public.geometry, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_angle(line1 public.geometry, line2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_angle(line1 public.geometry, line2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_angle(pt1 public.geometry, pt2 public.geometry, pt3 public.geometry, pt4 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_angle(pt1 public.geometry, pt2 public.geometry, pt3 public.geometry, pt4 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_area(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_area(text) TO mbollam;


--
-- Name: FUNCTION st_area(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_area(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_area(geog public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_area(geog public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_area2d(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_area2d(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_asbinary(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asbinary(public.geography) TO mbollam;


--
-- Name: FUNCTION st_asbinary(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asbinary(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_asbinary(public.geography, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asbinary(public.geography, text) TO mbollam;


--
-- Name: FUNCTION st_asbinary(public.geometry, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asbinary(public.geometry, text) TO mbollam;


--
-- Name: FUNCTION st_asencodedpolyline(geom public.geometry, nprecision integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asencodedpolyline(geom public.geometry, nprecision integer) TO mbollam;


--
-- Name: FUNCTION st_asewkb(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asewkb(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_asewkb(public.geometry, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asewkb(public.geometry, text) TO mbollam;


--
-- Name: FUNCTION st_asewkt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asewkt(text) TO mbollam;


--
-- Name: FUNCTION st_asewkt(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asewkt(public.geography) TO mbollam;


--
-- Name: FUNCTION st_asewkt(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asewkt(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_asewkt(public.geography, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asewkt(public.geography, integer) TO mbollam;


--
-- Name: FUNCTION st_asewkt(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asewkt(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_asgeojson(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgeojson(text) TO mbollam;


--
-- Name: FUNCTION st_asgeojson(geog public.geography, maxdecimaldigits integer, options integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgeojson(geog public.geography, maxdecimaldigits integer, options integer) TO mbollam;


--
-- Name: FUNCTION st_asgeojson(geom public.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgeojson(geom public.geometry, maxdecimaldigits integer, options integer) TO mbollam;


--
-- Name: FUNCTION st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgeojson(r record, geom_column text, maxdecimaldigits integer, pretty_bool boolean) TO mbollam;


--
-- Name: FUNCTION st_asgml(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgml(text) TO mbollam;


--
-- Name: FUNCTION st_asgml(geom public.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgml(geom public.geometry, maxdecimaldigits integer, options integer) TO mbollam;


--
-- Name: FUNCTION st_asgml(geog public.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgml(geog public.geography, maxdecimaldigits integer, options integer, nprefix text, id text) TO mbollam;


--
-- Name: FUNCTION st_asgml(version integer, geog public.geography, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgml(version integer, geog public.geography, maxdecimaldigits integer, options integer, nprefix text, id text) TO mbollam;


--
-- Name: FUNCTION st_asgml(version integer, geom public.geometry, maxdecimaldigits integer, options integer, nprefix text, id text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgml(version integer, geom public.geometry, maxdecimaldigits integer, options integer, nprefix text, id text) TO mbollam;


--
-- Name: FUNCTION st_ashexewkb(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_ashexewkb(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_ashexewkb(public.geometry, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_ashexewkb(public.geometry, text) TO mbollam;


--
-- Name: FUNCTION st_askml(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_askml(text) TO mbollam;


--
-- Name: FUNCTION st_askml(geog public.geography, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_askml(geog public.geography, maxdecimaldigits integer, nprefix text) TO mbollam;


--
-- Name: FUNCTION st_askml(geom public.geometry, maxdecimaldigits integer, nprefix text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_askml(geom public.geometry, maxdecimaldigits integer, nprefix text) TO mbollam;


--
-- Name: FUNCTION st_aslatlontext(geom public.geometry, tmpl text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_aslatlontext(geom public.geometry, tmpl text) TO mbollam;


--
-- Name: FUNCTION st_asmarc21(geom public.geometry, format text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asmarc21(geom public.geometry, format text) TO mbollam;


--
-- Name: FUNCTION st_asmvtgeom(geom public.geometry, bounds public.box2d, extent integer, buffer integer, clip_geom boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asmvtgeom(geom public.geometry, bounds public.box2d, extent integer, buffer integer, clip_geom boolean) TO mbollam;


--
-- Name: FUNCTION st_assvg(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_assvg(text) TO mbollam;


--
-- Name: FUNCTION st_assvg(geog public.geography, rel integer, maxdecimaldigits integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_assvg(geog public.geography, rel integer, maxdecimaldigits integer) TO mbollam;


--
-- Name: FUNCTION st_assvg(geom public.geometry, rel integer, maxdecimaldigits integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_assvg(geom public.geometry, rel integer, maxdecimaldigits integer) TO mbollam;


--
-- Name: FUNCTION st_astext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_astext(text) TO mbollam;


--
-- Name: FUNCTION st_astext(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_astext(public.geography) TO mbollam;


--
-- Name: FUNCTION st_astext(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_astext(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_astext(public.geography, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_astext(public.geography, integer) TO mbollam;


--
-- Name: FUNCTION st_astext(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_astext(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_astwkb(geom public.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_astwkb(geom public.geometry, prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) TO mbollam;


--
-- Name: FUNCTION st_astwkb(geom public.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_astwkb(geom public.geometry[], ids bigint[], prec integer, prec_z integer, prec_m integer, with_sizes boolean, with_boxes boolean) TO mbollam;


--
-- Name: FUNCTION st_asx3d(geom public.geometry, maxdecimaldigits integer, options integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asx3d(geom public.geometry, maxdecimaldigits integer, options integer) TO mbollam;


--
-- Name: FUNCTION st_azimuth(geog1 public.geography, geog2 public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_azimuth(geog1 public.geography, geog2 public.geography) TO mbollam;


--
-- Name: FUNCTION st_azimuth(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_azimuth(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_bdmpolyfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_bdmpolyfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_bdpolyfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_bdpolyfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_boundary(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_boundary(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_boundingdiagonal(geom public.geometry, fits boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_boundingdiagonal(geom public.geometry, fits boolean) TO mbollam;


--
-- Name: FUNCTION st_box2dfromgeohash(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_box2dfromgeohash(text, integer) TO mbollam;


--
-- Name: FUNCTION st_buffer(text, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(text, double precision) TO mbollam;


--
-- Name: FUNCTION st_buffer(public.geography, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(public.geography, double precision) TO mbollam;


--
-- Name: FUNCTION st_buffer(text, double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(text, double precision, integer) TO mbollam;


--
-- Name: FUNCTION st_buffer(text, double precision, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(text, double precision, text) TO mbollam;


--
-- Name: FUNCTION st_buffer(public.geography, double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(public.geography, double precision, integer) TO mbollam;


--
-- Name: FUNCTION st_buffer(public.geography, double precision, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(public.geography, double precision, text) TO mbollam;


--
-- Name: FUNCTION st_buffer(geom public.geometry, radius double precision, quadsegs integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(geom public.geometry, radius double precision, quadsegs integer) TO mbollam;


--
-- Name: FUNCTION st_buffer(geom public.geometry, radius double precision, options text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buffer(geom public.geometry, radius double precision, options text) TO mbollam;


--
-- Name: FUNCTION st_buildarea(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_buildarea(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_centroid(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_centroid(text) TO mbollam;


--
-- Name: FUNCTION st_centroid(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_centroid(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_centroid(public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_centroid(public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_chaikinsmoothing(public.geometry, integer, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_chaikinsmoothing(public.geometry, integer, boolean) TO mbollam;


--
-- Name: FUNCTION st_cleangeometry(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_cleangeometry(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_clipbybox2d(geom public.geometry, box public.box2d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clipbybox2d(geom public.geometry, box public.box2d) TO mbollam;


--
-- Name: FUNCTION st_closestpoint(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_closestpoint(text, text) TO mbollam;


--
-- Name: FUNCTION st_closestpoint(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_closestpoint(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_closestpoint(public.geography, public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_closestpoint(public.geography, public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_closestpointofapproach(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_closestpointofapproach(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_clusterdbscan(public.geometry, eps double precision, minpoints integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterdbscan(public.geometry, eps double precision, minpoints integer) TO mbollam;


--
-- Name: FUNCTION st_clusterintersecting(public.geometry[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterintersecting(public.geometry[]) TO mbollam;


--
-- Name: FUNCTION st_clusterintersectingwin(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterintersectingwin(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_clusterkmeans(geom public.geometry, k integer, max_radius double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterkmeans(geom public.geometry, k integer, max_radius double precision) TO mbollam;


--
-- Name: FUNCTION st_clusterwithin(public.geometry[], double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterwithin(public.geometry[], double precision) TO mbollam;


--
-- Name: FUNCTION st_clusterwithinwin(public.geometry, distance double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterwithinwin(public.geometry, distance double precision) TO mbollam;


--
-- Name: FUNCTION st_collect(public.geometry[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_collect(public.geometry[]) TO mbollam;


--
-- Name: FUNCTION st_collect(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_collect(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_collectionextract(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_collectionextract(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_collectionextract(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_collectionextract(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_collectionhomogenize(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_collectionhomogenize(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_combinebbox(public.box2d, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_combinebbox(public.box2d, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_combinebbox(public.box3d, public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_combinebbox(public.box3d, public.box3d) TO mbollam;


--
-- Name: FUNCTION st_combinebbox(public.box3d, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_combinebbox(public.box3d, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_concavehull(param_geom public.geometry, param_pctconvex double precision, param_allow_holes boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_concavehull(param_geom public.geometry, param_pctconvex double precision, param_allow_holes boolean) TO mbollam;


--
-- Name: FUNCTION st_contains(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_contains(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_containsproperly(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_containsproperly(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_convexhull(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_convexhull(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_coorddim(geometry public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coorddim(geometry public.geometry) TO mbollam;


--
-- Name: FUNCTION st_coverageinvalidedges(geom public.geometry, tolerance double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coverageinvalidedges(geom public.geometry, tolerance double precision) TO mbollam;


--
-- Name: FUNCTION st_coveragesimplify(geom public.geometry, tolerance double precision, simplifyboundary boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coveragesimplify(geom public.geometry, tolerance double precision, simplifyboundary boolean) TO mbollam;


--
-- Name: FUNCTION st_coverageunion(public.geometry[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coverageunion(public.geometry[]) TO mbollam;


--
-- Name: FUNCTION st_coveredby(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coveredby(text, text) TO mbollam;


--
-- Name: FUNCTION st_coveredby(geog1 public.geography, geog2 public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coveredby(geog1 public.geography, geog2 public.geography) TO mbollam;


--
-- Name: FUNCTION st_coveredby(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coveredby(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_covers(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_covers(text, text) TO mbollam;


--
-- Name: FUNCTION st_covers(geog1 public.geography, geog2 public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_covers(geog1 public.geography, geog2 public.geography) TO mbollam;


--
-- Name: FUNCTION st_covers(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_covers(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_cpawithin(public.geometry, public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_cpawithin(public.geometry, public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_crosses(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_crosses(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_curvetoline(geom public.geometry, tol double precision, toltype integer, flags integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_curvetoline(geom public.geometry, tol double precision, toltype integer, flags integer) TO mbollam;


--
-- Name: FUNCTION st_delaunaytriangles(g1 public.geometry, tolerance double precision, flags integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_delaunaytriangles(g1 public.geometry, tolerance double precision, flags integer) TO mbollam;


--
-- Name: FUNCTION st_dfullywithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dfullywithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_difference(geom1 public.geometry, geom2 public.geometry, gridsize double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_difference(geom1 public.geometry, geom2 public.geometry, gridsize double precision) TO mbollam;


--
-- Name: FUNCTION st_dimension(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dimension(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_disjoint(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_disjoint(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_distance(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distance(text, text) TO mbollam;


--
-- Name: FUNCTION st_distance(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distance(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_distance(geog1 public.geography, geog2 public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distance(geog1 public.geography, geog2 public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_distancecpa(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distancecpa(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_distancesphere(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distancesphere(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_distancesphere(geom1 public.geometry, geom2 public.geometry, radius double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distancesphere(geom1 public.geometry, geom2 public.geometry, radius double precision) TO mbollam;


--
-- Name: FUNCTION st_distancespheroid(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distancespheroid(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_distancespheroid(geom1 public.geometry, geom2 public.geometry, public.spheroid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_distancespheroid(geom1 public.geometry, geom2 public.geometry, public.spheroid) TO mbollam;


--
-- Name: FUNCTION st_dump(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dump(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_dumppoints(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dumppoints(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_dumprings(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dumprings(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_dumpsegments(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dumpsegments(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_dwithin(text, text, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dwithin(text, text, double precision) TO mbollam;


--
-- Name: FUNCTION st_dwithin(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dwithin(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_dwithin(geog1 public.geography, geog2 public.geography, tolerance double precision, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_dwithin(geog1 public.geography, geog2 public.geography, tolerance double precision, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_endpoint(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_endpoint(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_envelope(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_envelope(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_equals(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_equals(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_estimatedextent(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_estimatedextent(text, text) TO mbollam;


--
-- Name: FUNCTION st_estimatedextent(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_estimatedextent(text, text, text) TO mbollam;


--
-- Name: FUNCTION st_estimatedextent(text, text, text, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_estimatedextent(text, text, text, boolean) TO mbollam;


--
-- Name: FUNCTION st_expand(public.box2d, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_expand(public.box2d, double precision) TO mbollam;


--
-- Name: FUNCTION st_expand(public.box3d, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_expand(public.box3d, double precision) TO mbollam;


--
-- Name: FUNCTION st_expand(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_expand(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_expand(box public.box2d, dx double precision, dy double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_expand(box public.box2d, dx double precision, dy double precision) TO mbollam;


--
-- Name: FUNCTION st_expand(box public.box3d, dx double precision, dy double precision, dz double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_expand(box public.box3d, dx double precision, dy double precision, dz double precision) TO mbollam;


--
-- Name: FUNCTION st_expand(geom public.geometry, dx double precision, dy double precision, dz double precision, dm double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_expand(geom public.geometry, dx double precision, dy double precision, dz double precision, dm double precision) TO mbollam;


--
-- Name: FUNCTION st_exteriorring(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_exteriorring(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_filterbym(public.geometry, double precision, double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_filterbym(public.geometry, double precision, double precision, boolean) TO mbollam;


--
-- Name: FUNCTION st_findextent(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_findextent(text, text) TO mbollam;


--
-- Name: FUNCTION st_findextent(text, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_findextent(text, text, text) TO mbollam;


--
-- Name: FUNCTION st_flipcoordinates(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_flipcoordinates(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_force2d(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_force2d(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_force3d(geom public.geometry, zvalue double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_force3d(geom public.geometry, zvalue double precision) TO mbollam;


--
-- Name: FUNCTION st_force3dm(geom public.geometry, mvalue double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_force3dm(geom public.geometry, mvalue double precision) TO mbollam;


--
-- Name: FUNCTION st_force3dz(geom public.geometry, zvalue double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_force3dz(geom public.geometry, zvalue double precision) TO mbollam;


--
-- Name: FUNCTION st_force4d(geom public.geometry, zvalue double precision, mvalue double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_force4d(geom public.geometry, zvalue double precision, mvalue double precision) TO mbollam;


--
-- Name: FUNCTION st_forcecollection(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_forcecollection(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_forcecurve(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_forcecurve(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_forcepolygonccw(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_forcepolygonccw(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_forcepolygoncw(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_forcepolygoncw(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_forcerhr(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_forcerhr(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_forcesfs(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_forcesfs(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_forcesfs(public.geometry, version text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_forcesfs(public.geometry, version text) TO mbollam;


--
-- Name: FUNCTION st_frechetdistance(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_frechetdistance(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_fromflatgeobuf(anyelement, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_fromflatgeobuf(anyelement, bytea) TO mbollam;


--
-- Name: FUNCTION st_fromflatgeobuftotable(text, text, bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_fromflatgeobuftotable(text, text, bytea) TO mbollam;


--
-- Name: FUNCTION st_generatepoints(area public.geometry, npoints integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_generatepoints(area public.geometry, npoints integer) TO mbollam;


--
-- Name: FUNCTION st_generatepoints(area public.geometry, npoints integer, seed integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_generatepoints(area public.geometry, npoints integer, seed integer) TO mbollam;


--
-- Name: FUNCTION st_geogfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geogfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_geogfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geogfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_geographyfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geographyfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_geohash(geog public.geography, maxchars integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geohash(geog public.geography, maxchars integer) TO mbollam;


--
-- Name: FUNCTION st_geohash(geom public.geometry, maxchars integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geohash(geom public.geometry, maxchars integer) TO mbollam;


--
-- Name: FUNCTION st_geomcollfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomcollfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_geomcollfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomcollfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_geomcollfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomcollfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_geomcollfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomcollfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_geometricmedian(g public.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geometricmedian(g public.geometry, tolerance double precision, max_iter integer, fail_if_not_converged boolean) TO mbollam;


--
-- Name: FUNCTION st_geometryfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geometryfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_geometryfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geometryfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_geometryn(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geometryn(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_geometrytype(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geometrytype(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_geomfromewkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromewkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_geomfromewkt(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromewkt(text) TO mbollam;


--
-- Name: FUNCTION st_geomfromgeohash(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromgeohash(text, integer) TO mbollam;


--
-- Name: FUNCTION st_geomfromgeojson(json); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromgeojson(json) TO mbollam;


--
-- Name: FUNCTION st_geomfromgeojson(jsonb); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromgeojson(jsonb) TO mbollam;


--
-- Name: FUNCTION st_geomfromgeojson(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromgeojson(text) TO mbollam;


--
-- Name: FUNCTION st_geomfromgml(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromgml(text) TO mbollam;


--
-- Name: FUNCTION st_geomfromgml(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromgml(text, integer) TO mbollam;


--
-- Name: FUNCTION st_geomfromkml(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromkml(text) TO mbollam;


--
-- Name: FUNCTION st_geomfrommarc21(marc21xml text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfrommarc21(marc21xml text) TO mbollam;


--
-- Name: FUNCTION st_geomfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_geomfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_geomfromtwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromtwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_geomfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_geomfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_geomfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_gmltosql(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_gmltosql(text) TO mbollam;


--
-- Name: FUNCTION st_gmltosql(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_gmltosql(text, integer) TO mbollam;


--
-- Name: FUNCTION st_hasarc(geometry public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_hasarc(geometry public.geometry) TO mbollam;


--
-- Name: FUNCTION st_hausdorffdistance(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_hausdorffdistance(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_hausdorffdistance(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_hausdorffdistance(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_hexagon(size double precision, cell_i integer, cell_j integer, origin public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_hexagon(size double precision, cell_i integer, cell_j integer, origin public.geometry) TO mbollam;


--
-- Name: FUNCTION st_hexagongrid(size double precision, bounds public.geometry, OUT geom public.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_hexagongrid(size double precision, bounds public.geometry, OUT geom public.geometry, OUT i integer, OUT j integer) TO mbollam;


--
-- Name: FUNCTION st_interiorringn(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_interiorringn(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_interpolatepoint(line public.geometry, point public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_interpolatepoint(line public.geometry, point public.geometry) TO mbollam;


--
-- Name: FUNCTION st_intersection(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_intersection(text, text) TO mbollam;


--
-- Name: FUNCTION st_intersection(public.geography, public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_intersection(public.geography, public.geography) TO mbollam;


--
-- Name: FUNCTION st_intersection(geom1 public.geometry, geom2 public.geometry, gridsize double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_intersection(geom1 public.geometry, geom2 public.geometry, gridsize double precision) TO mbollam;


--
-- Name: FUNCTION st_intersects(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_intersects(text, text) TO mbollam;


--
-- Name: FUNCTION st_intersects(geog1 public.geography, geog2 public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_intersects(geog1 public.geography, geog2 public.geography) TO mbollam;


--
-- Name: FUNCTION st_intersects(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_intersects(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_inversetransformpipeline(geom public.geometry, pipeline text, to_srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_inversetransformpipeline(geom public.geometry, pipeline text, to_srid integer) TO mbollam;


--
-- Name: FUNCTION st_isclosed(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isclosed(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_iscollection(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_iscollection(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_isempty(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isempty(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_ispolygonccw(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_ispolygonccw(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_ispolygoncw(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_ispolygoncw(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_isring(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isring(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_issimple(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_issimple(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_isvalid(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isvalid(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_isvalid(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isvalid(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_isvaliddetail(geom public.geometry, flags integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isvaliddetail(geom public.geometry, flags integer) TO mbollam;


--
-- Name: FUNCTION st_isvalidreason(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isvalidreason(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_isvalidreason(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isvalidreason(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_isvalidtrajectory(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_isvalidtrajectory(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_largestemptycircle(geom public.geometry, tolerance double precision, boundary public.geometry, OUT center public.geometry, OUT nearest public.geometry, OUT radius double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_largestemptycircle(geom public.geometry, tolerance double precision, boundary public.geometry, OUT center public.geometry, OUT nearest public.geometry, OUT radius double precision) TO mbollam;


--
-- Name: FUNCTION st_length(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_length(text) TO mbollam;


--
-- Name: FUNCTION st_length(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_length(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_length(geog public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_length(geog public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_length2d(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_length2d(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_length2dspheroid(public.geometry, public.spheroid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_length2dspheroid(public.geometry, public.spheroid) TO mbollam;


--
-- Name: FUNCTION st_lengthspheroid(public.geometry, public.spheroid); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lengthspheroid(public.geometry, public.spheroid) TO mbollam;


--
-- Name: FUNCTION st_letters(letters text, font json); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_letters(letters text, font json) TO mbollam;


--
-- Name: FUNCTION st_linecrossingdirection(line1 public.geometry, line2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linecrossingdirection(line1 public.geometry, line2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_lineextend(geom public.geometry, distance_forward double precision, distance_backward double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lineextend(geom public.geometry, distance_forward double precision, distance_backward double precision) TO mbollam;


--
-- Name: FUNCTION st_linefromencodedpolyline(txtin text, nprecision integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linefromencodedpolyline(txtin text, nprecision integer) TO mbollam;


--
-- Name: FUNCTION st_linefrommultipoint(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linefrommultipoint(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_linefromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linefromtext(text) TO mbollam;


--
-- Name: FUNCTION st_linefromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linefromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_linefromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linefromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_linefromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linefromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_lineinterpolatepoint(text, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lineinterpolatepoint(text, double precision) TO mbollam;


--
-- Name: FUNCTION st_lineinterpolatepoint(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lineinterpolatepoint(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_lineinterpolatepoint(public.geography, double precision, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lineinterpolatepoint(public.geography, double precision, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_lineinterpolatepoints(text, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lineinterpolatepoints(text, double precision) TO mbollam;


--
-- Name: FUNCTION st_lineinterpolatepoints(public.geometry, double precision, repeat boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lineinterpolatepoints(public.geometry, double precision, repeat boolean) TO mbollam;


--
-- Name: FUNCTION st_lineinterpolatepoints(public.geography, double precision, use_spheroid boolean, repeat boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_lineinterpolatepoints(public.geography, double precision, use_spheroid boolean, repeat boolean) TO mbollam;


--
-- Name: FUNCTION st_linelocatepoint(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linelocatepoint(text, text) TO mbollam;


--
-- Name: FUNCTION st_linelocatepoint(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linelocatepoint(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_linelocatepoint(public.geography, public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linelocatepoint(public.geography, public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_linemerge(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linemerge(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_linemerge(public.geometry, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linemerge(public.geometry, boolean) TO mbollam;


--
-- Name: FUNCTION st_linestringfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linestringfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_linestringfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linestringfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_linesubstring(text, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linesubstring(text, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_linesubstring(public.geography, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linesubstring(public.geography, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_linesubstring(public.geometry, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linesubstring(public.geometry, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_linetocurve(geometry public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_linetocurve(geometry public.geometry) TO mbollam;


--
-- Name: FUNCTION st_locatealong(geometry public.geometry, measure double precision, leftrightoffset double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_locatealong(geometry public.geometry, measure double precision, leftrightoffset double precision) TO mbollam;


--
-- Name: FUNCTION st_locatebetween(geometry public.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_locatebetween(geometry public.geometry, frommeasure double precision, tomeasure double precision, leftrightoffset double precision) TO mbollam;


--
-- Name: FUNCTION st_locatebetweenelevations(geometry public.geometry, fromelevation double precision, toelevation double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_locatebetweenelevations(geometry public.geometry, fromelevation double precision, toelevation double precision) TO mbollam;


--
-- Name: FUNCTION st_longestline(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_longestline(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_m(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_m(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_makebox2d(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makebox2d(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_makeenvelope(double precision, double precision, double precision, double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makeenvelope(double precision, double precision, double precision, double precision, integer) TO mbollam;


--
-- Name: FUNCTION st_makeline(public.geometry[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makeline(public.geometry[]) TO mbollam;


--
-- Name: FUNCTION st_makeline(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makeline(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_makepoint(double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makepoint(double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makepoint(double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_makepoint(double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makepoint(double precision, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_makepointm(double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makepointm(double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_makepolygon(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makepolygon(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_makepolygon(public.geometry, public.geometry[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makepolygon(public.geometry, public.geometry[]) TO mbollam;


--
-- Name: FUNCTION st_makevalid(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makevalid(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_makevalid(geom public.geometry, params text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makevalid(geom public.geometry, params text) TO mbollam;


--
-- Name: FUNCTION st_maxdistance(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_maxdistance(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_maximuminscribedcircle(public.geometry, OUT center public.geometry, OUT nearest public.geometry, OUT radius double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_maximuminscribedcircle(public.geometry, OUT center public.geometry, OUT nearest public.geometry, OUT radius double precision) TO mbollam;


--
-- Name: FUNCTION st_memsize(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_memsize(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_minimumboundingcircle(inputgeom public.geometry, segs_per_quarter integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_minimumboundingcircle(inputgeom public.geometry, segs_per_quarter integer) TO mbollam;


--
-- Name: FUNCTION st_minimumboundingradius(public.geometry, OUT center public.geometry, OUT radius double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_minimumboundingradius(public.geometry, OUT center public.geometry, OUT radius double precision) TO mbollam;


--
-- Name: FUNCTION st_minimumclearance(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_minimumclearance(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_minimumclearanceline(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_minimumclearanceline(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_mlinefromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mlinefromtext(text) TO mbollam;


--
-- Name: FUNCTION st_mlinefromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mlinefromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_mlinefromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mlinefromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_mlinefromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mlinefromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_mpointfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpointfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_mpointfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpointfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_mpointfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpointfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_mpointfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpointfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_mpolyfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpolyfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_mpolyfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpolyfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_mpolyfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpolyfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_mpolyfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_mpolyfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_multi(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multi(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_multilinefromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multilinefromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_multilinestringfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multilinestringfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_multilinestringfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multilinestringfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_multipointfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multipointfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_multipointfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multipointfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_multipointfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multipointfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_multipolyfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multipolyfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_multipolyfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multipolyfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_multipolygonfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multipolygonfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_multipolygonfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_multipolygonfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_ndims(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_ndims(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_node(g public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_node(g public.geometry) TO mbollam;


--
-- Name: FUNCTION st_normalize(geom public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_normalize(geom public.geometry) TO mbollam;


--
-- Name: FUNCTION st_npoints(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_npoints(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_nrings(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_nrings(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_numgeometries(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_numgeometries(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_numinteriorring(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_numinteriorring(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_numinteriorrings(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_numinteriorrings(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_numpatches(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_numpatches(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_numpoints(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_numpoints(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_offsetcurve(line public.geometry, distance double precision, params text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_offsetcurve(line public.geometry, distance double precision, params text) TO mbollam;


--
-- Name: FUNCTION st_orderingequals(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_orderingequals(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_orientedenvelope(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_orientedenvelope(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_overlaps(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_overlaps(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_patchn(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_patchn(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_perimeter(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_perimeter(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_perimeter(geog public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_perimeter(geog public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_perimeter2d(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_perimeter2d(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_point(double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_point(double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_point(double precision, double precision, srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_point(double precision, double precision, srid integer) TO mbollam;


--
-- Name: FUNCTION st_pointfromgeohash(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointfromgeohash(text, integer) TO mbollam;


--
-- Name: FUNCTION st_pointfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_pointfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_pointfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_pointfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_pointinsidecircle(public.geometry, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointinsidecircle(public.geometry, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointm(xcoordinate double precision, ycoordinate double precision, mcoordinate double precision, srid integer) TO mbollam;


--
-- Name: FUNCTION st_pointn(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointn(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_pointonsurface(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointonsurface(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_points(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_points(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointz(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, srid integer) TO mbollam;


--
-- Name: FUNCTION st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_pointzm(xcoordinate double precision, ycoordinate double precision, zcoordinate double precision, mcoordinate double precision, srid integer) TO mbollam;


--
-- Name: FUNCTION st_polyfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polyfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_polyfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polyfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_polyfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polyfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_polyfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polyfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_polygon(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polygon(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_polygonfromtext(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polygonfromtext(text) TO mbollam;


--
-- Name: FUNCTION st_polygonfromtext(text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polygonfromtext(text, integer) TO mbollam;


--
-- Name: FUNCTION st_polygonfromwkb(bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polygonfromwkb(bytea) TO mbollam;


--
-- Name: FUNCTION st_polygonfromwkb(bytea, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polygonfromwkb(bytea, integer) TO mbollam;


--
-- Name: FUNCTION st_polygonize(public.geometry[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polygonize(public.geometry[]) TO mbollam;


--
-- Name: FUNCTION st_project(geog public.geography, distance double precision, azimuth double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_project(geog public.geography, distance double precision, azimuth double precision) TO mbollam;


--
-- Name: FUNCTION st_project(geog_from public.geography, geog_to public.geography, distance double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_project(geog_from public.geography, geog_to public.geography, distance double precision) TO mbollam;


--
-- Name: FUNCTION st_project(geom1 public.geometry, distance double precision, azimuth double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_project(geom1 public.geometry, distance double precision, azimuth double precision) TO mbollam;


--
-- Name: FUNCTION st_project(geom1 public.geometry, geom2 public.geometry, distance double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_project(geom1 public.geometry, geom2 public.geometry, distance double precision) TO mbollam;


--
-- Name: FUNCTION st_quantizecoordinates(g public.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_quantizecoordinates(g public.geometry, prec_x integer, prec_y integer, prec_z integer, prec_m integer) TO mbollam;


--
-- Name: FUNCTION st_reduceprecision(geom public.geometry, gridsize double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_reduceprecision(geom public.geometry, gridsize double precision) TO mbollam;


--
-- Name: FUNCTION st_relate(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_relate(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_relate(geom1 public.geometry, geom2 public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_relate(geom1 public.geometry, geom2 public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_relate(geom1 public.geometry, geom2 public.geometry, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_relate(geom1 public.geometry, geom2 public.geometry, text) TO mbollam;


--
-- Name: FUNCTION st_relatematch(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_relatematch(text, text) TO mbollam;


--
-- Name: FUNCTION st_removepoint(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_removepoint(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_removerepeatedpoints(geom public.geometry, tolerance double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_removerepeatedpoints(geom public.geometry, tolerance double precision) TO mbollam;


--
-- Name: FUNCTION st_reverse(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_reverse(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_rotate(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_rotate(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_rotate(public.geometry, double precision, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_rotate(public.geometry, double precision, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_rotate(public.geometry, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_rotate(public.geometry, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_rotatex(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_rotatex(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_rotatey(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_rotatey(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_rotatez(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_rotatez(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_scale(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_scale(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_scale(public.geometry, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_scale(public.geometry, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_scale(public.geometry, public.geometry, origin public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_scale(public.geometry, public.geometry, origin public.geometry) TO mbollam;


--
-- Name: FUNCTION st_scale(public.geometry, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_scale(public.geometry, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_scroll(public.geometry, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_scroll(public.geometry, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_segmentize(geog public.geography, max_segment_length double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_segmentize(geog public.geography, max_segment_length double precision) TO mbollam;


--
-- Name: FUNCTION st_segmentize(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_segmentize(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_seteffectivearea(public.geometry, double precision, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_seteffectivearea(public.geometry, double precision, integer) TO mbollam;


--
-- Name: FUNCTION st_setpoint(public.geometry, integer, public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_setpoint(public.geometry, integer, public.geometry) TO mbollam;


--
-- Name: FUNCTION st_setsrid(geog public.geography, srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_setsrid(geog public.geography, srid integer) TO mbollam;


--
-- Name: FUNCTION st_setsrid(geom public.geometry, srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_setsrid(geom public.geometry, srid integer) TO mbollam;


--
-- Name: FUNCTION st_sharedpaths(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_sharedpaths(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_shiftlongitude(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_shiftlongitude(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_shortestline(text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_shortestline(text, text) TO mbollam;


--
-- Name: FUNCTION st_shortestline(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_shortestline(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_shortestline(public.geography, public.geography, use_spheroid boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_shortestline(public.geography, public.geography, use_spheroid boolean) TO mbollam;


--
-- Name: FUNCTION st_simplify(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_simplify(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_simplify(public.geometry, double precision, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_simplify(public.geometry, double precision, boolean) TO mbollam;


--
-- Name: FUNCTION st_simplifypolygonhull(geom public.geometry, vertex_fraction double precision, is_outer boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_simplifypolygonhull(geom public.geometry, vertex_fraction double precision, is_outer boolean) TO mbollam;


--
-- Name: FUNCTION st_simplifypreservetopology(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_simplifypreservetopology(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_simplifyvw(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_simplifyvw(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_snap(geom1 public.geometry, geom2 public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_snap(geom1 public.geometry, geom2 public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_snaptogrid(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_snaptogrid(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_snaptogrid(public.geometry, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_snaptogrid(public.geometry, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_snaptogrid(public.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_snaptogrid(public.geometry, double precision, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_snaptogrid(geom1 public.geometry, geom2 public.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_snaptogrid(geom1 public.geometry, geom2 public.geometry, double precision, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_split(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_split(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_square(size double precision, cell_i integer, cell_j integer, origin public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_square(size double precision, cell_i integer, cell_j integer, origin public.geometry) TO mbollam;


--
-- Name: FUNCTION st_squaregrid(size double precision, bounds public.geometry, OUT geom public.geometry, OUT i integer, OUT j integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_squaregrid(size double precision, bounds public.geometry, OUT geom public.geometry, OUT i integer, OUT j integer) TO mbollam;


--
-- Name: FUNCTION st_srid(geog public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_srid(geog public.geography) TO mbollam;


--
-- Name: FUNCTION st_srid(geom public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_srid(geom public.geometry) TO mbollam;


--
-- Name: FUNCTION st_startpoint(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_startpoint(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_subdivide(geom public.geometry, maxvertices integer, gridsize double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_subdivide(geom public.geometry, maxvertices integer, gridsize double precision) TO mbollam;


--
-- Name: FUNCTION st_summary(public.geography); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_summary(public.geography) TO mbollam;


--
-- Name: FUNCTION st_summary(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_summary(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_swapordinates(geom public.geometry, ords cstring); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_swapordinates(geom public.geometry, ords cstring) TO mbollam;


--
-- Name: FUNCTION st_symdifference(geom1 public.geometry, geom2 public.geometry, gridsize double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_symdifference(geom1 public.geometry, geom2 public.geometry, gridsize double precision) TO mbollam;


--
-- Name: FUNCTION st_symmetricdifference(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_symmetricdifference(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_tileenvelope(zoom integer, x integer, y integer, bounds public.geometry, margin double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_tileenvelope(zoom integer, x integer, y integer, bounds public.geometry, margin double precision) TO mbollam;


--
-- Name: FUNCTION st_touches(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_touches(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_transform(public.geometry, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_transform(public.geometry, integer) TO mbollam;


--
-- Name: FUNCTION st_transform(geom public.geometry, to_proj text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_transform(geom public.geometry, to_proj text) TO mbollam;


--
-- Name: FUNCTION st_transform(geom public.geometry, from_proj text, to_srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_transform(geom public.geometry, from_proj text, to_srid integer) TO mbollam;


--
-- Name: FUNCTION st_transform(geom public.geometry, from_proj text, to_proj text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_transform(geom public.geometry, from_proj text, to_proj text) TO mbollam;


--
-- Name: FUNCTION st_transformpipeline(geom public.geometry, pipeline text, to_srid integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_transformpipeline(geom public.geometry, pipeline text, to_srid integer) TO mbollam;


--
-- Name: FUNCTION st_translate(public.geometry, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_translate(public.geometry, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_translate(public.geometry, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_translate(public.geometry, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_transscale(public.geometry, double precision, double precision, double precision, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_transscale(public.geometry, double precision, double precision, double precision, double precision) TO mbollam;


--
-- Name: FUNCTION st_triangulatepolygon(g1 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_triangulatepolygon(g1 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_unaryunion(public.geometry, gridsize double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_unaryunion(public.geometry, gridsize double precision) TO mbollam;


--
-- Name: FUNCTION st_union(public.geometry[]); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_union(public.geometry[]) TO mbollam;


--
-- Name: FUNCTION st_union(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_union(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_union(geom1 public.geometry, geom2 public.geometry, gridsize double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_union(geom1 public.geometry, geom2 public.geometry, gridsize double precision) TO mbollam;


--
-- Name: FUNCTION st_voronoilines(g1 public.geometry, tolerance double precision, extend_to public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_voronoilines(g1 public.geometry, tolerance double precision, extend_to public.geometry) TO mbollam;


--
-- Name: FUNCTION st_voronoipolygons(g1 public.geometry, tolerance double precision, extend_to public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_voronoipolygons(g1 public.geometry, tolerance double precision, extend_to public.geometry) TO mbollam;


--
-- Name: FUNCTION st_within(geom1 public.geometry, geom2 public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_within(geom1 public.geometry, geom2 public.geometry) TO mbollam;


--
-- Name: FUNCTION st_wkbtosql(wkb bytea); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_wkbtosql(wkb bytea) TO mbollam;


--
-- Name: FUNCTION st_wkttosql(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_wkttosql(text) TO mbollam;


--
-- Name: FUNCTION st_wrapx(geom public.geometry, wrap double precision, move double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_wrapx(geom public.geometry, wrap double precision, move double precision) TO mbollam;


--
-- Name: FUNCTION st_x(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_x(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_xmax(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_xmax(public.box3d) TO mbollam;


--
-- Name: FUNCTION st_xmin(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_xmin(public.box3d) TO mbollam;


--
-- Name: FUNCTION st_y(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_y(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_ymax(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_ymax(public.box3d) TO mbollam;


--
-- Name: FUNCTION st_ymin(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_ymin(public.box3d) TO mbollam;


--
-- Name: FUNCTION st_z(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_z(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_zmax(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_zmax(public.box3d) TO mbollam;


--
-- Name: FUNCTION st_zmflag(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_zmflag(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_zmin(public.box3d); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_zmin(public.box3d) TO mbollam;


--
-- Name: FUNCTION unlockrows(text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.unlockrows(text) TO mbollam;


--
-- Name: FUNCTION updategeometrysrid(character varying, character varying, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.updategeometrysrid(character varying, character varying, integer) TO mbollam;


--
-- Name: FUNCTION updategeometrysrid(character varying, character varying, character varying, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.updategeometrysrid(character varying, character varying, character varying, integer) TO mbollam;


--
-- Name: FUNCTION updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.updategeometrysrid(catalogn_name character varying, schema_name character varying, table_name character varying, column_name character varying, new_srid_in integer) TO mbollam;


--
-- Name: FUNCTION st_3dextent(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_3dextent(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_asflatgeobuf(anyelement); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asflatgeobuf(anyelement) TO mbollam;


--
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asflatgeobuf(anyelement, boolean) TO mbollam;


--
-- Name: FUNCTION st_asflatgeobuf(anyelement, boolean, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asflatgeobuf(anyelement, boolean, text) TO mbollam;


--
-- Name: FUNCTION st_asgeobuf(anyelement); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgeobuf(anyelement) TO mbollam;


--
-- Name: FUNCTION st_asgeobuf(anyelement, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asgeobuf(anyelement, text) TO mbollam;


--
-- Name: FUNCTION st_asmvt(anyelement); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asmvt(anyelement) TO mbollam;


--
-- Name: FUNCTION st_asmvt(anyelement, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asmvt(anyelement, text) TO mbollam;


--
-- Name: FUNCTION st_asmvt(anyelement, text, integer); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asmvt(anyelement, text, integer) TO mbollam;


--
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asmvt(anyelement, text, integer, text) TO mbollam;


--
-- Name: FUNCTION st_asmvt(anyelement, text, integer, text, text); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_asmvt(anyelement, text, integer, text, text) TO mbollam;


--
-- Name: FUNCTION st_clusterintersecting(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterintersecting(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_clusterwithin(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_clusterwithin(public.geometry, double precision) TO mbollam;


--
-- Name: FUNCTION st_collect(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_collect(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_coverageunion(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_coverageunion(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_extent(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_extent(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_makeline(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_makeline(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_memcollect(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_memcollect(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_memunion(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_memunion(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_polygonize(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_polygonize(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_union(public.geometry); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_union(public.geometry) TO mbollam;


--
-- Name: FUNCTION st_union(public.geometry, double precision); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION public.st_union(public.geometry, double precision) TO mbollam;


--
-- Name: TABLE flood_zones; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.flood_zones TO mbollam;


--
-- Name: SEQUENCE flood_zones_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.flood_zones_id_seq TO mbollam;


--
-- Name: TABLE geography_columns; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.geography_columns TO mbollam;


--
-- Name: TABLE geometry_columns; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.geometry_columns TO mbollam;


--
-- Name: TABLE georgia_roads_vertices_pgr; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.georgia_roads_vertices_pgr TO mbollam;


--
-- Name: TABLE hospitals; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.hospitals TO mbollam;


--
-- Name: SEQUENCE hospitals_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,USAGE ON SEQUENCE public.hospitals_id_seq TO mbollam;


--
-- Name: TABLE person; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.person TO mbollam;


--
-- Name: SEQUENCE person_id_seq; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE public.person_id_seq TO mbollam;


--
-- Name: TABLE roads_vertices_pgr; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT ON TABLE public.roads_vertices_pgr TO mbollam;


--
-- Name: TABLE spatial_ref_sys; Type: ACL; Schema: public; Owner: postgres
--

GRANT SELECT,INSERT,DELETE,UPDATE ON TABLE public.spatial_ref_sys TO mbollam;


--
-- PostgreSQL database dump complete
--

