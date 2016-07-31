# @codekit-prepend "activities.coffee"

d = React.DOM
ce = React.createElement
createClass = React.createFactory React.createClass

Sidebar = React.createFactory React.createClass
  displayName: "Sidebar"
  propTypes:
    onSelectActivity: React.PropTypes.func
    selectedActivity: React.PropTypes.object

  render: ->
    Activities
      onSelectActivity: @props.onSelectActivity
      selectedActivity: @props.selectedActivity
