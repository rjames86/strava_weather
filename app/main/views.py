from flask import (
    request,
    session,
    redirect,
    render_template,
    url_for,
)

from . import main
from flask_login import login_required, current_user


@main.route('/')
@login_required
def index():
    return redirect(url_for('main.mapweather'))
    # return render_template('main/index.html', athlete=current_user.athlete())

@main.route('/mapweather')
def mapweather():
    return render_template('main/mapweather.html')


