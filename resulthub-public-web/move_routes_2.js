const fs = require('fs');
const path = require('path');

const srcDir = path.join('c:', 'Users', 'ELCOT', 'Desktop', 'Beta SoftNet', 'resulthub-public-web', 'src', 'app', 'dashboard', '`[sessionId`]');
const targetDir = path.join('c:', 'Users', 'ELCOT', 'Desktop', 'Beta SoftNet', 'resulthub-public-web', 'src', 'app', 'dashboard', '[sessionId]');

fs.readdirSync(srcDir).forEach(file => {
  const srcFile = path.join(srcDir, file);
  const targetFile = path.join(targetDir, file);
  if (!fs.existsSync(targetFile)) {
    fs.renameSync(srcFile, targetFile);
  } else {
    // if target is directory, merge it? Wait, none of the target directories should have contents except what we moved earlier
    fs.cpSync(srcFile, targetFile, { recursive: true });
    fs.rmSync(srcFile, { recursive: true, force: true });
  }
});

try {
  fs.rmdirSync(srcDir);
} catch(e) {}
console.log("Move finished");
