from flask import (
    jsonify,
    request,
    session,
    redirect,
    url_for,
)

from flask_login import login_required, current_user
from app.models.weather_forecast import ForecastIo

from . import weather


@weather.route('/<lat>/<lng>/<time>')
def get_weather(lat, lng, time):
    print "time", time
    weather = ForecastIo.get_weather_on_date(
                float(lat),
                float(lng),
                float(time)).d
    return jsonify(data=weather)

