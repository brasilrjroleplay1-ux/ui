"""Run the vendor suite and exercise the actual distributed library using its service shim."""
from pathlib import Path
import os,subprocess,tempfile,sys
ROOT=Path(__file__).resolve().parents[1]
VENDOR=ROOT/'vendor/rayfield-gen2'
LUNE=os.environ.get('CONEXAO_LUNE','/workspace/tools/lune-0.8.9/lune')
subprocess.run([sys.executable,str(ROOT/'tools/check_source.py')],check=True)

def run(args,label):
    result=subprocess.run([LUNE,*args],cwd=VENDOR,capture_output=True,text=True)
    log=Path('/tmp')/f'conexao-{label}.log';log.write_text(result.stdout+result.stderr)
    lines=(result.stdout+result.stderr).splitlines()
    if result.returncode:
        print('\n'.join(lines[-65:]));raise SystemExit(result.returncode)
    print('\n'.join(x for x in lines if 'tests passed' in x or 'coverage:' in x or x.startswith('PASS:')))

run(['run','scripts/run-tests.luau','--','--coverage-threshold','85.34'],'upstream')
runner=(VENDOR/'scripts/run-tests.luau').read_text()
prefix=runner[:runner.index('local results = {')]
checks=(ROOT/'tests/bundle_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()).replace('-- DEMO',(ROOT/'dist/Demo.luau').read_text())
with tempfile.TemporaryDirectory() as folder:
    test=Path(folder)/'public-bundle.luau';test.write_text(prefix+checks)
    run(['run',str(test)],'bundle')
