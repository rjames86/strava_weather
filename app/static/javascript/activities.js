// Generated by CoffeeScript 1.10.0
(function() {
  var Activities, ce, d;

  d = React.DOM;

  ce = React.createElement;

  Activities = React.createClass({
    render: function() {
      var i;
      return d.div({}, (function() {
        var j, results;
        results = [];
        for (i = j = 1; j <= 10; i = ++j) {
          results.push(d.p({}, i));
        }
        return results;
      })());
    }
  });

}).call(this);