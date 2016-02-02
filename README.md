# Cordova Spotify Plugin

[![Build Status](https://travis-ci.org/timflapper/cordova-spotify-plugin.svg?branch=master)](https://travis-ci.org/timflapper/cordova-spotify-plugin)

This plugin provides a javascript API to Spotify's iOS SDK for Cordova applications.

_Android integration is planned for a future release_

## Installation
	
1. Install the plugin:

		`cordova plugin add com.timflapper.spotify`

2. Add the iOS platform to your project (if needed):

        `cordova platform add ios`

3. The install script will start automatically. It will do two things:
 - Ask you for a [custom URL scheme](http://bit.ly/1u11ZUz).
 - Download and extract the Spotify iOS SDK.

That's it!

## API

Documentation can be found [here](https://github.com/timflapper/cordova-plugin-spotify/wiki/API)

## Setting up a token exchange service

You can use the Ruby script that is included in the Spotify iOS SDK Demo Projects for development:

- [Download the Spotify iOS SDK](https://github.com/spotify/ios-sdk/releases)
- Follow the instructions from the [Spotify iOS SDK beginner's tutorial](https://developer.spotify.com/technologies/spotify-ios-sdk/tutorial/).	


## Non-interactive installation

To avoid being prompted for the [custom URL scheme](http://bit.ly/1u11ZUz),
you can alternatively provide it in an environment variable:
```
export CORDOVA_SPOTIFY_URL_SCHEME=somecustomscheme
cordova plugin add com.timflapper.spotify
```


## License

[MIT](LICENSE)
