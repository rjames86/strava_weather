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

  speed: ->
    switch @props.unit
      when UNITS.MILES then @props.speed # miles per hour
      when UNITS.KM then @props.speed * 1000 # meters per hour

  pointDistance: (point) ->
    switch @props.unit
      when UNITS.MILES then point.d / 1609.344 # meters -> miles
      when UNITS.KM then point.d

  calculateTimeFromStart: (point) ->
    console.log "we assume distance #{@pointDistance(point)} at #{@speed()}"
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
    unitString = _.findKey UNITS, (value, key) => @props.unit is value
    humanDistance = @pointDistance(point)
    if @props.unit is UNITS.KM
      humanDistance = humanDistance / 1000
    toRet += listItem 'Current Distance', "#{humanDistance.toFixed(2)} #{unitString.toLowerCase()}"

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
        "Miles"
      d.label
        className: 'radio-inline',
        d.input
          type: 'radio'
          name: 'units'
          value: UNITS.KM
          onChange: => @props.onUnitChange UNITS.KM
          defaultChecked: @props.currentUnit is UNITS.KM
        "KM"

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
        d.input
          type: 'number'
          className: 'form-control'
          id: 'rwgsSpeed'
          placeholder: 'RWGS Speed'
          value: @props.speed
          onChange: @props.onSpeedChange
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
