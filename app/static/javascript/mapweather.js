// Generated by CoffeeScript 1.10.0
(function() {
  var Form, Main, Map, UNITS, UnitsOption, d, savedPoints;

  savedPoints = {};

  UNITS = {
    MILES: 1,
    KM: 2
  };

  d = React.DOM;

  Map = React.createFactory(React.createClass({
    savedPoints: {},
    componentDidUpdate: function(prevProps, prevState) {
      if (prevProps.rwgsData.id === this.props.rwgsData.id) {
        return;
      }
      return this.createMap();
    },
    componentDidMount: function() {
      return this.createMap();
    },
    startTime: function() {
      return parseInt(+new Date('12/24/2016 13:37') / 1000);
    },
    speed: function() {
      switch (this.props.unit) {
        case UNITS.MILES:
          return this.props.speed;
        case UNITS.KM:
          return this.props.speed * 1000;
      }
    },
    pointDistance: function(point) {
      switch (this.props.unit) {
        case UNITS.MILES:
          return point.d / 1609.344;
        case UNITS.KM:
          return point.d;
      }
    },
    calculateTimeFromStart: function(point) {
      var time;
      console.log("we assume distance " + (this.pointDistance(point)) + " at " + (this.speed()));
      time = (this.pointDistance(point) / this.speed()) * 60 * 60;
      return this.startTime() + time;
    },
    getWeatherForPoint: function(point, callback) {
      console.log(this.savedPoints);
      if (this.savedPoints[point.y + "," + point.x + "," + (this.speed())]) {
        return callback(this.savedPoints[point.y + "," + point.x + "," + (this.speed())]);
      }
      return $.ajax({
        async: false,
        url: "/weather/" + point.y + "/" + point.x + "/" + (this.calculateTimeFromStart(point)),
        success: (function(_this) {
          return function(res) {
            _this.savedPoints[point.y + "," + point.x + "," + (_this.speed())] = res;
            return callback(res);
          };
        })(this),
        error: function() {
          return callback({});
        }
      });
    },
    makeInfoWindow: function(point, info) {
      var duration, key, keyMap, listItem, ref, toRet, value;
      listItem = function(i, j) {
        return "<dt>" + i + "</dt><dd>" + j + "</dd>";
      };
      keyMap = {
        apparentTemperature: function(value) {
          return listItem('Feels Like', value);
        },
        humidity: function(value) {
          return listItem('Humidity', value);
        },
        precipProbability: function(value) {
          return listItem('Precipitation Probability', value);
        },
        summary: function(value) {
          return listItem('Summary', value);
        },
        temperature: function(value) {
          return listItem('Temperature', value);
        },
        time: function(value) {
          return listItem('Estimated Arrival Time', new Date(value * 1000));
        },
        windBearing: function(value) {
          return listItem('Wind Bearing', value);
        },
        windSpeed: function(value) {
          return listItem('Wind Speed', value);
        }
      };
      toRet = "<dl class='dl-horizontal'>";
      ref = info.data;
      for (key in ref) {
        value = ref[key];
        if (!(keyMap[key] == null)) {
          toRet += keyMap[key](value);
        }
      }
      duration = (this.calculateTimeFromStart(point) - this.startTime()) / 60 / 60;
      toRet += listItem('Estimated Duration', (duration.toFixed(2)) + " hours");
      toRet += '</dl>';
      return toRet;
    },
    createWeatherPoints: function(map, points) {
      var i, index, infowindow, k, l, lastPoint, latLng, len, len1, m, marker, point, ref, results, weatherPoints;
      weatherPoints = [];
      lastPoint = points[points.length - 1];
      for (i = k = 0, ref = lastPoint.d; k <= ref; i = k += 60000) {
        for (l = 0, len = points.length; l < len; l++) {
          point = points[l];
          if (point.d > i) {
            weatherPoints.push(point);
            break;
          }
        }
      }
      results = [];
      for (index = m = 0, len1 = weatherPoints.length; m < len1; index = ++m) {
        point = weatherPoints[index];
        infowindow = new google.maps.InfoWindow();
        latLng = {
          lat: point.y,
          lng: point.x
        };
        marker = new google.maps.Marker({
          position: latLng,
          map: map,
          icon: "http://chart.apis.google.com/chart?chst=d_map_pin_letter&chld=" + index + "|FF0000|000000"
        });
        results.push((function(_this) {
          return function(point, marker) {
            return google.maps.event.addListener(marker, 'click', function() {
              return _this.getWeatherForPoint(point, function(info) {
                infowindow.setContent(_this.makeInfoWindow(point, info));
                return infowindow.open(map, marker);
              });
            });
          };
        })(this)(point, marker));
      }
      return results;
    },
    createMap: function() {
      var coordinates, map, point, routePath, track_points;
      console.log("weather data", this.props.rwgsData, _.isEmpty(this.props.rwgsData));
      if (_.isEmpty(this.props.rwgsData)) {
        return;
      }
      track_points = this.props.rwgsData.track_points;
      track_points = _.filter(track_points, function(tp) {
        return tp.x != null;
      });
      coordinates = (function() {
        var k, len, results;
        results = [];
        for (k = 0, len = track_points.length; k < len; k++) {
          point = track_points[k];
          results.push({
            lat: point.y,
            lng: point.x
          });
        }
        return results;
      })();
      map = new google.maps.Map(document.getElementById('map'), {
        zoom: 8,
        center: coordinates[0],
        mapTypeId: 'terrain'
      });
      routePath = new google.maps.Polyline({
        path: coordinates,
        geodesic: true,
        strokeColor: '#FF0000',
        strokeOpacity: 1.0,
        strokeWeight: 5
      });
      console.log('attempting to set map', routePath);
      routePath.setMap(map);
      return this.createWeatherPoints(map, track_points);
    },
    render: function() {
      if (_.isEmpty(this.props.rwgsData)) {
        return d.div({
          className: "jumbotron"
        }, d.p(null, "Search for a route on RideWithGPS on the left"));
      } else {
        return d.div({
          id: "map"
        });
      }
    }
  }));

  UnitsOption = React.createFactory(React.createClass({
    render: function() {
      return d.div(null, d.label({
        className: 'radio-inline'
      }, d.input({
        value: UNITS.MILES,
        type: 'radio',
        name: 'units',
        onChange: (function(_this) {
          return function() {
            return _this.props.onUnitChange(UNITS.MILES);
          };
        })(this),
        defaultChecked: this.props.currentUnit === UNITS.MILES
      }), "Miles"), d.label({
        className: 'radio-inline'
      }, d.input({
        type: 'radio',
        name: 'units',
        value: UNITS.KM,
        onChange: (function(_this) {
          return function() {
            return _this.props.onUnitChange(UNITS.KM);
          };
        })(this),
        defaultChecked: this.props.currentUnit === UNITS.KM
      }), "KM"));
    }
  }));

  Form = React.createFactory(React.createClass({
    getInitialState: function() {
      return {
        searchLink: ''
      };
    },
    searchRWGS: function(e) {
      var route, urlMatch, urlSearch;
      e.preventDefault();
      console.log('searching...', this.state);
      urlSearch = /(trips|routes)\/(\d+)/;
      urlMatch = urlSearch.exec(this.state.searchLink);
      console.log('theurlmatch', urlMatch);
      if (urlMatch.length === 3) {
        route = urlMatch[1] === 'trips' ? 'trip' : 'route';
        console.log('route is', route);
        return $.ajax({
          url: "/rwgs/" + route + "/" + urlMatch[2],
          success: this.props.onSearchSuccess
        });
      }
    },
    render: function() {
      return d.form({
        className: 'input-group',
        id: 'rwgs-search'
      }, d.input({
        type: 'text',
        className: 'form-control',
        id: 'rwgsSearch',
        onChange: (function(_this) {
          return function(e) {
            return _this.setState({
              searchLink: e.target.value
            });
          };
        })(this),
        placeholder: 'RWGS Link'
      }), d.button({
        type: 'submit',
        className: 'btn btn-default',
        onClick: this.searchRWGS
      }, 'Submit'), d.input({
        type: 'number',
        className: 'form-control',
        id: 'rwgsSpeed',
        placeholder: 'RWGS Speed',
        value: this.props.speed,
        onChange: this.props.onSpeedChange
      }), UnitsOption({
        onUnitChange: this.props.onUnitChange,
        currentUnit: this.props.currentUnit
      }));
    }
  }));

  Main = React.createFactory(React.createClass({
    displayName: 'Main',
    getInitialState: function() {
      return {
        unit: UNITS.MILES,
        speed: 15,
        rwgsData: {}
      };
    },
    componentDidUpdate: function() {
      console.log('units now', this.state.unit);
      return console.log('speed now', this.state.speed);
    },
    onUnitChange: function(u) {
      return this.setState({
        unit: u
      });
    },
    onSpeedChange: function(e) {
      return this.setState({
        speed: parseInt(e.target.value)
      });
    },
    onSearchSuccess: function(res) {
      return this.setState({
        rwgsData: res.data
      });
    },
    render: function() {
      return d.div({
        className: 'container-fluid'
      }, d.div({
        className: 'row',
        style: {
          height: '100%'
        }
      }, d.div({
        className: 'col-md-2 col-sm-2'
      }, Form({
        onUnitChange: this.onUnitChange,
        currentUnit: this.state.unit,
        onSearchSuccess: this.onSearchSuccess,
        onSpeedChange: this.onSpeedChange,
        speed: this.state.speed
      })), d.div({
        className: 'col-md-10 col-sm-10',
        style: {
          height: "100%"
        }
      }, Map({
        rwgsData: this.state.rwgsData,
        unit: this.state.unit,
        speed: this.state.speed
      }))));
    }
  }));

  $(function() {
    return window.initMap = function() {
      var react_content;
      react_content = document.getElementById('react-content');
      return ReactDOM.render(React.createElement(Main, null, null), react_content);
    };
  });

}).call(this);
