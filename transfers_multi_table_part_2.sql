
drop table if exists gtfs_stops_nearby;

create table gtfs_stops_nearby as
select distinct p.stop_id , n.stop_id as nearby_stop
from gtfs_stops p
inner join gtfs_stops n 
	on ST_DWithin(p.the_geom::geography, n.the_geom::geography, 150)
inner join gtfs_stop_agency_map m on n.stop_id = m.stop_id
where m.agency_id !='LIRR'
UNION ALL
select distinct p.stop_id , n.stop_id as nearby_stop
from gtfs_stops p
inner join gtfs_stops n 
	on ST_DWithin(p.the_geom::geography, n.the_geom::geography, 250)
inner join gtfs_stop_agency_map m on n.stop_id = m.stop_id
where m.agency_id ='LIRR'
	;

drop table if exists gtfs_stops_transfers;

create table gtfs_stops_transfers as
select distinct 
p.stop_id
,r.time
,c.translated as service_id
,string_agg(distinct r.route_id, ',') as routes
from gtfs_stops_nearby p
inner join gtfs_routes_for_stop_at_intervals r on r.stop_id = p.nearby_stop
inner join gtfs_calendar_lookup c on r.service_id = c.service_id
where length(p.stop_id) > 4
group by p.stop_id, c.translated, r.time
-- only stops with more than one route.
HAVING count(distinct r.route_id) > 1
order by stop_id, time
;