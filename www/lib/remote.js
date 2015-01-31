var reqwest = require('./vendors/reqwest');

var apiUrl = 'https://api.spotify.com/v1';

module.exports = remote;

function remote(options, callback) {
  if (options === undefined)
    throw new Error('This method requires two arguments (options, callback)');

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
    req.headers.Authorization = 'Bearer ' + options.session.accessToken;

  if (options.data)
    req.data = options.data;

  reqwest(req)
    .then(function (data) {
      paginate(data, session);

      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
}

function paginate(data, session) {
  if (Array.isArray(data)) {
    data.forEach(function(item) {
      paginate(item, session);
    });

    return;
  }

  if (data.next) {
    var nextOpts = {url: data.next};

    if (session)
      nextOpts.session = session;

    data.next = function(callback) {
      remote(nextOpts, onRemoteResult);

      function onRemoteResult(err, data) {
        if (err) return callback(err);

        paginate(data, session);

        callback(null, data);
      }
    }
  }

  if (data.prev) {
    var prevOpts = {url: data.prev};

    if (session)
      prevOpts.session = session;

    data.prev = function(callback) {
      remote(prevOpts, onRemoteResult);

      function onRemoteResult(err, data) {
        if (err) return callback(err);

        paginate(data, session);

        callback(null, data);
      }
    }
  }

  if (data.artists) paginate(data.artists, session);
  if (data.tracks) paginate(data.tracks, session);
  if (data.albums) paginate(data.albums, session);
}
