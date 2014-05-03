# Cordova Spotify Plugin

This plugin provides a javascript API to Spotify's iOS SDK.

## Do not use this plugin in a production environment!
Currently the Spotify iOS SDK is in beta and breaking changes can occur without prior notice.

### Table of Contents

- [Setting up a token exchange service](#setting-up-a-token-exchange-service)

#### spotify API

- Methods
	- [spotify.authenticate](#spotifyauthenticate)
	- [spotify.search](#spotifysearch)
	- [spotify.getPlaylistsForUser](#spotifygetplaylistsforuser)

#### spotify.Session API

- [spotify.Session](#spotifysession)
- Properties
	- [session.username](#sessionusername)
	- [session.credential](#sessioncredential)
	
#### spotify.AudioPlayer API

- [spotify.AudioPlayer](#spotifyaudioplayer)
- Methods
	- [audioPlayer.addEventListener](#audioplayeraddeventlistener)
	- [audioPlayer.playURI](#audioplayerplayuri)
	- [audioPlayer.seekToOffset](#audioplayerseektooffset)
	- [audioPlayer.getIsPlaying](#audioplayergetisplaying)	
	- [audioPlayer.setIsPlaying](#audioplayersetisplaying)
	- [audioPlayer.setVolume](#audioplayersetvolume)
	- [audioPlayer.getLoggedIn](#audioplayergetloggedin)
	- [audioPlayer.getCurrentTrack](#audioplayergetcurrenttrack)
	- [audioPlayer.getCurrentPlaybackPosition](#audioplayergetcurrentplaybackposition)
- Events
	- [error](#error)
	- [message](#message)
	- [playbackStatus](#playbackstatus)
	- [seekToOffset](#seektooffset)

#### spotify.Playlist API

- [spotify.Playlist](#spotifyplaylist)
- Methods
	- [playlist.setName](#playlistsetname)
	- [playlist.setDescription](#playlistsetdescription)
	- [playlist.setCollaborative](#playlistsetcollaborative)
	- [playlist.addTracks](#playlistaddtracks)
	- [playlist.delete](#playlistdelete)	
- Properties
	- [playlist.name](#playlistname)
	- [playlist.version](#playlistversion)
	- [playlist.uri](#playlisturi)
	- [playlist.collaborative](#playlistcollaborate)
	- [playlist.creator](#playlistcreator)
	- [playlist.tracks](#playlisttracks)
	- [playlist.dateModified](#playlistdatemodified)
	
#### spotify.Album API

- [spotify.Album](#spotifyalbum)
- Properties
	- [album.name](#albumname)
	- [album.uri](#albumuri)
	- [album.sharingURL](#albumsharingurl)
	- [album.externalIds](#albumexternalids)
	- [album.availableTerritories](#albumavailableterritories)
	- [album.artists](#albumartists)
	- [album.tracks](#albumtracks)
	- [album.releaseDate](#albumreleasedate)
	- [album.type](#albumtype)
	- [album.genres](#albumgenres)
	- [album.covers](#albumcovers)
	- [album.largestCover](#albumlargestcover)
	- [album.smallestCover](#albumsmallestcover)
	- [album.popularity](#albumpopularity)

#### spotify.Artist API

- [spotify.Artist](#spotifyarist)
- Properties
	- [artist.name](#artistname)
	- [artist.uri](#artisturi)
	- [artist.sharingURL](#artistsharingURL)
	- [artist.genres](#artistgenres)
	- [artist.images](#artistimages)
	- [artist.smallestImage](#artistsmallestimage)
	- [artist.largestImage](#artistlargestimage)
	- [artist.popularity](#artistpopularity)

#### spotify.Track API

- [spotify.Track](#spotifytrack)
- Properties
	- [track.name](#trackname)
	- [track.uri](#trackuri)
	- [track.sharingURL](#tracksharingURL)
	- [track.previewURL](#trackpreviewURL)
	- [track.duration](#trackduration)
	- [track.artists](#trackartists)
	- [track.album](#trackalbum)
	- [track.trackNumber](#tracktracknumber)
	- [track.discNumber](#trackdiscnumber)
	- [track.popularity](#trackpopularity)
	- [track.flaggedExplicit](#trackflaggedexplicit)
	- [track.externalIds](#trackexternalids)
	- [track.availableTerritories](#trackavailableterritories)
	
# Setting up a token exchange service

To set up a token exchange service you have two options:

### Use the ruby script from the Spotify iOS SDK Demo Projects

* [Download the Spotify iOS SDK](https://github.com/spotify/ios-sdk/releases)
* Follow the instructions from the [Spotify iOS SDK beginner's tutorial](https://developer.spotify.com/technologies/spotify-ios-sdk/tutorial/).	

### Make your own

Explanation coming soon...

# spotify

## Methods

### spotify.authenticate

Authenticate the user with the Spotify API

```javascript
spotify.authenticate(clientId, tokenExchangeURL, [scopes], callback)
```

### clientId `string`

the clientId supplied by Spotify.

### tokenExchangeURL `string`

The URL for your token exchange service. See [setting up a token exchange service](#setting-up-a-token-exchange-service)

### scopes [optional] `array`

Custom scopes to request from the Spotify authentication service

### callback `function`

The callback gets two arguments `error` and `session`. `session` is a spotifySession object.

### spotify.search

### spotify.getPlaylistsForUser

# spotify.Session

Normally a `spotify.Session` object is returned from `spotify.authenticate()` but you can use the `spotify.Session` object to store the session for later use. A session is valid for 24 hours after which the user will need to login again.

```javascript
var session = spotify.Session({username: 'someUsername', credentials: 'AFD42....GD43'});
```

## Properties

### session.username

The username of the user.

### session.credential

An access token to verify the session.

# spotify.AudioPlayer

The constructor for a new `spotify.AudioPlayer` object.

```javascript
spotify.AudioPlayer(companyName, appName, session, callback)
```

### companyName `string`

Your company name

### appName `string`

Your application name

### session `object`

The user's `spotify.Session` object.

### callback `function`

The callback gets two arguments `error` and an `spotify.AudioPlayer` object, ready to start playing tracks.

#### Example

These examples show how to construct a `spotify.AudioPlayer` and play a track.

```javascript
spotify.AudioPlayer('Your-Company-Name', 'Your-App-Name', session, function(error, audioPlayer) {
	audioPlayer.playURI('spotify:track:6JEK0CvvjDjjMUBFoXShNZ');
});
```

## Methods

### audioPlayer.addEventListener

### audioPlayer.playURI

### audioPlayer.seekToOffset

### audioPlayer.getIsPlaying

### audioPlayer.setIsPlaying

### audioPlayer.setVolume

### audioPlayer.getLoggedIn

### audioPlayer.getCurrentTrack

### audioPlayer.getCurrentPlaybackPosition


## Events

### login

### logout

### permissionLost

### error

### message

### playbackStatus

### seekToOffset

# spotify.Playlist

## Methods

### playlist.setName

### playlist.setDescription

### playlist.setCollaborative

### playlist.addTracks

### playlist.delete

## Properties

### playlist.name

### playlist.version

### playlist.uri

### playlist.collaborative

### playlist.creator

### playlist.tracks

### playlist.dateModified

# spotify.Album

## Properties

### album.name

### album.uri

### album.sharingURL

### album.externalIds

### album.availableTerritories

### album.artists

### album.tracks

### album.releaseDate

### album.type

### album.genres

### album.covers

### album.largestCover

### album.smallestCover

### album.popularity

# spotify.Artist

## Properties

### artist.name

### artist.uri

### artist.sharingURL

### artist.genres

### artist.images

### artist.smallestImage

### artist.largestImage

### artist.popularity

# spotify.Track

## Properties

### track.name

### track.uri

### track.sharingURL

### track.previewURL

### track.duration

### track.artists

### track.album

### track.trackNumber

### track.discNumber

### track.popularity

### track.flaggedExplicit

### track.externalIds

### track.availableTerritories