
var utils = require('./utils')
  , reqwest = utils.reqwest
  , paginate = utils.paginate
  , apiUrl = utils.apiUrl;

function search(options, callback) {
  var url = apiUrl + '/search';

  if (arguments.length < 2) throw new Error('Expected 2 parameters, Received ' + String(arguments.length) + '.');
  if (typeof callback !== 'function') throw new Error('Second argument must be a function.');

  reqwest({
    url: url,
    type: 'json',
    method: 'get',
    data: options,
    crossOrigin: true
  })
    .then(function (data) {
      if (data.artists) paginate(data.artists);
      if (data.tracks) paginate(data.tracks);
      if (data.albums) paginate(data.albums);

      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
};

function albums(ids, callback) {
  var matches, url;

  if (arguments.length < 2) throw new Error('Expected 2 parameters, Received ' + String(arguments.length) + '.');
  if (typeof callback !== 'function') throw new Error('Second argument must be a function.');
  if (typeof ids !== 'string' && !Array.isArray(ids)) throw new Error('First argument must be a string or an array.');

  if (typeof ids === 'string') ids = [ids];

  ids.forEach(function(id, index) {
    if (matches = /^spotify:album:(.*)$/.exec(id)) ids[index] = matches[1];
  });

  url = apiUrl + '/albums/';

  if (ids.length === 1) {
    url = url + ids[0];
  } else {
    url = url + "?ids=" + ids.join(',');
  }
  reqwest({
    url: url,
    type: 'json',
    method: 'get',
    crossOrigin: true
  })
    .then(function (data) {
      if (data.tracks) paginate(data.tracks);
      if (data.albums) {
        data.albums.forEach(function(item) {
          if (item.tracks) paginate(item.tracks);
        });
      }

      callback(null, data);
    })
    .fail(function (err, msg) {
      if (err) return callback(err.statusText);
      if (msg) return callback(msg);
      callback("An unkown error occurred");
    });
}

function albumsOfArtist(id, callback) {
  var matches, url;

  if (arguments.length < 2) throw new Error('Expected 2 parameters, Received ' + String(arguments.length) + '.');
  if (typeof callback !== 'function') throw new Error('Second argument must be a function.');
  if (typeof id !== 'string') throw new Error('First argument must be a string.');

  if (matches = /^spotify:artist:(.*)$/.exec(id)) id = matches[1];

  url = apiUrl + '/artists/' + id + '/albums';

  reqwest({
    url: url,
    type: 'json',
    method: 'get',
    crossOrigin: true
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

function artists(ids, callback) {
  var matches, url;

  if (arguments.length < 2) throw new Error('Expected 2 parameters, Received ' + String(arguments.length) + '.');
  if (typeof callback !== 'function') throw new Error('Second argument must be a function.');
  if (typeof ids !== 'string' && !Array.isArray(ids)) throw new Error('First argument must be a string or an array.');

  if (typeof ids === 'string') ids = [ids];

  ids.forEach(function(id, index) {
    if (matches = /^spotify:artist:(.*)$/.exec(id)) ids[index] = matches[1];
  });

  url = apiUrl + '/artists/';

  if (ids.length === 1) {
    url = url + ids[0];
  } else {
    url = url + "?ids=" + ids.join(',');
  }

  reqwest({
    url: url,
    type: 'json',
    method: 'get',
    crossOrigin: true
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

function tracks(ids, callback) {
  var matches, url;

  if (arguments.length < 2) throw new Error('Expected 2 parameters, Received ' + String(arguments.length) + '.');
  if (typeof callback !== 'function') throw new Error('Second argument must be a function.');
  if (typeof ids !== 'string' && !Array.isArray(ids)) throw new Error('First argument must be a string or an array.');

  if (typeof ids === 'string') ids = [ids];

  ids.forEach(function(id, index) {
    if (matches = /^spotify:track:(.*)$/.exec(id)) ids[index] = matches[1];
  });

  url = apiUrl + '/tracks/';

  if (ids.length === 1) {
    url = url + ids[0];
  } else {
    url = url + "?ids=" + ids.join(',');
  }

  reqwest({
    url: url,
    type: 'json',
    method: 'get',
    crossOrigin: true
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

module.exports = {
  search: search,
  meta: {
    albums: albums,
    artists: artists,
    albumsOfArtist: albumsOfArtist,
    tracks: tracks
  }
};
