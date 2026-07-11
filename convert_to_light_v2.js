const fs = require('fs');
const path = require('path');

const files = [
  'src/app/dashboard/team/page.tsx',
  'src/app/dashboard/developers/page.tsx',
  'src/app/dashboard/page.tsx',
  'src/app/dashboard/workspaces/page.tsx',
  'src/app/dashboard/security/page.tsx',
  'src/app/dashboard/analytics/page.tsx',
  'src/app/dashboard/complaints/page.tsx',
  'src/app/dashboard/polls/page.tsx',
  'src/app/dashboard/settings/page.tsx'
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

  // Modal backgrounds (bg-zinc-950 and bg-zinc-900)
  content = content.replace(/bg-zinc-950\/80/g, 'bg-white/80');
  content = content.replace(/bg-zinc-950\/50/g, 'bg-white/50');
  content = content.replace(/bg-zinc-950\/40/g, 'bg-black/40'); // Usually backdrops
  content = content.replace(/bg-zinc-950/g, 'bg-white');
  
  content = content.replace(/bg-zinc-900\/80/g, 'bg-white/80');
  content = content.replace(/bg-zinc-900\/50/g, 'bg-white/50');
  
  // CAREFUL: Only replace bg-zinc-900 if it's not a button hover state or something specifically dark.
  // Actually, replacing bg-zinc-900 with bg-zinc-50 is standard for light cards.
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
  
  content = content.replace(/text-white/g, 'text-zinc-900');

  // Fix buttons that should remain white text
  content = content.replace(/bg-red-600 text-zinc-900/g, 'bg-red-600 text-white');
  content = content.replace(/bg-indigo-600 text-zinc-900/g, 'bg-indigo-600 text-white');
  content = content.replace(/to-indigo-600 rounded-xl overflow-hidden transition-all hover:scale-105 hover:shadow-\[0_0_40px_-10px_rgba\(99,102,241,0.5\)\] active:scale-95 text-zinc-900/g, 'to-indigo-600 rounded-xl overflow-hidden transition-all hover:scale-105 hover:shadow-[0_0_40px_-10px_rgba(99,102,241,0.5)] active:scale-95 text-white');
  content = content.replace(/bg-orange-600 hover:bg-orange-500 rounded-xl text-zinc-900/g, 'bg-orange-600 hover:bg-orange-500 rounded-xl text-white');
  
  // Specific fix for "Create Poll" button if the script double ran
  content = content.replace(/<span className="relative z-10 text-zinc-900">Create Poll<\/span>/g, '<span className="relative z-10">Create Poll</span>');

  fs.writeFileSync(fullPath, content, 'utf8');
  console.log('Processed', file);
}
