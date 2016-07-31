# @codekit-prepend "loader.coffee"

d = React.DOM
ce = React.createElement

StravaMap = React.createFactory React.createClass
  displayName: "StravaMap"
  defaultPublicToken: "pk.eyJ1IjoicmphbWVzODYiLCJhIjoiY2ltam53d2F5MDBzZnY4a2cyaWR4Y3pnMyJ9.SM84_1rqm7WiwAl4uO7RIw"
  propTypes:
    activity: React.PropTypes.object

  decodePolyline: ->
    polyline.decode @props.activity['map'].summary_polyline

  componentDidUpdate: (prevProps, prevState) ->
    if @props.activity.id is prevProps.activity?.id
      return
    else
      @polyline.remove()
      @addLayer()

  addLayer: ->
    @polyline = L.polyline(@decodePolyline(), {color: "red"}).addTo(mymap)
    mymap.fitBounds(@polyline.getBounds())

  componentDidMount: ->
    window.mymap = L.map('map').setView [37.76289, -122.43468], 13
    L.tileLayer("https://api.mapbox.com/styles/v1/mapbox/streets-v9/tiles/256/{z}/{x}/{y}?access_token=#{@defaultPublicToken}", {
      maxZoom: 18,
      accessToken: @defaultPublicToken
    }).addTo(mymap)
    @addLayer()



  render: ->
    if @props.activity
      d.div className: "map-container",
        d.div id: "map", style: { position:"absolute", top: 0, bottom: 0, width: "100%" }
    else
      return LoadingDots thingToLoad: "Map"

