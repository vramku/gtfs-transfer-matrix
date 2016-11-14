#!/bin/bash

gtfsFiles=(
    "http://web.mta.info/developers/data/nyct/subway/google_transit.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_bronx.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_brooklyn.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_manhattan.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_queens.zip"
    "http://web.mta.info/developers/data/nyct/bus/google_transit_staten_island.zip"
    #of course everything is named google_transit.zip
    "http://web.mta.info/developers/data/lirr/google_transit.zip"
    #"http://web.mta.info/developers/data/mnr/google_transit.zip"
    "http://web.mta.info/developers/data/busco/google_transit.zip"
)

set -e
mkdir -p gtfs-download
cd gtfs-download
set -vx

for f in "${gtfsFiles[@]}"
    do
        IFS='/' read -r -a urlarray <<< "$f"
        #disambiguate google_transit.zip to google_transit_X.zip
        outfile="${urlarray[-1]%.zip}_${urlarray[-2]}.zip"
        wget -nv -NS $f -O $outfile
done

python ../prepend_agency_id.py google_transit_lirr.zip LIRR
mv google_transit_lirr.zip.new google_transit_lirr.zip

for z in *.zip
    do
        unzip -o -d "${z%.*}" $z
done 

#drop NYCT Bus holidays and shapes for speed.
for d in *_bus/; do
    cd $d
    sed -i -e '/[A-Z]{2}_[G-Z][0-9]-/d' calendar.txt calendar_dates.txt trips.txt stop_times.txt
    rm shapes.txt
    cd ..
done

#../src is a link to the GTFS-SQL-Importer
echo "creating tables"
cat ../src/gtfs_tables.sql | psql -q gtfs

for d in */; do
        echo "importing $d"
        #nocopy supports upsert, necessary as stops will not be unique
        python ../src/import_gtfs_to_sql.py $d nocopy  | psql -q gtfs
done

cat ../src/gtfs_tables_makespatial.sql \
    ../src/gtfs_tables_makeindexes.sql \
    ../src/vacuumer.sql | psql -e gtfs

#cat ../gtfs_calendar_lookup.sql | psql gtfs