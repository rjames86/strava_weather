from flask import Blueprint

strava = Blueprint('strava', __name__)

from . import views
