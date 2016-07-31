from flask_login import UserMixin
from app import db, login_manager
from app.models.strava import Strava


@login_manager.user_loader
def load_user(token):
    return StravaUser.get_athlete_by_token(token)


class StravaUser(UserMixin, db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    strava_token = db.Column(db.String(80))

    @staticmethod
    def get_or_create(strava_token):
        rv = StravaUser.query.filter_by(strava_token=strava_token).first()
        if rv is None:
            rv = StravaUser()
            rv.strava_token = strava_token
            db.session.add(rv)
        return rv

    @staticmethod
    def get_athlete_by_token(token):
        return StravaUser.query.filter_by(strava_token=token).first()

    def athlete(self):
        return Strava.athlete_by_token(self.strava_token)

    def activities(self, **kw):
        return Strava.activities_by_token(self.strava_token, **kw)

    def get_activity(self, id):
        return Strava.client_from_token(self.strava_token).get_activity(id)

    def logout_and_deauthorize(self):
        # Deauthorize the app so they have to re-accept when logging back in
        Strava.client_from_token(self.strava_token).deauthorize()
        # Let's not keep their token around
        db.session.delete(self)
        db.session.commit()

    def get_id(self):
        return self.strava_token
