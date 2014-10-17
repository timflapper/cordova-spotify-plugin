
var utils = require('./utils')
  , reqwest = utils.reqwest
  , apiUrl = utils.apiUrl;

var playlists = exports;

playlists.getPlaylists = function(session, callback) {
  var url = apiUrl + '/users/' + session.username + '/playlists';

  if (arguments.length < 2)
    throw new Error('Not enough parameters. Expected: 2, Received: ' + String(arguments.length) + '.');

  if (typeof callback !== 'function')
    throw new Error('Second argument should be a callback function.');

  reqwest({
    url: url,
    type: 'json',
    method: 'get',
    crossOrigin: true,
    headers: {
      'Authorization': 'Bearer ' + session.credential
    }
  })
    .then(function (data) {
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
}
