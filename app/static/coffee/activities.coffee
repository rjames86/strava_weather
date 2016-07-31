# @codekit-prepend "loader.coffee"

d = React.DOM
ce = React.createElement
createClass = React.createFactory React.createClass

Activity = React.createFactory React.createClass
  displayName: "Activity"
  propTypes:
    activity: React.PropTypes.object
    onSelectActivity: React.PropTypes.func
    selectedActivity: React.PropTypes.object

  metersToMiles: (distance) ->
    miles = distance / 1609.344
    return Math.round(miles * 100) / 100

  isoToDate: (ts) ->
    date = new Date Date.parse(ts)
    return "#{date.getFullYear()}-#{date.getMonth() + 1}-#{date.getDate()}"

  selectActivity: (activity) ->
    # We want the full activity information
    $.ajax
      url: "/strava/activity/#{activity.id}",
      success: (res) =>
        @props.onSelectActivity res.data

  render: ->
    activeClass = if @props.activity.id is @props.selectedActivity?.id then "active" else ""
    d.div className: "list-group",
      d.a
        className: "list-group-item #{activeClass}",
        onClick: => @selectActivity @props.activity
      ,
        d.h4 className: "list-group-item-heading", @props.activity.name
        d.p className: "list-group-item-text", "Start: #{@isoToDate @props.activity.start_date}"
        d.p className: "list-group-item-text", "Type: #{@props.activity.type}"
        d.p className: "list-group-item-text", "Distance: #{@metersToMiles @props.activity.distance} miles"

Activities = React.createFactory React.createClass
  displayName: "Activities"
  getInitialState: ->
    data: null

  componentDidMount: ->
    $.ajax
      url: "/strava/activities",
      success: (res) =>
        @setState data: res.data

  componentDidUpdate: ->
    $('.activities').css({ height: $(window).innerHeight() })

  render: ->
    if not @state.data
      return LoadingDots thingToLoad: "Activities"
    d.div className: "activities",
      (Activity
        activity: activity,
        key: activity.id,
        onSelectActivity: @props.onSelectActivity
        selectedActivity: @props.selectedActivity
      ) for activity in @state.data

