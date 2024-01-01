const { version } = require('./wap.json');
const fs = require('fs');

const main = './EnchantCheck/main.lua'

fs.readFile(main, 'utf-8', function (err, data) {
  if (err) {
    console.log(err);
    return;
  }
  built = data.replace('@project_version@', `v${version}`);
  fs.writeFile(main, built, 'utf-8', function(err) {
    if (err) {
      console.log(err);
      return;
    }
    console.log('replaced')
  }); 
});