const fs = require('fs');
const path = require('path');

const srcDir = path.join('c:', 'Users', 'ELCOT', 'Desktop', 'Beta SoftNet', 'resulthub-public-web', 'src', 'app', 'dashboard', '`[sessionId`]');
const targetDir = path.join('c:', 'Users', 'ELCOT', 'Desktop', 'Beta SoftNet', 'resulthub-public-web', 'src', 'app', 'dashboard', '[sessionId]');

fs.readdirSync(srcDir).forEach(file => {
  const srcFile = path.join(srcDir, file);
  const targetFile = path.join(targetDir, file);
  console.log("Copying", srcFile, "to", targetFile);
  fs.cpSync(srcFile, targetFile, { recursive: true });
});
console.log("Copy finished");
