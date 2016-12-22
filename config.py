import os
basedir = os.path.abspath(os.path.dirname(__file__))


class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'hard to guess string'
    STRAVA_CLIENT_ID = os.environ.get('STRAVA_CLIENT_ID')
    STRAVA_CLIENT_SECRET = os.environ.get('STRAVA_CLIENT_SECRET')
    FORECASTIO_KEY = os.environ.get('FORECASTIO_KEY')
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'data-dev.sqlite')

    DEBUG = True

    @staticmethod
    def init_app(app):
        pass


class Production(Config):
    import prod_config as config

    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'data-dev.sqlite')
    STRAVA_CLIENT_ID = config.STRAVA_CLIENT_ID
    STRAVA_CLIENT_SECRET = config.STRAVA_CLIENT_SECRET
    FORECASTIO_KEY = config.FORECASTIO_KEY

    DEBUG = True

class HerokuConfig(Config):
    DEBUG = False
    @classmethod
    def init_app(cls, app):
        print "Using Heroku config"
        Config.init_app(app)

        # log to stderr
        import logging
        from logging import StreamHandler
        file_handler = StreamHandler()
        file_handler.setLevel(logging.ERROR)
        app.logger.addHandler(file_handler)

config = {
    'default': Config,
    'prod': Production,
    'heroku': HerokuConfig
}
