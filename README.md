# Cordova Spotify Plugin

[![Build Status](https://travis-ci.org/timflapper/cordova-spotify-plugin.svg?branch=master)](https://travis-ci.org/timflapper/cordova-spotify-plugin)

This plugin provides a javascript API to Spotify's iOS SDK.

**Beware! this plugin is in a very early (alpha) stage. Please try it out but do not use for production.**

## Do not use this plugin in a production environment!
Currently the Spotify iOS SDK is in beta and breaking changes can occur without prior notice.

## Installation
	
1. Install the plugin:

		`cordova plugin add https://github.com/timflapper/cordova-spotify-plugin`

2. Run the install script to download the `Spotify.framework`
        
        `./plugins/com.timflapper.spotify/install.sh`

3. Add the iOS playform to your project.

        `cordova platform add ios`

    Or, if you already have ios as a platform please run:

        `cordova prepare`

4. Try it out!

## API

Documentation can be found [here](https://github.com/timflapper/cordova-plugin-spotify/wiki/API)

## Setting up a token exchange service

You can use the Ruby script that is included in the Spotify iOS SDK Demo Projects for development:

- [Download the Spotify iOS SDK](https://github.com/spotify/ios-sdk/releases)
- Follow the instructions from the [Spotify iOS SDK beginner's tutorial](https://developer.spotify.com/technologies/spotify-ios-sdk/tutorial/).	
