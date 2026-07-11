const fs = require('fs');
const path = require('path');

const files = [
  'src/app/dashboard/security/page.tsx',
  'src/app/dashboard/analytics/page.tsx',
  'src/app/dashboard/complaints/page.tsx',
  'src/app/dashboard/polls/page.tsx',
  'src/app/dashboard/settings/page.tsx',
];

const basePath = 'c:/Users/ELCOT/Desktop/Beta SoftNet/resulthub-public-web';

for (const file of files) {
  const fullPath = path.join(basePath, file);
  if (!fs.existsSync(fullPath)) continue;

  let content = fs.readFileSync(fullPath, 'utf8');

  // Global theme
  content = content.replace(/bg-\[\#0A0A0A\]/g, 'bg-transparent');
  content = content.replace(/text-zinc-100/g, 'text-zinc-900');
  
  // Gradients for Headings
  content = content.replace(/from-white via-zinc-200 to-zinc-400/g, 'from-zinc-900 via-zinc-700 to-zinc-500');

  // Backgrounds
  content = content.replace(/bg-zinc-950\/80/g, 'bg-white/80');
  content = content.replace(/bg-zinc-950\/50/g, 'bg-white/50');
  content = content.replace(/bg-zinc-950/g, 'bg-white');
  
  content = content.replace(/bg-zinc-900\/80/g, 'bg-white/80');
  content = content.replace(/bg-zinc-900\/50/g, 'bg-white/50');
  content = content.replace(/bg-zinc-900/g, 'bg-zinc-50');

  content = content.replace(/bg-zinc-800\/50/g, 'bg-zinc-100/50');
  content = content.replace(/bg-zinc-800/g, 'bg-zinc-100');

  // Borders
  content = content.replace(/border-zinc-800\/80/g, 'border-zinc-200');
  content = content.replace(/border-zinc-800\/50/g, 'border-zinc-200');
  content = content.replace(/border-zinc-800/g, 'border-zinc-200');
  content = content.replace(/border-zinc-700/g, 'border-zinc-200');
  content = content.replace(/border-zinc-600/g, 'border-zinc-300');

  // Hover states
  content = content.replace(/hover:bg-zinc-900/g, 'hover:bg-zinc-50');
  content = content.replace(/hover:bg-zinc-800/g, 'hover:bg-zinc-100');
  content = content.replace(/hover:border-zinc-700/g, 'hover:border-zinc-300');
  content = content.replace(/hover:border-zinc-600/g, 'hover:border-zinc-400');
  content = content.replace(/hover:text-white/g, 'hover:text-zinc-900');

  // Text colors
  content = content.replace(/text-zinc-400/g, 'text-zinc-500');
  content = content.replace(/text-zinc-300/g, 'text-zinc-600');
  content = content.replace(/text-zinc-200/g, 'text-zinc-800');
  
  // Replace text-white cautiously: if the element doesn't have a colored background
  // Actually, replacing text-white everywhere except standard buttons is tough with Regex. 
  // Let's replace it globally and then fix the buttons.
  content = content.replace(/text-white/g, 'text-zinc-900');

  // Fix buttons that should remain white text
  // Red Button
  content = content.replace(/bg-red-600 text-zinc-900/g, 'bg-red-600 text-white');
  // Indigo Button
  content = content.replace(/bg-indigo-600 text-zinc-900/g, 'bg-indigo-600 text-white');
  content = content.replace(/to-indigo-600 rounded-xl overflow-hidden transition-all hover:scale-105 hover:shadow-\[0_0_40px_-10px_rgba\(99,102,241,0.5\)\] active:scale-95"\n            >\n              <div className="absolute inset-0 bg-white\/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out" \/>\n              <Plus className="w-5 h-5 relative z-10" \/>\n              <span className="relative z-10">Create Poll<\/span>/g, 
  'to-indigo-600 rounded-xl overflow-hidden transition-all hover:scale-105 hover:shadow-[0_0_40px_-10px_rgba(99,102,241,0.5)] active:scale-95 text-white">\n              <div className="absolute inset-0 bg-white/20 translate-y-full group-hover:translate-y-0 transition-transform duration-300 ease-out" />\n              <Plus className="w-5 h-5 relative z-10" />\n              <span className="relative z-10">Create Poll</span>');
  // Orange Button
  content = content.replace(/bg-orange-600 hover:bg-orange-500 rounded-xl text-zinc-900/g, 'bg-orange-600 hover:bg-orange-500 rounded-xl text-white');
  
  fs.writeFileSync(fullPath, content, 'utf8');
  console.log('Processed', file);
}
