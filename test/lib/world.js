'use strict';

var spotify = exports.spotify = require('../../www/spotify');

exports.session = spotify.Session({
  username: 'testuser',
  credential: 's0m3th1ngR4nd0mL1k3'
});
