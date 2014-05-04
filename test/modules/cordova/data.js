var SPImage = require('../../../www/lib/image');

var albums = {};

var albumCovers = [{
  large: SPImage({
    height: 640,
    width: 640,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/8782b58f895d68dc2fa1fd987a2fa1699b765984'
  }),
  medium: SPImage({
    height: 300, 
    width: 300,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/59acdf741304f2643168f80a80935b83f0a1ef28'
  }),
  small: SPImage({
    height: 64,
    width: 64,
    url: 'https://d3rt1990lpmkn.cloudfront.net/original/a13e23f485ccf67a91d9b207276ff067c60581a9'
  })
}];

albums['spotify:album:4FtOLTQqwnxpaABrJWYdBy'] = {
    name: 'Rockin\' The Suburbs',
    uri: 'spotify:album:4FtOLTQqwnxpaABrJWYdBy',
    sharingURL: 'http://open.spotify.com/album/4FtOLTQqwnxpaABrJWYdBy',
    externalIds: {
      upc: '074646161029'
    },
    availableTerritories: ['AD', 'AR', 'AT', 'AU', 'BE', 'BG', 'BO', 'BR', 'CA', 'CH', 'CL', 'CO', 'CR', 'CY', 'CZ', 'DE', 'DK', 'DO', 'EC', 'EE', 'ES', 'FI', 'FR', 'GB', 'GR', 'GT', 'HK', 'HN', 'HR', 'HU', 'IE', 'IS', 'IT', 'LI', 'LT', 'LU', 'LV', 'MC', 'MT', 'MX', 'MY', 'NI', 'NL', 'NO', 'NZ', 'PA', 'PE', 'PH', 'PL', 'PT', 'PY', 'RO', 'SE', 'SG', 'SI', 'SK', 'SV', 'TR', 'TW', 'US', 'UY'],
    artists: [{
      uri: 'spotify:artist:55tif8708yyDQlSjh3Trdu',
      name: 'Ben Folds'
    }],
    tracks: [
      {uri: 'spotify:track:2hDQU47XuGq9CdYRIQD1m6', name: 'Annie Waits'},
      {uri: 'spotify:track:5djxeOKKsF7BhHvz7iFOjw', name: 'Zak And Sara'},
      {uri: 'spotify:track:0f9fM6DdpJM79NQ1XbHcjJ', name: 'Still Fighting It'},
      {uri: 'spotify:track:2E3y6Tmfgs0NRIPxrZQuRH', name: 'Gone'},
      {uri: 'spotify:track:2Oq7FNjSS7hdVYqWqmDcQr', name: 'Fred Jones Part 2'},
      {uri: 'spotify:track:1JsrhWs2mx0DkdNS2wwDSQ', name: 'The Ascent Of Stan'},
      {uri: 'spotify:track:5fpbJ17L8Cw0OYcOdIG224', name: 'Losing Lisa'},
      {uri: 'spotify:track:2wlrGjzCYco5dCH3MxjibS', name: 'Carrying Cathy'},
      {uri: 'spotify:track:0QmSEMpnWRrVZ1o9oyjZF3', name: 'Not The Same'},
      {uri: 'spotify:track:3BOQOd4qPpdiwvqMQyh2Yg', name: 'Rockin\' The Suburbs'},
      {uri: 'spotify:track:7ny1jOJSZAF6VBb7x9DRO2', name: 'Fired'},
      {uri: 'spotify:track:1fujSajijBpJlr5mRGKHJN', name: 'The Luckiest'}
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
    covers: albumCovers[0],
    largestCover: albumCovers[0].large,
    smallestCover: albumCovers[0].small,
    popularity: 62
  };
  
  
exports.albums = albums;