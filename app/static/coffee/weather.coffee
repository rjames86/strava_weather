# @codekit-prepend "loader.coffee"

d = React.DOM
ce = React.createElement

Weather = React.createFactory React.createClass
  displayName: "Weather"
  propTypes:
    activity: React.PropTypes.object

  getInitialState: ->
    loading: false
    weather: null

  degreesToDirection: (deg) ->
    dir = deg - 11.25

    getDirection = ->
      switch dir
        when 0
          return 'NNE'
        when 1
          return 'NE'
        when 2
          return 'ENE'
        when 3
          return 'E'
        when 4
          return 'ESE'
        when 5
          return 'SE'
        when 6
          return 'SSE'
        when 7
          return 'S'
        when 8
          return 'SSW'
        when 9
          return 'SW'
        when 10
          return 'WSW'
        when 11
          return 'W'
        when 12
          return 'WNW'
        when 13
          return 'NW'
        when 14
          return 'NNW'
        when 15
          return 'N'
        else
          return 'unknown'
      return

    if dir < 0
      dir = 360 + dir
    dir = dir / (360 / 16)
    dir = Math.floor(dir)
    dir = getDirection(dir)
    dir

  loadTheWeather: ->
    skycons = new Skycons({color: "#FC4C02"})
    skycons.remove "weather_icon"

    @setState loading: true
    $.ajax
      url: "/strava/activity/#{@props.activity.id}/weather_at_start",
      success: (res) =>
        weather = res.data
        @setState
          loading: false
          weather: weather
        skycons.add "weather_icon", weather.icon
        skycons.play() # start animation!

  componentDidMount: ->
    @loadTheWeather()

  componentDidUpdate: (prevProps, prevState) ->
    if @props.activity.id is prevProps.activity?.id
      return
    else
      @loadTheWeather()

  render: ->
    d.div {},
      if @state.loading
        LoadingDots thingToLoad: "Weather"
      else if not @state.weather
        d.h1 {}, "Weather widget"
      else
        d.div className: "weather-widget__content center",
          d.canvas
            id: "weather_icon"
            width: 128
            height: 128
          , ""
          d.ul className: "weather-widget__description",
            d.li {}, "Temperature: #{@state.weather.temperature}#{String.fromCharCode(0x2109)}"
            d.li {}, "Windspeed: #{@state.weather.windSpeed} #{@degreesToDirection @state.weather.windBearing}"




