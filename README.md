# Strava Weather Display
2016-07-31

Welcome to my Strava Weather display! Once you get setup (instructions below), when you first visit the page you should be prompted to log in with your Strava account. Once authorized, you'll see a list of all of your activities on the left-hand side of the page. Click on one of the activities to see a map of the route and the weather at the start of that particular activity.

![](https://dl.dropboxusercontent.com/s/44svk2zx36z4fu4/Screenshot%202016-07-31%2012.32.08.png?dl=0)


## Setup
    cd strava_weather

    # Create virtualenv
    virtualenv venv
    source venv/bin/activate

    # Install requirements
    pip install -r requirements.txt

    # Create the tables
    python manage.py create_db

    # Start the webserver
    python manage.py runserver

    # Visit http://localhost:5000

## Notes
- I didn't want to share my API keys publically. If you have keys for Forecast.IO and Strava, you can add them to the project or exporting them to the environment before running the server. You can see a working copy at [http://strava.ryanmo.co](http://strava.ryanmo.co).
    `export FORECASTIO_KEY=YOUR_KEY_HERE`

## Ideas for future improvement
- For longer activities, having markers along the map that you can click to see weather along the route
- Better mobile setup
    + iPad landscape is fine
    + iPhone isn't great
- Show saved routes and ability to see future weather (is this possible? Could be useful for planning touring/longer rides)

## Libraries Used
- Flask
- Bootstrap
- ReactJS
- stravalib (https://github.com/hozn/stravalib)
- python-forecast.io (https://github.com/ZeevG/python-forecast.io)
- Forecast.IO weather icons (http://blog.forecast.io/skycons-unobtrustive-animated-weather-icons/)
- polyline.js (https://github.com/mapbox/polyline)
- leaflet.js (http://leafletjs.com)
