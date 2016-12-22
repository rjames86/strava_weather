from flask import Flask
from flask_login import LoginManager
from flask_sqlalchemy import SQLAlchemy
from flask.json import JSONEncoder

from app.models.strava import Activity

from config import config

db = SQLAlchemy()
login_manager = LoginManager()
login_manager.session_protection = 'strong'
login_manager.login_view = 'auth.authorize'


class CustomJSONEncoder(JSONEncoder):
    def default(self, obj):
        try:
            if isinstance(obj, Activity):
                return obj.serialize()
        except TypeError:
            pass
        else:
            return JSONEncoder.default(self, obj)


def create_app(config_name='default'):
    app = Flask(__name__)
    app.json_encoder = CustomJSONEncoder
    app.config.from_object(config[config_name])
    config[config_name].init_app(app)

    db.init_app(app)
    login_manager.init_app(app)

    from .main import main as main_blueprint
    from .auth import auth as auth_blueprint
    from .strava import strava as strava_blueprint
    from .rwgs import rwgs as rwgs_blueprint
    from .weather import weather as weather_blueprint

    app.register_blueprint(main_blueprint)
    app.register_blueprint(auth_blueprint, url_prefix='/auth')
    app.register_blueprint(strava_blueprint, url_prefix='/strava')
    app.register_blueprint(rwgs_blueprint, url_prefix='/rwgs')
    app.register_blueprint(weather_blueprint, url_prefix='/weather')

    return app
