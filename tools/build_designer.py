"""Build the offline Designer using actual RetroBox palettes, icons and catalog."""
from pathlib import Path
import argparse,json,subprocess,sys
ROOT=Path(__file__).resolve().parents[1]
PROJECT=ROOT/'RetroBox-UI-v1.1.0/retrobox-ui'
DESIGNER=ROOT/'designer'
def build(check=False):
    if not check:
        subprocess.run([sys.executable,str(PROJECT/'tools/build_distribution.py'),'--embed-only'],check=True)
    result=subprocess.run([sys.executable,str(PROJECT/'tests/run_headless.py'),str(PROJECT/'tools/export_designer_assets.lua')],check=True,capture_output=True,text=True)
    assets=json.loads(result.stdout)
    catalog=json.loads((DESIGNER/'schema.json').read_text())
    assert assets.pop('Catalog')==catalog,'The embedded catalog must match designer/schema.json'
    assert sorted(assets['Themes'])==catalog['ThemeNames'] and sorted(assets['Icons'])==catalog['IconNames']
    assets_text=json.dumps(assets,ensure_ascii=False,sort_keys=True,indent=2)+'\n'
    src=DESIGNER/'src';html=(src/'shell.html').read_text()
    values={'STYLE':(src/'style.css').read_text(),'CATALOG':json.dumps(catalog,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c'),'ASSETS':json.dumps(assets,ensure_ascii=False,separators=(',',':')).replace('<','\\u003c')}
    for key,name in [('CORE','core.js'),('SIMULATOR','simulator.js'),('APP','app.js')]:
        values[key]=(src/name).read_text().replace('</script','<\\/script')
    for key,value in values.items():html=html.replace('/*__'+key+'__*/',value)
    assert '/*__' not in html
    for path,content in {DESIGNER/'index.html':html,DESIGNER/'assets.json':assets_text}.items():
        if check:assert path.read_text()==content,'Stale Designer build: '+str(path)
        else:path.write_text(content)
    print(f"Offline Designer {'verified' if check else 'built'}: {len(html.encode())} bytes, {len(catalog['Controls'])} components, {len(catalog['FlowNodes'])} blocks, {len(assets['Themes'])} themes, {len(assets['Icons'])} icons")
if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--check',action='store_true');build(p.parse_args().check)
