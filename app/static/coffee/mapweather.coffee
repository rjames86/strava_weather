savedPoints = {}
UNITS =
  MILES: 1
  KM: 2

d = React.DOM

Map = React.createFactory React.createClass
  savedPoints: {}

  componentDidUpdate: (prevProps, prevState) ->
    if prevProps.rwgsData.id is @props.rwgsData.id
      return
    @createMap()
  componentDidMount: ->
    @createMap()

  unitsHuman: ->
    unitString = _.findKey UNITS, (value, key) => @props.unit is value
    if unitString then unitString.toLowerCase() else ''

  unitsSwitch: (whenMiles, whenKM) ->
    miles = if _.isFunction whenMiles then whenMiles() else whenMiles
    km = if _.isFunction km then whenKM() else whenKM
    switch @props.unit
      when UNITS.MILES then miles
      when UNITS.KM then km

  speed: ->
    @unitsSwitch @props.speed, @props.speed * 1000

  pointDistance: (point) ->
    @unitsSwitch (point.d / 1609.344), point.d

  humanDistance: (point) ->
    distance = @pointDistance point
    @unitsSwitch distance, distance / 1000

  calculateTimeFromStart: (point) ->
    time = (@pointDistance(point) / @speed()) * 60 * 60 # <unit> per second
    @props.startTime + time

  getWeatherForPoint: (point, callback) ->
    console.log @savedPoints
    if @savedPoints["#{point.y},#{point.x},#{@speed()}"]
      return callback @savedPoints["#{point.y},#{point.x},#{@speed()}"]
    $.ajax
      async: false
      url: "/weather/#{point.y}/#{point.x}/#{@calculateTimeFromStart point}",
      success: (res) =>
        @savedPoints["#{point.y},#{point.x},#{@speed()}"] = res
        return callback res
      error: -> return callback {}

  makeInfoWindow: (point, info) ->
    listItem = (i, j) -> "<dt>#{i}</dt><dd>#{j}</dd>"
    keyMap =
      apparentTemperature: (value) -> listItem 'Feels Like', value
      humidity: (value) -> listItem 'Humidity', value
      # icon: (value) -> null
      precipProbability: (value) -> listItem 'Precipitation Probability', value
      summary: (value) -> listItem 'Summary', value
      temperature: (value) -> listItem 'Temperature', value
      time: (value) -> listItem 'Estimated Arrival Time', new Date(value * 1000)
      windBearing: (value) -> listItem 'Wind Bearing', value
      windSpeed: (value) -> listItem 'Wind Speed', value

    toRet = "<dl class='dl-horizontal'>"
    for key, value of info.data
      toRet += keyMap[key](value) unless not keyMap[key]?
    duration = (@calculateTimeFromStart(point) - @props.startTime) / 60 / 60
    toRet += listItem 'Estimated Duration', "#{duration.toFixed(2)} hours"
    toRet += listItem 'Current Distance', "#{@humanDistance(point).toFixed(2)} #{@unitsHuman()}"

    toRet += '</dl>'
    toRet

  createWeatherPoints: (map, points) ->
    weatherPoints = []
    # Get the distance of the last point (i.e. the total distance of the course)
    [..., lastPoint] = points
    # Get points every 60,000 meters (~37 miles)
    for i in [0..lastPoint.d] by 60000
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
      do (point, marker) =>
        google.maps.event.addListener marker, 'click', =>
          @getWeatherForPoint point, (info) =>
            infowindow.setContent @makeInfoWindow point, info
            infowindow.open map, marker

  createMap: ->
    if _.isEmpty @props.rwgsData
      return
    {track_points} = @props.rwgsData

    track_points = _.filter track_points, (tp) -> tp.x?

    coordinates = ({lat: point.y, lng: point.x} for point in track_points)

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

    console.log 'attempting to set map' , routePath

    routePath.setMap(map)
    @createWeatherPoints map, track_points


  render: ->
    if _.isEmpty @props.rwgsData
      return (
        d.div
          className: "jumbotron"
          ,
            d.p null, "Search for a route on RideWithGPS on the left"
      )
    else
      d.div
        id: "map"

UnitsOption = React.createFactory React.createClass
  render: ->
    d.div null,
      d.label
        className: 'radio-inline',
        d.input
          value: UNITS.MILES
          type: 'radio'
          name: 'units'
          onChange: => @props.onUnitChange UNITS.MILES
          defaultChecked: @props.currentUnit is UNITS.MILES
        "Imperial"
      d.label
        className: 'radio-inline',
        d.input
          type: 'radio'
          name: 'units'
          value: UNITS.KM
          onChange: => @props.onUnitChange UNITS.KM
          defaultChecked: @props.currentUnit is UNITS.KM
        "Metric"

