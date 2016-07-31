#!/usr/bin/env python
import os

from app import create_app, db
from flask_script import Manager, Shell
from flask_migrate import Migrate, MigrateCommand

from app.models.user import StravaUser
from app.models.strava import Strava

app = create_app(os.getenv('FLASK_CONFIG') or 'default')
manager = Manager(app)
migrate = Migrate(app, db)


def make_shell_context():
    return dict(app=app, db=db, StravaUser=StravaUser, Strava=Strava)

manager.add_command("shell", Shell(make_context=make_shell_context))
manager.add_command('db', MigrateCommand)

@manager.command
def create_db():
    db.create_all()

if __name__ == '__main__':
    manager.run()
