d = React.DOM
ce = React.createElement

RideInfo = React.createFactory React.createClass
  displayName: "RideInfo"
  propTypes:
    activity: React.PropTypes.object

  metersToMiles: (distance) ->
    miles = distance / 1609.344
    return Math.round(miles * 100) / 100

  metersToFeet: (distance) ->
    miles = @metersToMiles(distance) * 5280
    return Math.round(miles * 100) / 100

  secondsToHours: (seconds) ->
    sec_num = parseInt(seconds, 10)
    hours   = Math.floor(sec_num / 3600)
    minutes = Math.floor((sec_num - (hours * 3600)) / 60)
    seconds = sec_num - (hours * 3600) - (minutes * 60)

    if (hours   < 10)
      hours   = "0" + hours
    if (minutes < 10)
      minutes = "0" + minutes
    if (seconds < 10)
      seconds = "0" + seconds
    return hours + ':' + minutes + ':' + seconds

  kilometersToMiles: (distance) ->
    miles = distance / 0.44704
    return Math.round(miles * 100) / 100

  isoToDate: (ts) ->
    date = new Date Date.parse(ts)
    "#{date.getFullYear()}-#{date.getMonth() + 1}-#{date.getDate()}"

  render: ->
    d.div
      className: "row"
    ,
      d.div
        className: "col-md-12"
      ,
        d.h2
          className: "center"
        ,
          @props.activity.name
      d.div
        className: "col-md-12 center"
      ,
        d.ul
          className: "rideinfo"
        ,
          d.li {}, "Start Time: #{@isoToDate @props.activity.start_date_local}"
          d.li {}, "Distance: #{@metersToMiles @props.activity.distance} mi"
          d.li {}, "Elapsed Time: #{@secondsToHours @props.activity.elapsed_time}"
        d.ul
          className: "rideinfo"
        ,
          d.li {}, "Elevation Gain: #{@metersToFeet @props.activity.total_elevation_gain} ft"
          d.li {}, "Max Speed: #{@kilometersToMiles @props.activity.max_speed} mph"
          d.li {}, "Gear: #{@props.activity.gear.name}" unless not @props.activity.gear

