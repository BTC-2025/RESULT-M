const fs = require('fs');
const path = require('path');

const srcDir = 'backend/src/main/java/com/resulthub/api';

function walkDir(dir, callback) {
  if (!fs.existsSync(dir)) return;
  fs.readdirSync(dir).forEach(f => {
    let dirPath = path.join(dir, f);
    let isDirectory = fs.statSync(dirPath).isDirectory();
    isDirectory ? walkDir(dirPath, callback) : callback(path.join(dir, f));
  });
}

let md = '# ResultHub Backend Architecture\n\n';

let controllers = [];
let entities = [];
let services = [];

walkDir(srcDir, function(filePath) {
  if (filePath.endsWith('.java')) {
    let content = fs.readFileSync(filePath, 'utf8');
    if (content.includes('@RestController')) {
      controllers.push({ path: filePath, content: content });
    } else if (content.includes('@Entity')) {
      entities.push({ path: filePath, content: content });
    } else if (content.includes('@Service')) {
      services.push({ path: filePath, content: content });
    }
  }
});

md += '## 🚀 API Controllers & Endpoints\n\n';
controllers.forEach(c => {
  let classNameMatch = c.content.match(/class\s+(\w+Controller)/);
  if (!classNameMatch) return;
  let className = classNameMatch[1];
  md += '### ' + className + '\n\n';
  
  let baseMapMatch = c.content.match(/@RequestMapping\(\s*\"([^\"]+)\"/);
  let basePath = baseMapMatch ? baseMapMatch[1] : '';
  md += '**Base Path:** `' + basePath + '`\n\n';
  
  md += '| Method | Endpoint | Function |\n';
  md += '|---|---|---|\n';
  
  let lines = c.content.split('\n');
  for (let i = 0; i < lines.length; i++) {
    let line = lines[i].trim();
    let methodMatch = line.match(/@(GetMapping|PostMapping|PutMapping|DeleteMapping|PatchMapping)(?:\(\s*\"([^\"]*)\".*?\))?/);
    if (methodMatch) {
      let httpMethod = methodMatch[1].replace('Mapping', '').toUpperCase();
      let route = methodMatch[2] || '';
      
      // Look ahead for the function name
      let funcName = 'unknown';
      for(let j=i+1; j < i+10 && j < lines.length; j++) {
        let funcMatch = lines[j].match(/public\s+[\w\<\>\?\[\]\s]+\s+(\w+)\s*\(/);
        if (funcMatch) {
          funcName = funcMatch[1];
          break;
        }
      }
      md += '| ' + httpMethod + ' | `' + basePath + route + '` | `' + funcName + '` |\n';
    }
  }
  md += '\n';
});

md += '## 🗄️ Database Entities\n\n';
entities.forEach(e => {
  let classNameMatch = e.content.match(/class\s+(\w+)/);
  if (!classNameMatch) return;
  let className = classNameMatch[1];
  md += '### ' + className + '\n\n';
  
  let fields = [];
  let lines = e.content.split('\n');
  lines.forEach(line => {
    let fieldMatch = line.match(/private\s+([\w\<\>\[\]\,]+)\s+(\w+)\s*;/);
    if (fieldMatch) {
      fields.push('`' + fieldMatch[2] + '` (' + fieldMatch[1] + ')');
    }
  });
  
  if (fields.length > 0) {
    md += '- ' + fields.join(', ') + '\n\n';
  }
});

md += '## ⚙️ Services\n\n';
services.forEach(s => {
  let classNameMatch = s.content.match(/class\s+(\w+Service\w*)/);
  if (classNameMatch) {
    md += '- **' + classNameMatch[1] + '**\n';
  }
});

fs.writeFileSync('backend.md', md);
console.log('Done generating backend.md');
