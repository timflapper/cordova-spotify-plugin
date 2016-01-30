#!/bin/sh

if [ "$PLUGIN_ENV" == "test" ]; then
  exit
fi

if [ "$CORDOVA_SPOTIFY_URL_SCHEME" == "" ]
then
    DEFAULT_SCHEME="spotify-cordova"

    echo "The Spotify SDK Plugin needs a URL scheme for authentication."
    echo "See http://bit.ly/1u11ZUz for more information"
    printf "Specify your URL scheme [$DEFAULT_SCHEME]: "

    read CORDOVA_SPOTIFY_URL_SCHEME
    if [ "$CORDOVA_SPOTIFY_URL_SCHEME" == "" ]
    then
      CORDOVA_SPOTIFY_URL_SCHEME="$DEFAULT_SCHEME"
    fi
fi

echo "Writing URL scheme to plugin.xml"

mv plugins/com.timflapper.spotify/plugin.xml plugins/com.timflapper.spotify/plugin.bak.xml
sed "s/{{URL_SCHEME}}/$CORDOVA_SPOTIFY_URL_SCHEME/g" plugins/com.timflapper.spotify/plugin.bak.xml > plugins/com.timflapper.spotify/plugin.xml
rm plugins/com.timflapper.spotify/plugin.bak.xml

echo "Removing placeholder"
rm -rf plugins/com.timflapper.spotify/src/ios/Spotify.framework

echo "Downloading Spotify Framework"
mkdir plugins/com.timflapper.spotify/src/ios/tmp
cd plugins/com.timflapper.spotify/src/ios/tmp
curl -OL "https://github.com/spotify/ios-sdk/archive/beta-6.tar.gz"

echo "Extracting"
tar xzvf beta-6.tar.gz
cd ..
mv tmp/ios-sdk-beta-6/Spotify.framework .
rm -rf tmp

echo "Finished!"
