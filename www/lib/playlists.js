
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
      paginate(data);
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
}

playlists.getPlaylist = function(id, session, callback) {
  var url = apiUrl + '/users/' + session.username + '/playlists/' + id;

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
      paginate(data.tracks);
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
};

playlists.createPlaylist = function(name, pub, session, callback) {
  var url = apiUrl + '/users/' + session.username + '/playlists';

  reqwest({
    url: url,
    type: 'json',
    contentType: 'application/json',
    method: 'post',
    crossOrigin: true,
    headers: {
      'Authorization': 'Bearer ' + session.credential
    },
    data: JSON.stringify({ 'name': name, 'public': pub })
  })
    .then(function (data) {
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
};

playlists.addTracksToPlaylist = function(id, uris, session, callback) {
  var url = apiUrl + '/users/' + session.username + '/playlists/'+id+'/tracks';

  reqwest({
    url: url,
    type: 'json',
    contentType: 'application/json',
    method: 'post',
    crossOrigin: true,
    headers: {
      'Authorization': 'Bearer ' + session.credential
    },
    data: JSON.stringify(uris)
  })
    .then(function (data) {
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
};

playlists.removeTracksFromPlaylist = function(id, uris, session, callback) {
  var url = apiUrl + '/users/' + session.username + '/playlists/'+id+'/tracks';

  var tracks = [];

  for (var i = 0; i < uris.length; i++) {
    tracks.push({uri: uris[i]});
  }

  reqwest({
    url: url,
    type: 'json',
    contentType: 'application/json',
    method: 'delete',
    crossOrigin: true,
    headers: {
      'Authorization': 'Bearer ' + session.credential
    },
    data: JSON.stringify({tracks: tracks})
  })
    .then(function (data) {
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
};

playlists.replaceTracksOnPlaylist = function(id, uris, session, callback) {
  var url = apiUrl + '/users/' + session.username + '/playlists/'+id+'/tracks';

  reqwest({
    url: url,
    type: 'json',
    contentType: 'application/json',
    method: 'put',
    crossOrigin: true,
    headers: {
      'Authorization': 'Bearer ' + session.credential
    },
    data: JSON.stringify({uris: uris})
  })
    .then(function (data) {
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
};

playlists.changePlaylistDetails = function(id, name, pub, session, callback) {
  var url = apiUrl + '/users/' + session.username + '/playlists/' + id;

  reqwest({
    url: url,
    type: 'json',
    contentType: 'application/json',
    method: 'put',
    crossOrigin: true,
    headers: {
      'Authorization': 'Bearer ' + session.credential
    },
    data: JSON.stringify({ 'name': name, 'public': pub })
  })
    .then(function (data) {
      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
};
