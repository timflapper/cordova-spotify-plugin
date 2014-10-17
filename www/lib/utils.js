
var exec = require('cordova/exec')
  , reqwest = require('./vendors/reqwest');

var noop = function() {};

var utils = {
  apiUrl: 'https://api.spotify.com/v1',
  exec: function(/*action, [params], [callback]*/) {
    var action, args = [], callback = noop;
    var i, argsLength = arguments.length;

    if (arguments.length === 0) throw new Error('No arguments received 1 or more expected.');
    action = arguments[0];

    for (i=1;i < argsLength;i++) args[i] = arguments[i];

    if (args.length > 0 && typeof args.slice(-1)[0] === 'function') {
      callback = args.splice(-1, 1)[0];
    }

    function onSuccess(result) { callback(null, result); }
    function onError(error) { callback(error); }

    exec(onSuccess, onError, 'SpotifyPlugin', action, args);
  },
  paginate: function(data) {
    var nextUrl = data.next
      , prevUrl = data.prev;

    if (nextUrl) {
      data.next = function(callback) {
        reqwest({
          url: nextUrl,
          type: 'json',
          method: 'get',
          crossOrigin: true
        })
          .then(function (data) {
            utils.paginate(data);

            callback(null, data);
          })
          .fail(function (err, msg) {
            if (err) return callback(err.statusText);
            if (msg) return callback(msg);
            callback("An unkown error occurred");
          });
      }
    }

    if (prevUrl) {
      data.prev = function(callback) {
        reqwest({
          url: prevUrl,
          type: 'json',
          method: 'get',
          crossOrigin: true
        })
          .then(function (data) {
            utils.paginate(data);

            callback(null, data);
          })
          .fail(function (err, msg) {
            if (err) return callback(err.statusText);
            if (msg) return callback(msg);
            callback("An unkown error occurred");
          });
      }
    }
  },

  noop: noop,
  reqwest: reqwest
};
module.exports = utils;
