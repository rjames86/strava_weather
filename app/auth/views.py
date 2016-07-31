from flask import (
    request,
    render_template,
    url_for,
    redirect,
)
from flask_login import (
    current_user,
    login_user,
    login_required,
    logout_user
)
from . import auth
from app import db
from app.models.strava import Strava
from app.models.user import StravaUser


@auth.route('/authorize')
def authorize():
    return redirect(Strava.authorization_url())


@auth.route('/confirm')
def confirm_auth():
    if request.args.get('error') == 'access_denied':
        return render_template('auth/no_access.html')
    token = Strava().get_access_token(request.args.get('code'))
    new_user = StravaUser(strava_token=token)
    db.session.add(new_user)
    db.session.commit()
    login_user(new_user)
    return redirect(url_for('main.index'))


@auth.route('/logout')
@login_required
def logout():
    user = StravaUser.query.filter_by(strava_token=current_user.get_id()).first()
    user.logout_and_deauthorize()
    logout_user()
    return render_template('auth/logout.html')
