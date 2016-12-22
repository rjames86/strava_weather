from flask import Blueprint

rwgs = Blueprint('rwgs', __name__)

from . import views
