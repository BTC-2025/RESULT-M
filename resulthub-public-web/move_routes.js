const fs = require('fs');
const path = require('path');

const srcDir = path.join('c:', 'Users', 'ELCOT', 'Desktop', 'Beta SoftNet', 'resulthub-public-web', 'src', 'app', 'dashboard', '`[sessionId`]');
const targetDir = path.join('c:', 'Users', 'ELCOT', 'Desktop', 'Beta SoftNet', 'resulthub-public-web', 'src', 'app', 'dashboard', '[sessionId]');

fs.readdirSync(srcDir).forEach(file => {
  const srcFile = path.join(srcDir, file);
  const targetFile = path.join(targetDir, file);
  fs.renameSync(srcFile, targetFile);
});

fs.rmdirSync(srcDir);
console.log("Done");
