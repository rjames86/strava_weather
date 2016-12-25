from flask import current_app, url_for

import functools
from stravalib.client import (
    Client as oStravaClient,
    BatchedResultsIterator
)
from app.lib.rwgs import RWGS as RWGSLib


class RWGS(object):
    KEYS_TO_KEEP = [
        'id',
        'description',
        'distance',
        'elevation_gain',
        'name',
        'track_id',
        'track_points'
    ]

    def __init__(self):
        self.client = RWGSLib('f7faf5ac')

    @classmethod
    def get_route_by_id(cls, route_id):
        self = cls()
        return self.client.routes(id=route_id)

    @classmethod
    def get_trip_by_id(cls, route_id):
        self = cls()
        return self.client.trips(id=route_id)

    @classmethod
    def get_track_points(cls, route_id):
        track = cls.get_route_by_id(route_id)
        return {k: track['route'].get(k) for k in cls.KEYS_TO_KEEP}

    @classmethod
    def get_trip_points(cls, route_id):
        trip = cls.get_trip_by_id(route_id)
        return {k: trip['trip'].get(k) for k in cls.KEYS_TO_KEEP}






