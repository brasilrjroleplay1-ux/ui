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
run(['run',str(ROOT/'tests/executor_policy_checks.luau')],'executor-policy')
runner=(VENDOR/'scripts/run-tests.luau').read_text()
prefix=runner[:runner.index('local results = {')]
checks=(ROOT/'tests/bundle_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()).replace('-- DEMO',(ROOT/'dist/Demo.luau').read_text()).replace('-- COMPONENTS',(ROOT/'dist/Components.luau').read_text())
with tempfile.TemporaryDirectory() as folder:
    test=Path(folder)/'public-bundle.luau';test.write_text(prefix+checks)
    run(['run',str(test)],'bundle')
    startup=Path(folder)/'executor-startup.luau'
    startup.write_text(prefix+(ROOT/'tests/executor_startup_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()))
    run(['run',str(startup)],'executor-startup')
    layout=Path(folder)/'control-layout.luau'
    layout.write_text(prefix+(ROOT/'tests/control_layout_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()))
    run(['run',str(layout)],'control-layout')
    chrome=Path(folder)/'chrome.luau'
    chrome.write_text(prefix+(ROOT/'tests/chrome_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()))
    run(['run',str(chrome)],'chrome')
    shell=Path(folder)/'shell.luau'
    shell.write_text(prefix+(ROOT/'tests/shell_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()))
    run(['run',str(shell)],'shell')
    navigation=Path(folder)/'navigation.luau'
    navigation.write_text(prefix+(ROOT/'tests/navigation_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()))
    run(['run',str(navigation)],'navigation')
    slider_input=Path(folder)/'slider-input.luau'
    slider_input.write_text(prefix+(ROOT/'tests/slider_input_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()))
    run(['run',str(slider_input)],'slider-input')
    feedback=Path(folder)/'feedback.luau'
    feedback.write_text(prefix+(ROOT/'tests/feedback_checks.luau').read_text().replace('-- BUNDLE',(ROOT/'dist/ConexaoUI.luau').read_text()))
    run(['run',str(feedback)],'feedback')
