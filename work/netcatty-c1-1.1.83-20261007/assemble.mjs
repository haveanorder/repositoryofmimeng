import fs from 'node:fs';
import path from 'node:path';
import { execFileSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import { pathToFileURL } from 'node:url';
const [source, official, output] = process.argv.slice(2).map(p => path.resolve(p));
const asar = await import(pathToFileURL(path.join(source, 'node_modules/@electron/asar/lib/asar.js')).href);
const staging = path.join(output, 'staging');
fs.mkdirSync(output, { recursive: true });
const original = path.join(official, 'resources/app.asar');
const header = asar.getRawHeader(original).header;
asar.extractAll(original, staging);
const pkg = JSON.parse(fs.readFileSync(path.join(staging, 'package.json')));
if (pkg.name !== 'netcatty' || pkg.version !== '1.1.83') throw Error('Expected official Netcatty 1.1.83');
const changed = (execFileSync('git', ['diff', '--name-only', 'HEAD'], { cwd: source, encoding: 'utf8' }) + execFileSync('git', ['ls-files', '--others', '--exclude-standard'], { cwd: source, encoding: 'utf8' })).trim().split('\n');
for (const file of changed) {
  if (!file.startsWith('electron/') && !file.startsWith('packages/netcatty-dsh-bridge/')) continue;
  if (/\.test\./.test(file)) continue;
  fs.mkdirSync(path.dirname(path.join(staging, file)), { recursive: true });
  fs.copyFileSync(path.join(source, file), path.join(staging, file));
}
fs.rmSync(path.join(staging, 'dist'), { recursive: true, force: true });
fs.cpSync(path.join(source, 'dist'), path.join(staging, 'dist'), { recursive: true });
const unpacked = new Set();
function remember(node, prefix = '', inherited = false) {
  for (const [name, entry] of Object.entries(node.files || {})) {
    const p = prefix ? prefix + '/' + name : name;
    const unpack = inherited || Boolean(entry.unpacked);
    if (unpack) unpacked.add(p);
    if (entry.files) remember(entry, p, unpack);
  }
}
remember(header);
const streams = [];
function collect(directory, prefix = '') {
  for (const name of fs.readdirSync(directory).sort()) {
    const file = path.join(directory, name);
    const relative = prefix ? prefix + '/' + name : name;
    const stat = fs.lstatSync(file);
    const unpackedFile = unpacked.has(relative) || relative.startsWith('electron/bridges/aiBridge/sdk/nativeExtensions/') || relative.startsWith('packages/netcatty-dsh-bridge/');
    if (stat.isDirectory()) {
      streams.push({ type: 'directory', path: relative, unpacked: unpackedFile });
      collect(file, relative);
    } else if (stat.isSymbolicLink()) streams.push({ type: 'link', path: relative, stat, symlink: fs.readlinkSync(file), unpacked: unpackedFile });
    else streams.push({ type: 'file', path: relative, stat, streamGenerator: () => fs.createReadStream(file), unpacked: unpackedFile });
  }
}
collect(staging);
const payload = path.join(output, 'payload/resources');
fs.mkdirSync(payload, { recursive: true });
await asar.createPackageFromStreams(path.join(payload, 'app.asar'), streams);
const digest = file => createHash('sha256').update(fs.readFileSync(file)).digest('hex');
const files = [];
function prune(directory, prefix = '') {
  for (const name of fs.readdirSync(directory)) {
    const file = path.join(directory, name);
    const relative = prefix ? prefix + '/' + name : name;
    if (fs.statSync(file).isDirectory()) { prune(file, relative); continue; }
    const oldFile = path.join(official, relative);
    const before = fs.existsSync(oldFile) ? digest(oldFile) : null;
    const after = digest(file);
    if (before === after) { fs.unlinkSync(file); continue; }
    files.push({ path: relative, before, after });
  }
}
prune(path.join(output, 'payload'));
fs.writeFileSync(path.join(output, 'manifest.json'), JSON.stringify({ base: '1.1.83', architecture: 'x64', originalAsar: digest(original), patchedAsar: digest(path.join(payload, 'app.asar')), status: 'acceptance-pending', files }, null, 2));
console.log('Assembled resources with original name, version and Windows dependencies.');
