from flask import (
    jsonify,
    request,
    session,
    redirect,
    url_for,
)

from flask_login import login_required, current_user

from . import rwgs
from app.models.rwgs import RWGS

@rwgs.route('/route/<int:id>')
def get_route(id):
    return jsonify(data=RWGS.get_track_points(id))

@rwgs.route('/trip/<int:id>')
def get_trip(id):
    return jsonify(data=RWGS.get_trip_points(id))

@rwgs.route('/route/<int:id>/raw')
def get_route_raw(id):
    return jsonify(data=RWGS.get_rout_by_id(id))

@rwgs.route('/trip/<int:id>/raw')
def get_trip_raw(id):
    return jsonify(data=RWGS.get_trip_by_id(id))
