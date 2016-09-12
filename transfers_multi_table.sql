
 -- function courtesy PostgreSQL wiki
CREATE OR REPLACE FUNCTION round_time(TIME WITHOUT TIME ZONE) RETURNS TIME WITHOUT TIME ZONE AS $$
  SELECT "time"(date_trunc('hour', $1)
  + INTERVAL '15 min' * FLOOR(date_part('minute', $1) / 15.0) ) $$ LANGUAGE SQL;

drop table if exists gtfs_routes_for_stop_at_intervals;

create table gtfs_routes_for_stop_at_intervals
WITH OIDS
as select distinct stop_id 
,  CASE
WHEN service_id ~ '^[A-Z]{4}' THEN
split_part(service_id,'-',3) || '-' || split_part(service_id,'-',5) 
WHEN service_id ~ '^[A-Z]{2}_' THEN
split_part(service_id,'-',2) || '-' || split_part(service_id,'-',4) 
WHEN service_id ~ '^[A-Z][0-9]*[A-Z]{3}' THEN
regexp_matches(service_id, '([A-Z]{3}$)')::text
ELSE service_id
END
AS service_id
, route_id
, agency_id
,round_time("time"(
to_timestamp(cast(st.arrival_time_seconds as text),'SSSS')
)) as time 
from gtfs_stop_times st
natural inner join gtfs_trips
natural inner join gtfs_routes;

create index stop_route_idx on gtfs_routes_for_stop_at_intervals (stop_id, service_id);


create table if not exists gtfs_calendar_lookup (
   service_id varchar(32),
   translated varchar(32)
 ) WITH OIDS;