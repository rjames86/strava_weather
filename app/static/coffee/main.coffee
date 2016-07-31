# @codekit-prepend "maincontent.coffee"
# @codekit-prepend "sidebar.coffee"

d = React.DOM
ce = React.createElement

Main = React.createClass
  displayName: "Main"
  getInitialState: ->
    activity: null

  onSelectActivity: (activity) ->
    @setState activity: activity

  render: ->
    d.div
      className: "row"
    ,
      d.div
        className: "col-md-2 col-sm-2"
      ,
        Sidebar
          onSelectActivity: @onSelectActivity
          selectedActivity: @state.activity
      d.div
        className: "col-md-10 col-sm-10"
      ,
        MainContent
          selectedActivity: @state.activity


$ ->
  react_content = document.getElementById('react-content')
  ReactDOM.render(ce(Main, null, null), react_content)
