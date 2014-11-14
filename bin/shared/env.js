var fs = require('fs');

module.exports = {
  loadEnvVariables: function(fn) {
    if (fs.existsSync(fn)) {
      fs.readFileSync(fn, {encoding: 'utf8'})
          .split('\n')
            .forEach(function(item) {
              var env = item.split('=')
                , key = env[0], value = env[1];
              process.env[key] = process.env[key] || value;
            });
    }
  },
  setupEnvVariablesForTestScript: function(keys) {
    var enabledVars = [];

    if (process.env.SAUCE)
      keys = keys.concat(['SAUCE_USERNAME', 'SAUCE_ACCESS_KEY']);

    keys.forEach(function(key, index, arr) {
      if (process.env[key])
        enabledVars.push(key+'='+process.env[key]);
    });

    return enabledVars;
  },
  setupTestCommand: function(env, framework, script) {
    return env.concat([framework, script]).join(' ');
  }
}
