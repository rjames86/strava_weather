LoadingDots = React.createFactory React.createClass
  displayName: "LoadingDots"
  propTypes:
    thingToLoad: React.PropTypes.string
  render: ->
    d.h1
      className: "loader center"
    ,
      "Loading #{@props.thingToLoad}"
      d.span {}, "."
      d.span {}, "."
      d.span {}, "."
