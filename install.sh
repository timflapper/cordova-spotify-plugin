#!/bin/sh

echo "Removing placeholder"
rm -rf plugins/com.timflapper.spotify/src/ios/Spotify.framework

echo "Downloading Spotify Framework"
mkdir plugins/com.timflapper.spotify/src/ios/tmp
cd plugins/com.timflapper.spotify/src/ios/tmp
curl -OL "https://github.com/spotify/ios-sdk/archive/beta-5.tar.gz"

echo "Extracting"
tar xzvf beta-5.tar.gz
cd ..
mv tmp/ios-sdk-beta-5/Spotify.framework .
rm -rf tmp

echo "Finished!"
