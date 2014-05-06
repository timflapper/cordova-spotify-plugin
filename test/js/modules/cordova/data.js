var SPImage = require('../../../../www/lib/image');

var albums = {}
  , artists = {}
  , tracks = {}
  , playlists = {};

var albumCovers = [{
  large: new SPImage({
    height: 640,
    width: 640,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/8782b58f895d68dc2fa1fd987a2fa1699b765984'
  }),
  medium: new SPImage({
    height: 300, 
    width: 300,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/59acdf741304f2643168f80a80935b83f0a1ef28'
  }),
  small: new SPImage({
    height: 64,
    width: 64,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/a13e23f485ccf67a91d9b207276ff067c60581a9'
  })
}];

var artistImages = [{
  small: new SPImage({
    width: 64,
    height: 52,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/e095f9cd4b4c7354cbac5833bb87ed8a1ef6c601'
  }),
  medium: new SPImage({
    width: 200,
    height: 163,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/34f314e1fc688a385377db7ee4c95bbaed3b6736'
  }),
  large: new SPImage({
    width: 640,
    height: 521,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/fa6c1901c9b71493bfd3f792d46af2505d45685b'
  }),
  xlarge: new SPImage({
    width: 1000,
    height: 814,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/17bc1410db1c5d6abee55f2e270bcd104cc56c2f'
  })
}];

albums['spotify:album:4FtOLTQqwnxpaABrJWYdBy'] = {
    name: 'Rockin\' The Suburbs',
    uri: 'spotify:album:4FtOLTQqwnxpaABrJWYdBy',
    sharingURL: 'http://open.spotify.com/album/4FtOLTQqwnxpaABrJWYdBy',
    externalIds: {
      upc: '074646161029'
    },
    availableTerritories: ['AD', 'AR', 'AT', 'NL'],
    artists: [{
      uri: 'spotify:artist:55tif8708yyDQlSjh3Trdu',
      name: 'Ben Folds'
    }],
    tracks: [
      {uri: 'spotify:track:2hDQU47XuGq9CdYRIQD1m6', name: 'Annie Waits'},
      {uri: 'spotify:track:5djxeOKKsF7BhHvz7iFOjw', name: 'Zak And Sara'},
      {uri: 'spotify:track:0f9fM6DdpJM79NQ1XbHcjJ', name: 'Still Fighting It'}
    ],
    releaseDate: {
      year: 2001,
      month: 9,
      day: 11
    },
    type: 'album',
    genres: [
      'Adult Alternative Pop/Rock',
      'Alternative Pop/Rock',
      'Alternative/Indie Rock',
      'Pop/Rock'
    ],
    images: albumCovers[0],
    largestImage: albumCovers[0].large,
    smallestImage: albumCovers[0].small,
    popularity: 62
  };

artists['spotify:artist:55tif8708yyDQlSjh3Trdu'] = {
  name: 'Ben Folds',
  uri: 'spotify:artist:55tif8708yyDQlSjh3Trdu',
  sharingURL: 'https://open.spotify.com/artist/55tif8708yyDQlSjh3Trdu',
  genres: [
  'Adult Alternative Pop/Rock',
  'Alternative Pop/Rock',
  'Alternative/Indie Rock',
  'Pop/Rock'
  ],
  images: artistImages[0],
  smallestImage: artistImages[0].small,
  largestImage: artistImages[0].xlarge,
  popularity: 50
};

tracks['spotify:track:0F0MA0ns8oXwGw66B2BSXm'] = {
  name: 'Let\'s Dance - 1999 Digital Remaster',
  uri: 'spotify:track:0F0MA0ns8oXwGw66B2BSXm',
  sharingURL: 'https://open.spotify.com/track/0F0MA0ns8oXwGw66B2BSXm',
  previewURL: 'http://d318706lgtcm8e.cloudfront.net/mp3-preview/fe28213f07f5428d97dc1a09b01449797cb38d78',
  duration: 457.133,
  artists: [
    {name: 'David Bowie', uri: 'spotify:artist:0oSGxfWSnnOXhD2fKuz2Gy'}
  ],
  album: {name: 'Let\'s Dance', uri: 'spotify:album:37KYBt1Lzn4eJ4KoCFZcnR'},
  trackNumber: 3,
  discNumber: 1,
  popularity: 0,
  flaggedExplicit: false,
  externalIds: {
    'isrc': 'USJT19900185'
  },
  availableTerritories: [ 'MY', 'NI', 'NL', 'NO', 'NZ', 'PA', 'PE', 'PH' ]
};

playlists['spotify:user:testuser:playlist:87234DfaD43fdsdfDx'] = {
  name: 'My Super Funky Playlist',
  version: 1,
  uri: 'spotify:user:testuser:playlist:87234DfaD43fdsdfDx',
  collaborative: false,
  creator: 'testuser',
  tracks: [
    {uri: 'spotify:track:0F0MA0ns8oXwGw66B2BSXm', name: 'Let\'s Dance - 1999 Digital Remaster'}
  ],
  dateModified: new Date()
}
  
exports.albums = albums;
exports.artists = artists;
exports.tracks = tracks;
exports.playlists = playlists;