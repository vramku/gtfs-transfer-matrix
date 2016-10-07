#!/bin/bash

gtfsFiles=(
    "http://web.mta.info/developers/data/nyct/subway/google_transit.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_bronx.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_brooklyn.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_manhattan.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_queens.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_staten_island.zip"
    "http://web.mta.info/developers/data/lirr/google_transit.zip"
    "http://web.mta.info/developers/data/mnr/google_transit.zip"
    "http://web.mta.info/developers/data/busco/google_transit.zip"
)

set -e
mkdir -p gtfs-download
cd gtfs-download

for f in "${gtfsFiles[@]}"
    do
        wget -nv -N $f
    done

for z in *.zip
    do
        #rm -rf "${z%.*}"
        unzip -f -d "${z%.*}" $z
    done 

#../src is a link to the GTFS-SQL-Importer
echo "creating tables"
cat ../src/gtfs_tables.sql | psql -q gtfs

#counter to stop using COPY after the first import 
#COPY does not support upsert, but is faster
a=0

for d in */; do
    echo "importing $d"
    #if [ "$a" -le 1 ] 
    #    then
            #python ../src/import_gtfs_to_sql.py $d | psql gtfs
            #((a++))
    #else
            python ../src/import_gtfs_to_sql.py $d nocopy  | psql -q gtfs
    #fi 
done

cat ../src/gtfs_tables_makespatial.sql \
    ../src/gtfs_tables_makeindexes.sql \
    ../src/vacuumer.sql \
    gtfs_calendar_lookup.sql | psql gtfs