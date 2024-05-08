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
  try {
    fs.writeFileSync('./wap.json', JSON.stringify(config), 'utf-8');
  } catch(e) {
    console.error(`Error writing file 'wap.json': `, e);
  }
  try {
    const data = fs.readFileSync(main, 'utf-8');
    built = data.replace('@project_version@', `v${config.version}`);
    try {
      fs.writeFileSync(main, built, 'utf-8'); 
      console.log(`replaced @project_version@ with ${versionWithBuild}`);
    } catch(e) {
      console.error(`Error writing file ${main}: `, e);
    }
  } catch (e) {
    console.error(`Error reading file ${main}: `, e);
  }
});