// Copies the Flutter web build (../build/web) into public/play so the site
// serves the game at /play/. Flutter builds with <base href="/"> by default,
// so the copy gets <base href="/play/"> to load its assets from there.
// Run after each `flutter build web`: npm run play
import { cpSync, existsSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const src = join(root, '..', 'build', 'web');
const dest = join(root, 'public', 'play');

if (!existsSync(join(src, 'index.html'))) {
  console.error(`No Flutter web build in ${src}. Run \`flutter build web\` first.`);
  process.exit(1);
}

rmSync(dest, { recursive: true, force: true });
cpSync(src, dest, { recursive: true });

const index = join(dest, 'index.html');
const html = readFileSync(index, 'utf8').replace(/<base href="[^"]*">/, '<base href="/play/">');
writeFileSync(index, html);
console.log('Flutter web build copied to public/play (base href /play/).');
