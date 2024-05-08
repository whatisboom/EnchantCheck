const config = require('./wap.json');
const fs = require('fs');
const readline = require('readline').createInterface({
  input: process.stdin,
  output: process.stdout
});
const main = './EnchantCheck/main.lua'

readline.question('Enter current game version: ', version => {
  readline.close();
  const pieces = config.version.split('-');
  let buildNumber = parseInt(pieces[1]);
  const versionWithBuild = pieces.length > 1 && pieces[0] === version ? `${version}-${buildNumber+1}` : `${version}-1`;
  config.version = versionWithBuild;
  config.wowVersions.mainline = version;
  fs.writeFileSync('./wap.json', JSON.stringify(config), 'utf-8');
  fs.readFile(main, 'utf-8', function (err, data) {
    if (err) {
      console.log(err);
      return;
    }
    built = data.replace('@project_version@', `v${config.version}`);
    fs.writeFile(main, built, 'utf-8', function(err) {
      if (err) {
        console.error(err);
        return;
      }
      console.log('replaced')
    }); 
  });
});