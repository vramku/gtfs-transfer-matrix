drop table if exists mtabc_stops;

create table if not exists mtabc_stops as
select distinct stop_id from gtfs_stop_times st
natural inner join gtfs_trips t
natural inner join gtfs_routes r
where r.agency_id = 'MTABC';

select * from gtfs_stops_transfers
natural left join mtabc_stops
-- where stop_id = '307263'
-- limit 10
;