
var utils = require('./utils')
  , reqwest = require('./vendors/reqwest');

var apiUrl = 'https://api.spotify.com/v1';

function remote(options, callback) {
  var req = {
    type: 'json',
    contentType: 'application/json',
    method: options.method || 'get',
    crossOrigin: true,
    headers: {}
  };

  if (options.uri) {
    req.url = apiUrl + options.uri;
  } else if (options.url) {
    req.url = options.url;
  } else {
    return callback('No URL or URI set');
  }

  if (options.session)
    req.headers.Authorization = 'Bearer ' + options.session.credential;

  if (options.data)
    req.data = options.data;

  reqwest(req)
    .then(function (data) {
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
}

module.exports = remote;
