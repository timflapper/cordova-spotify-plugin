var exec = require('cordova/exec');

function requestAudioPlayer(companyName, appName, session, callback) {
  spotify.exec( 'getAudioPlayer',
                [ companyName, appName, session ],
                callback );
}

module.exports = requestAudioPlayer;