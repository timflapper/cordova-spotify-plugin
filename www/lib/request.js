
var utils = require('./utils')
  , remote = require('./remote')
  , paginate = utils.paginate

function search(options, callback) {
  remote({uri: '/search', data: options}, onRemoteResult);

  function onRemoteResult(err, data) {
    if (err) return callback(err);

    if (data.artists) paginate(data.artists);
    if (data.tracks) paginate(data.tracks);
    if (data.albums) paginate(data.albums);

    callback(null, data);
  }
};

function albums(ids, callback) {
  var matches, uri = '/albums/';

  if (typeof ids === 'string') ids = [ids];

  urisToIds(ids);

  if (ids.length === 1) {
    uri = uri + ids[0];
  } else {
    uri = uri + "?ids=" + ids.join(',');
  }

  remote({uri: uri}, onRemoteResult);

  function onRemoteResult(err, data) {
    if (err) return callback(err);

    if (data.tracks) paginate(data.tracks);
    if (data.albums) {
      data.albums.forEach(function(item) {
        if (item.tracks) paginate(item.tracks);
      });
    }

    callback(null, data);
  }
}

function albumsOfArtist(id, callback) {
  var matches;

  if (matches = /^spotify:artist:(.*)$/.exec(id)) id = matches[1];

  remote({uri: '/artists/' + id + '/albums'}, onRemoteResult);

  function onRemoteResult(err, data) {
    if (err) return callback(err);

    paginate(data);

    callback(null, data);
  }
}

function artists(ids, callback) {
  var matches, uri = '/artists/';

  if (typeof ids === 'string') ids = [ids];

  urisToIds(ids);

  if (ids.length === 1) {
    uri = uri + ids[0];
  } else {
    uri = uri + "?ids=" + ids.join(',');
  }

  remote({uri: uri}, callback);
}

function tracks(ids, callback) {
  var matches, uri ='/tracks/';

  if (typeof ids === 'string') ids = [ids];

  urisToIds(ids);

  if (ids.length === 1) {
    uri = uri + ids[0];
  } else {
    uri = uri + "?ids=" + ids.join(',');
  }

  remote({uri: uri}, callback);
}

function savedTracks(session, callback) {
  remote({uri: '/me/tracks', session: session}, onRemoteResult);

  function onRemoteResult(err, data) {
    if (err) return callback(err);

    paginate(data);
    callback(null, data);
  }
}

function savedTracksContain(session, ids, callback) {
  var matches, url;

  if (typeof ids === 'string') ids = [ids];

  urisToIds(ids);

  remote({
    uri: '/me/tracks/contains?ids=' + ids.join(','),
    session: session
  }, callback);
}

function getProfile(session, callback) {
  remote({
    uri: '/me',
    session: session
  }, callback);
}

function saveTracks(session, ids, callback) {
  var matches;

  if (typeof ids === 'string') ids = [ids];

  urisToIds(ids);

  remote({
    uri: '/me/tracks?ids=' + ids.join(','),
    method: 'put',
    session: session
  }, callback);
}

function removeTracks(session, ids, callback) {
  var matches, url;

  if (typeof ids === 'string') ids = [ids];

  urisToIds(ids);

  remote({
    uri: '/me/tracks?ids=' + ids.join(','),
    method: 'delete',
    session: session
  }, callback);

}

function urisToIds(items) {
  items.forEach(function(id, index) {
    if (matches = /^spotify:[^:]*:(.*)$/.exec(id)) items[index] = matches[1];
  });
}

module.exports = {
  getProfile: getProfile,
  search: search,
  getAlbums: albums,
  getArtists: artists,
  getAlbumsOfArtist: albumsOfArtist,
  getTracks: tracks,
  getSavedTracks: savedTracks,
  getSavedTracksContain: savedTracksContain,
  saveTracks: saveTracks,
  removeTracks: removeTracks
};
