import arrow
import forecastio as forecast
from flask import current_app


def datetime_from_string(dt_str):
    return arrow.get(dt_str).datetime


class ForecastIo(object):
    def __init__(self):
        self.api_key = current_app.config['FORECASTIO_KEY']

    @staticmethod
    def load_forecast(lat, lng, time):
        return forecast.load_forecast(ForecastIo().api_key, lat, lng, datetime_from_string(time))

    @staticmethod
    def get_weather_on_date(lat, lng, time):
        return ForecastIo.load_forecast(lat, lng, datetime_from_string(time)).currently()
