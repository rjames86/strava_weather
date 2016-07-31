from flask import current_app, url_for

import functools
from stravalib.client import (
    Client as oStravaClient,
    BatchedResultsIterator
)
from stravalib.model import Activity as oActivity
from app.models.weather_forecast import ForecastIo


class StravaClient(oStravaClient):
    def get_activities(self, before=None, after=None, limit=None):
        """
        Overriding oStravaClient.get_activities because all of the attributes
        get set on the object and make it way harder to serialize
        """

        if before:
            before = self._utc_datetime_to_epoch(before)

        if after:
            after = self._utc_datetime_to_epoch(after)

        params = dict(before=before, after=after)
        result_fetcher = functools.partial(self.protocol.get,
                                           '/athlete/activities',
                                           **params)

        return BatchedResultsIterator(entity=Activity,
                                      bind_client=self,
                                      result_fetcher=result_fetcher,
                                      limit=limit)

    def get_activity(self, activity_id, include_all_efforts=False):
        """
        Overriding for the same reason as self.get_activities
        """
        raw = self.protocol.get('/activities/{id}', id=activity_id,
                                include_all_efforts=include_all_efforts)
        return Activity.deserialize(raw, bind_client=self)

    def deauthorize(self):
        """
        Deauthorize the application. This causes the application to be removed
        from the athlete's "My Apps" settings page.

        See http://strava.github.io/api/v3/oauth/#deauthorization
        """
        self.protocol.post("oauth/deauthorize")


class Activity(oActivity):
    @classmethod
    def deserialize(cls, v, bind_client=None):
        """
        Creates a new object based on serialized (dict) struct.
        """
        if v is None:
            return None
        o = cls(bind_client=bind_client)
        o.from_dict(v)
        o.attrsdict = v
        return o

    def serialize(self):
        return self.attrsdict

    @property
    def weather_at_start(self):
        return ForecastIo.get_weather_on_date(
            self.start_latitude,
            self.start_longitude,
            self.start_date_local
        ).d


class Strava(object):
    def __init__(self):
        self.client_id = current_app.config['STRAVA_CLIENT_ID']
        self.client_secret = current_app.config['STRAVA_CLIENT_SECRET']
        self.redirect_uri = url_for('auth.confirm_auth', _external=True)

        self.client = StravaClient()

    @property
    def athlete(self):
        return self.client.get_athlete()

    def activities(self, before=None, after=None):
        kw = {}
        # The stravalib client doesn't handle unicode well, so cast the args to string
        if before:
            kw['before'] = str(before)
        if after:
            kw['after'] = str(after)
        return self.client.get_activities(**kw)

    @classmethod
    def authorization_url(cls):
        self = cls()
        return self.client.authorization_url(client_id=self.client_id,
                                             redirect_uri=self.redirect_uri)

    def get_access_token(self, code):
        return self.client.exchange_code_for_token(client_id=self.client_id,
                                                   client_secret=self.client_secret,
                                                   code=code)

    @classmethod
    def athlete_by_token(cls, token):
        self = cls()
        self.client.access_token = token
        return self.athlete

    @classmethod
    def activities_by_token(cls, token, **kw):
        self = cls()
        self.client.access_token = token
        return self.activities(**kw)

    @classmethod
    def client_from_token(cls, token):
        self = cls()
        self.client.access_token = token
        return self.client
