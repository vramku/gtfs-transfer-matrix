#!/usr/bin/python

import mzgtfs.feed
import mzgtfs.util
import sys, os

gtfs_file = sys.argv[1]

gtfs_feed = mzgtfs.feed.Feed(filename=gtfs_file)
gtfs_feed.preload()
files = ["routes.txt", "trips.txt"]

if len(gtfs_feed.agencies()) > 1:
    print "I don't work on feeds with more than one agency'"
    sys.exit(1)

agency_id = gtfs_feed.agencies()[0].id()

for route in gtfs_feed.routes():
    new_route_id = agency_id + '_' + route.id()
    route.set('route_id',new_route_id)

for trip in gtfs_feed.trips():
    new_route_id = agency_id + '_' + trip.get('route_id')
    trip.set('route_id',new_route_id)

for f in files:
    if os.path.exists(f):
        os.remove(f)

gtfs_feed.write('routes.txt', gtfs_feed.routes())
gtfs_feed.write('trips.txt', gtfs_feed.trips())

gtfs_feed.make_zip(gtfs_file + ".new", files=files, clone=gtfs_file)