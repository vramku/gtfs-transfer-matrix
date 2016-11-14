--
-- PostgreSQL database dump
--

-- Dumped from database version 9.5.4
-- Dumped by pg_dump version 9.5.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: gtfs_calendar_lookup; Type: TABLE; Schema: public; Owner: user
--
BEGIN;
CREATE TABLE IF NOT EXISTS gtfs_calendar_lookup (
    service_id character varying(32),
    translated character varying(32)
);


ALTER TABLE gtfs_calendar_lookup OWNER TO "user";

--
-- Data for Name: gtfs_calendar_lookup; Type: TABLE DATA; Schema: public; Owner: user
--

COPY gtfs_calendar_lookup (service_id, translated) FROM stdin;
{WKD}	Weekday-SDon
Weekday-SDon	Weekday-SDon
Weekday-	Weekday
Saturday-	Saturday
Sunday-	Sunday
{WKD}	Weekday
{SAT}	Saturday
{SUN}	Sunday
\.
COMMIT;

--
-- PostgreSQL database dump complete
--

