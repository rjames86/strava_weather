from flask import (
    jsonify,
    request,
    session,
    redirect,
    url_for,
)

from flask_login import login_required, current_user

from . import strava


@strava.route('/activities')
@login_required
def activities():
    params = dict(before=request.args.get('before'),
                  after=request.args.get('after'))

    activities = list(current_user.activities(**params))
    return jsonify(data=activities)


@strava.route('/activity/<int:id>')
@login_required
def activity(id):
    return jsonify(data=current_user.get_activity(id))


@strava.route('/activity/<int:id>/weather_at_start')
@login_required
def activity_weather_at_start(id):
    return jsonify(data=current_user.get_activity(id).weather_at_start)
