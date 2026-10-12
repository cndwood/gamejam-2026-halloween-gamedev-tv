#!/usr/bin/env python3
"""Export Uninvited and package an itch.io-ready ZIP (requires export templates)."""
import argparse
from pathlib import Path
import shutil
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--godot', default=shutil.which('godot') or shutil.which('godot4'), help='Godot executable path')
    args = parser.parse_args()
    if not args.godot:
        parser.error('Pass --godot with the path to your Godot executable.')
    output = ROOT / 'build' / 'web'
    output.mkdir(parents=True, exist_ok=True)
    (ROOT / 'build' / '.gdignore').touch()
    archive = ROOT / 'build' / 'uninvited-web.zip'
    archive.unlink(missing_ok=True)
    # Clear only our generated export directory, preventing stale files in uploads.
    for path in output.iterdir():
        if path.is_dir():
            shutil.rmtree(path)
        else:
            path.unlink()
    for flags in [ ['--editor', '--import', '--quit'], ['--export-release', 'Web', str(output / 'index.html')] ]:
        result = subprocess.run([args.godot, '--headless', '--path', str(ROOT), *flags], cwd=ROOT)
        if result.returncode:
            print('Export stopped. Check the errors above and install matching Web export templates in Godot.', file=sys.stderr)
            return result.returncode
    if not (output / 'index.html').exists() or not list(output.glob('*.wasm')) or not list(output.glob('*.pck')):
        print('Export is incomplete; no upload ZIP was created.', file=sys.stderr)
        return 1
    public_readme = (ROOT / 'README.md').read_text().split('## Development and Web upload')[0]
    (output / 'README.md').write_text(public_readme)
    (output / 'docs').mkdir(exist_ok=True)
    for name in ['Godot-License.txt', 'Engine-Third-Party-Licenses.txt', 'Third-Party-Notices.md']:
        source = ROOT / 'docs' / name
        if source.exists():
            shutil.copy2(source, output / 'docs' / name)
    with zipfile.ZipFile(archive, 'w', zipfile.ZIP_DEFLATED) as package:
        for path in sorted(output.rglob('*')):
            if path.is_file():
                package.write(path, path.relative_to(output))
    print(f'Upload ZIP: {archive}\nPreview: python3 -m http.server 8000 --directory build/web')
    return 0


if __name__ == '__main__':
    raise SystemExit(main())
