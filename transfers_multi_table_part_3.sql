-- hard code updating the transfers table with LIRR stops at all times. 

select stop_id
,time
,service_id
,routes || ',LIRR' as routes
from gtfs_stops_transfers t
natural inner join gtfs_stops_nearby n 
natural inner join gtfs_stop_agency_map m
where
(length(n.nearby_stop) < 4 or n.nearby_stop LIKE 'LIRR%')

limit 10000