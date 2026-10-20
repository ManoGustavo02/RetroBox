-- Run with RETROBOX_PROMPT_PATH=/absolute/path/Prompt-RetroBox-IA-v2.5.1.md
-- python3 tests/run_headless.py tests/prompt-runtime.lua
local Mock=dofile('tests/mock_roblox.lua')
local Library=dofile('RetroBox.lua')
dofile('tests/distribution.lua')(Mock,Library,function() end)
local f=assert(io.open(assert(os.getenv('RETROBOX_PROMPT_PATH'),'Set RETROBOX_PROMPT_PATH'),'rb'))
local prompt=f:read('*a');f:close()
loadstring=load;readfile=nil;writefile=nil;makefolder=nil;isfile=nil;listfiles=nil
Mock.StrictIconLifecycle=true;Mock.ParentLockErrors=0;Mock.DestroyedIconWrites=0
local requests=0
game.HttpGet=function(...) requests=requests+1;return Mock.distributionHTTP(...) end
local function example(marker)
    local start=assert(prompt:find(marker,1,true),marker)
    return assert(prompt:sub(start):match('```lua\n(.-)```'))
end
local function clean(window)
    window:Destroy();Mock.pump(100)
    assert(Mock.Connections==0 and #Mock.Warnings==0 and Mock.ParentLockErrors==0 and Mock.DestroyedIconWrites==0)
end
local code=example('Exemplo funcional de montagem da interface')
local w=assert(load(code..'\nreturn window','@prompt-primary'))();Mock.pump()
assert(w.Controls.example_profile and w.Controls.example_action and requests==3);clean(w)
print('PASS primary prompt example: permanent HTTP bootstrap and unchanged assembly sequence')
code=example('Exemplo funcional dos componentes da 2.2.0')
local window,section,hud,bar,stepper=assert(load(code..'\nreturn window,section,hud,bar,stepper','@prompt-compact'))()
Mock.pump();assert(window.Controls.money and window.Controls.steps and window.Controls.preview and hud.Items[1]:GetValue()==1250)
assert(window.Controls.start:Press());Mock.pump();assert(stepper:GetSteps()[3].Status=='Completed' and hud.Items[1]:GetValue()==1260)
window:Hide();assert(hud.Frame.Visible and bar.Frame.Visible);clean(window)
print('PASS compact prompt example: shared HUD State, real action, preview, Stepper and cleanup')
code=example('Exemplo adicional do launcher nativo da 2.3.0')
local environment=setmetatable({Library=Library},{__index=_G})
local hub=assert(load(code..'\nreturn hub','@prompt-native-hub','t',environment))();Mock.pump()
assert(hub.Launcher and hub:GetCatalogFilter()=='All' and hub.Window.Theme=='Hacker')
assert(hub:GetGame('current').FallbackName=='Jogo desta sessão' and hub:GetScript('current','aviso').Description~='')
assert(hub.PlayButton:Press());Mock.pump();assert(hub:GetScriptStatus('current','aviso').Status=='Completed')
clean(hub.Window)
print('PASS native hub prompt example: catalog only, default shared launcher and local callback')
code=example('Exemplo adicional de scripts universais da 2.4.0')
local universal=assert(load(code..'\nreturn universalHub','@prompt-universal','t',environment))();Mock.pump()
assert(universal:GetSelectedCategory()=='Universal' and universal:GetSelectedGame()==nil and #universal:GetGames()==0)
assert(universal:GetSelectedScript().Name=='Aviso universal' and universal.ScriptList._pool[1].UniversalTag.Visible)
assert(universal.PlayButton:Press());Mock.pump();assert(universal:GetUniversalScriptStatus('aviso').Status=='Completed')
clean(universal.Window)
print('PASS universal prompt example: independent native category, tag and explicit local callback')
for _,spec in ipairs({
 {'localização e formulários','localization-forms'},
 {'componentes reutilizáveis','reusable-components'},
 {'grade de cards','card-grid'},
 {'ligações visuais','visual-flow'},
}) do
 code=example('Exemplo funcional de '..spec[1]..' da 2.5.1')
 local created=assert(load(code..'\nreturn window','@prompt-'..spec[2]))();Mock.pump()
 if spec[2]=='localization-forms' then
  local form=created._forms.preferences;form:SetDraft({name='Updated',enabled=true});assert(form:Apply());Mock.pump();assert(form:GetValue().name=='Updated')
 elseif spec[2]=='reusable-components' then assert(created:GetFlag('wallet/balance')==1500 and created:GetFlag('bank/balance')==5000)
 elseif spec[2]=='card-grid' then assert(created.Controls.tools:GetViewStats().Total==1000 and created.Controls.tools:GetViewStats().Pool<=64)
 else created.Controls.amount:SetValue(42,true);assert(created.Controls.summary:GetValue()=='Quantidade: 42');assert(created.Controls.run:Press());Mock.pump() end
 clean(created);print('PASS prompt 2.5 example: '..spec[2])
end
print('8/8 prompt examples passed with mocked HTTP and no executor files')
