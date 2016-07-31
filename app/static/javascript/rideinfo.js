// Generated by CoffeeScript 1.10.0
(function() {
  var RideInfo, ce, d;

  d = React.DOM;

  ce = React.createElement;

  RideInfo = React.createClass({
    propTypes: {
      activity: React.PropTypes.object
    },
    metersToMiles: function(distance) {
      var miles;
      miles = distance / 1609.344;
      return Math.round(miles * 100) / 100;
    },
    metersToFeet: function(distance) {
      return this.metersToMiles(distance) * 5280;
    },
    secondsToHours: function(seconds) {
      return seconds / 60 / 60;
    },
    kilometersToMiles: function(distance) {
      var miles;
      miles = distance * 0.62137;
      return Math.round(miles * 100) / 100;
    },
    render: function() {
      return d.ul({}, d.li({}, this.metersToMiles(this.props.activity.distance)), d.li({}, this.secondsToHours(this.props.activity.elapsed_time)), d.li({}, this.metersToFeet(this.props.activity.total_elevation_gain)), d.li({}, this.kilometersToMiles(this.props.activity.max_speed)));
    }
  });

}).call(this);
