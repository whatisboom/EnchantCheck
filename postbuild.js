const { version } = require('./wap.json');
const fs = require('fs');

const main = './EnchantCheck/main.lua'

fs.readFile(main, 'utf-8', function (err, data) {
  if (err) {
    console.log(err);
    return;
  }
  built = data.replace(`v${version}`, '@project_version@');
  fs.writeFile(main, built, 'utf-8', function(err) {
    if (err) {
      console.log(err);
      return;
    }
    console.log(`replaced ${version} with '@project_version@'`)
  }); 
});