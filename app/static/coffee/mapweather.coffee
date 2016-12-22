savedPoints = {}

calculateTimeFromStart = (point) ->
  startTime = 1482352464
  speed = 24 * 1000 # meters per hour (~15 mph)
  time = (point.d / speed) * 60 * 60 # meters per second
  startTime + time

getWeatherForPoint = (point, callback) ->
  if savedPoints["#{point.y},#{point.x}"]
    return callback savedPoints["#{point.y},#{point.x}"]
  $.ajax
    async: false
    url: "/weather/#{point.y}/#{point.x}/#{calculateTimeFromStart point}",
    success: (res) ->
      savedPoints["#{point.y},#{point.x}"] = res
      return callback res
    error: -> return callback {}

makeInfoWindow = (info) ->
  listItem = (i, j) -> "<dt>#{i}</dt><dd>#{j}</dd>"
  keyMap =
    apparentTemperature: (value) -> listItem "Feels Like", value
    humidity: (value) -> listItem "Humidity", value
    # icon: (value) -> null
    precipProbability: (value) -> listItem "Precipitation Probability", value
    summary: (value) -> listItem "Summary", value
    temperature: (value) -> listItem "Temperature", value
    time: (value) -> listItem "Estimated Arrival Time", new Date(value * 1000)
    windBearing: (value) -> listItem "Wind Bearing", value
    windSpeed: (value) -> listItem "Wind Speed", value

  toRet = """<dl class="dl-horizontal">"""
  for key, value of info.data
    toRet += keyMap[key](value) unless not keyMap[key]?
  toRet += "</dl>"
  toRet

createWeatherPoints = (map, points) ->
  weatherPoints = []
  # Get the distance of the last point (i.e. the total distance of the course)
  [..., {d}] = points
  # Get points every 60,000 meters (~37 miles)
  for i in [0..d] by 60000
    for point in points
      if point.d > i
        weatherPoints.push point
        break

  for point, index in weatherPoints
    infowindow = new google.maps.InfoWindow()
    latLng =
      lat: point.y
      lng: point.x
    marker = new google.maps.Marker
      position: latLng
      map: map
      icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=#{index}|FF0000|000000"
    do (point, marker) ->
      google.maps.event.addListener marker, 'click', ->
        getWeatherForPoint point, (info) ->
          infowindow.setContent makeInfoWindow info
          infowindow.open map, marker


createMap = (res) ->
  {track_points} = res.data

  track_points = _.filter track_points, (tp) -> tp.x?

  coordinates = ({lat: point.y, lng: point.x} for point in track_points)
  # coordinates = _.filter coordinates, (c) -> c.lat?

  map = new google.maps.Map(document.getElementById('map'),
    zoom: 8
    center: coordinates[0]
    mapTypeId: 'terrain'
  )

  routePath = new google.maps.Polyline
    path: coordinates
    geodesic: true
    strokeColor: '#FF0000'
    strokeOpacity: 1.0
    strokeWeight: 5

  routePath.setMap(map)
  createWeatherPoints map, track_points

searchRWGS = (url) ->
  urlSearch = /(trips|routes)\/(\d+)/
  urlMatch = urlSearch.exec url
  if urlMatch.length is 3
    route = if urlMatch[1] is 'trips' then 'trip' else 'route'
    $.ajax
      url: "/rwgs/#{route}/#{urlMatch[2]}",
      success: createMap

window.initMap = ->
  $.ajax
    url: '/rwgs/route/15903786',
    success: createMap

$ ->
  $('#rwgs-search').submit (event) ->
    event.preventDefault()
    searchRWGS document.getElementById("rwgsSearch").value
