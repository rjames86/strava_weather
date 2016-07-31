# @codekit-prepend "weather.coffee"
# @codekit-prepend "map.coffee"
# @codekit-prepend "rideinfo.coffee"

d = React.DOM
ce = React.createElement

MainContent = React.createFactory React.createClass
  displayName: "MainContent"
  propTypes:
    selectedActivity: React.PropTypes.object

  render: ->
    if not @props.selectedActivity
      d.h1
        className: "center"
      ,
        "Select an activity to get started"
    else
      d.div {},
        d.div
          className: "row weather-rideinfo-container"
        ,
          d.div
            className: "col-md-6"
          ,
            if @props.selectedActivity
              Weather activity: @props.selectedActivity

          d.div
            className: "col-md-6 strava-ride-info"
          ,
            if @props.selectedActivity
              RideInfo activity: @props.selectedActivity
        d.div
          className: "row strava-map"
        ,
          d.div
            className: "col-md-12"
          ,
            if @props.selectedActivity
              StravaMap activity: @props.selectedActivity