Form = React.createFactory React.createClass
  getInitialState: ->
    searchLink: ''

  searchRWGS: (e) ->
    e.preventDefault()
    console.log 'searching...', @state
    urlSearch = /(trips|routes)\/(\d+)/
    urlMatch = urlSearch.exec @state.searchLink
    console.log 'theurlmatch', urlMatch
    if urlMatch.length is 3
      route = if urlMatch[1] is 'trips' then 'trip' else 'route'
      console.log 'route is', route
      $.ajax
        url: "/rwgs/#{route}/#{urlMatch[2]}",
        success: @props.onSearchSuccess

  formStyles: ->
    padding: "15px 0 0 15px"

  render: ->
    d.form
      className: 'input-group'
      id: 'rwgs-search'
      style: @formStyles()
      ,
        d.input
          type: 'text'
          className: 'form-control'
          id: 'rwgsSearch'
          onChange: (e) => @setState searchLink: e.target.value
          placeholder: 'RWGS Link'
        d.button
          type: 'submit'
          className: 'btn btn-default'
          onClick: @searchRWGS
          , 'Submit'
        d.div
          className: 'input-group'
          ,
          d.input
            type: 'number'
            className: 'form-control'
            id: 'rwgsSpeed'
            placeholder: 'RWGS Speed'
            value: @props.speed
            onChange: @props.onSpeedChange
          d.span
            className: 'input-group-addon'
            , 'Estimated Speed'
        UnitsOption
          onUnitChange: @props.onUnitChange
          currentUnit: @props.currentUnit
        d.div
          className: 'input-group date'
          id: 'datetimepicker'
          ,
            d.input
              type: 'text'
              className: 'form-control'
            d.span
              className: 'input-group-addon'
              ,
                d.span
                  className: 'glyphicon glyphicon-calendar'

RouteInfo = React.createFactory React.createClass
  displayName: "RouteInfo"

  # TODO(ryan) DRY
  unitsSwitch: (whenMiles, whenKM) ->
    miles = if _.isFunction whenMiles then whenMiles() else whenMiles
    km = if _.isFunction km then whenKM() else whenKM
    switch @props.unit
      when UNITS.MILES then miles
      when UNITS.KM then km

  # TODO(ryan) DRY
  unitsHuman: ->
    unitString = _.findKey UNITS, (value, key) => @props.unit is value
    if unitString then unitString.toLowerCase() else ''

  unitsHeight: ->
    @unitsSwitch "ft", "m"

  # TODO(ryan) DRY
  humanDistance: (distance) ->
    @unitsSwitch (distance / 1609.344).toFixed(2), (distance / 1000).toFixed(2)

  humanElevation: (elev) ->
    @unitsSwitch (elev / .3048).toFixed(2), elev

  listItem: (val, key) ->
    keyMap =
      name:
        humanName: "Name"
      description:
        humanName: "Description"
      distance:
        humanName: "Distance"
        value: (v) => "#{@humanDistance(val)} #{@unitsHuman()}"
      elevation_gain:
        humanName: "Elevation Gain"
        value: (v) => "#{@humanElevation(val)} #{@unitsHeight()}"
    [
      d.dt(null, keyMap[key]?.humanName),
      d.dd(null, if keyMap[key]?.value? then keyMap[key].value(val) else val)
    ]

  render: ->
    data = _.pick @props.rwgsData, ['name', 'description', 'distance', 'elevation_gain']
    d.div {},
      d.dl
        className: 'dl-horizontal'
      ,
      if not _.isEmpty data
        (@listItem val, key for key, val of data)
      else
        d.div()

InfoAboutSite = React.createFactory React.createClass
  messageText: ->
    [
      "Welcome! This is still in beta, so everything may not work. If you're here, I assume you know how to contact me. Please let me know if something breaks."
      "Everything you see should be hooked up."
      "- RideWithGPS routes and trips are supported right now."
      "- Search may be slow. If you hit submit, it's searching. I don't have a loader indicator yet"
      "- If you change the date, speed or units, you'll have to click on the point again to get updated info"
    ]

  render: ->
    d.div
      className: "well"
      ,
        (d.p {key: index}, t for t, index in @messageText())

Footer = React.createFactory React.createClass
  render: ->
    d.footer
      className: 'footer'
      ,
      d.div
        className: 'container'
        ,
        d.p
          className: 'text-muted'
          ,
          d.a {href: 'https://darksky.net/poweredby/'}, 'Weather powered by Dark Sky'

Main = React.createFactory React.createClass
  displayName: 'Main'

  getInitialState: ->
    unit: UNITS.MILES
    speed: 15
    rwgsData: {}
    date: +moment()

  componentDidMount: ->
    # http://eonasdan.github.io/bootstrap-datetimepicker/
    $('#datetimepicker').datetimepicker(
      defaultDate: +moment()
    )
    $('#datetimepicker').on "dp.change", @onDateChange

  componentDidUpdate: ->
    console.log 'units now', @state.unit
    console.log 'speed now', @state.speed
    console.log 'date now', @state.date

  onUnitChange: (u) -> @setState unit: u
  onSpeedChange: (e) -> @setState speed: parseInt e.target.value
  onDateChange: (e) -> @setState date: e.date
  onSearchSuccess: (res) -> @setState rwgsData: res.data

  date: ->
    +@state.date / 1000

  sidebarStyle: ->
    border: "1px solid #eeeeee"
    height: "100%"

  render: ->
    d.div
      className: 'container-fluid'
      ,
      d.div
        className: 'row'
        style:
          height: '100%'
        ,
          d.div
            className: 'col-md-3 col-sm-3'
            style: @sidebarStyle()
          ,
            Form
              onUnitChange: @onUnitChange
              currentUnit: @state.unit
              onSearchSuccess: @onSearchSuccess
              onSpeedChange: @onSpeedChange
              speed: @state.speed
            RouteInfo
              rwgsData: @state.rwgsData
              unit: @state.unit
            InfoAboutSite()
            Footer()
          d.div
            className: 'col-md-9 col-sm-9'
            style:
              height: "100%"
          ,
            Map
              rwgsData: @state.rwgsData
              unit: @state.unit
              speed: @state.speed
              startTime: @date()

$ ->
  window.initMap = ->
    react_content = document.getElementById('react-content')
    ReactDOM.render React.createElement(Main, null, null), react_content
