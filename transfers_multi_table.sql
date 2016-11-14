
 -- function courtesy PostgreSQL wiki
CREATE OR REPLACE FUNCTION round_time(TIME WITHOUT TIME ZONE) RETURNS TIME WITHOUT TIME ZONE AS $$
  SELECT "time"(date_trunc('hour', $1)
  + INTERVAL '15 min' * FLOOR(date_part('minute', $1) / 15.0) ) $$ LANGUAGE SQL;

DROP TABLE IF EXISTS gtfs_routes_for_stop_at_intervals;

CREATE TABLE gtfs_routes_for_stop_at_intervals
WITH OIDS
as SELECT DISTINCT stop_id 
,CASE
  -- MTABC
  WHEN service_id ~ '^[A-Z]{4}' THEN
  split_part(service_id,'-',3) || '-' || split_part(service_id,'-',5) 
  -- NYCT BUS
  WHEN service_id ~ '^[A-Z]{2}_' THEN
  split_part(service_id,'-',2) || '-' || split_part(service_id,'-',4)
  --  NYCT SUBWAY
  WHEN service_id ~ '^[A-Z][0-9]*[A-Z]{3}' THEN
  regexp_matches(service_id, '([A-Z]{3}$)')::text
  -- The rest will be handled by agency_id
  ELSE service_id
  END
AS service_id

,CASE
  WHEN split_part(route_id,'_',1) = 'LIRR' THEN
  'LIRR'
  ELSE route_id
  END
AS route_id

, agency_id
,round_time("time"(
to_timestamp(cast(st.arrival_time_seconds as text),'SSSS')
)) as time 
from gtfs_stop_times st
natural inner join gtfs_trips
natural inner join gtfs_routes;

create index stop_route_idx on gtfs_routes_for_stop_at_intervals (stop_id, service_id);


drop table if exists gtfs_stop_agency_map;
create table gtfs_stop_agency_map as
select distinct stop_id,
CASE 
	when r.route_id like 'LIRR%'
	then 'LIRR'
	else r.agency_id
END as agency_id
from gtfs_stop_times st
natural inner join gtfs_trips t
natural inner join gtfs_routes r;