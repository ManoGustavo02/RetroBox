"use strict";
const {test,before,after}=require("node:test"),assert=require("node:assert/strict"),fs=require("node:fs/promises"),os=require("node:os"),path=require("node:path"),{pathToFileURL}=require("node:url");
let playwright;try{playwright=require("playwright");}catch(error){if(!process.env.CODEX_PRIMARY_RUNTIME_NODE_MODULES)throw error;playwright=require(path.join(process.env.CODEX_PRIMARY_RUNTIME_NODE_MODULES,"playwright"));}
let browser;
before(async()=>{browser=await playwright.chromium.launch({headless:true,...(process.env.RETROBOX_CHROMIUM?{executablePath:process.env.RETROBOX_CHROMIUM}:{})});});
after(async()=>{await browser?.close();});
async function open(fn,options={}){const context=await browser.newContext({locale:"pt-BR",viewport:{width:1440,height:1000},...options}),page=await context.newPage(),errors=[];page.setDefaultTimeout(8000);page.on("pageerror",e=>errors.push(e.message));try{await page.goto(pathToFileURL(path.join(__dirname,"../index.html")).href);await fn(page,context);assert.deepEqual(errors,[]);}finally{await context.close();}}
async function change(page,selector,value){await page.locator(selector).fill(value);await page.locator(selector).dispatchEvent("change");}
async function download(page,click){const pending=page.waitForEvent("download");await click();const item=await pending,temp=await fs.mkdtemp(path.join(os.tmpdir(),"retrobox-download-"));try{const file=path.join(temp,item.suggestedFilename());await item.saveAs(file);return {name:item.suggestedFilename(),text:await fs.readFile(file,"utf8")};}finally{await fs.rm(temp,{recursive:true,force:true});}}
async function wires(page,count){await page.waitForFunction(n=>document.querySelectorAll(".flow-edge").length===n,count);}
test("offline HTML loads actual components and simulates values and events",async()=>open(async page=>{
 const requests=[];page.on("request",r=>{if(/^https?:/.test(r.url()))requests.push(r.url());});
 assert.equal(await page.locator(".component-tile").count(),22);await page.locator("[data-action=simulate]").click();await page.locator('[data-control-id="amount"] input[type=range]').fill("63");assert.match(await page.locator('[data-control-id="summary"]').textContent(),/Quantidade: 63/);await page.locator('[data-control-id="run"] .rb-action').click();assert.match(await page.locator("#event-log").textContent(),/Você acionou um evento visual/);assert.deepEqual(requests,[]);
}));
test("add edit duplicate delete undo and JSON/Luau round trip retain the design",async()=>open(async page=>{
 await page.locator('.component-tile[data-add="Input"]').click();await change(page,'#inspector [data-field="Title"]',"Nome personalizado");
 await page.locator("[data-action=duplicate]").click();assert.equal(await page.locator('[data-control-id^="input"]').count(),2);await page.locator("[data-action=delete]").click();assert.equal(await page.locator('[data-control-id^="input"]').count(),1);await page.locator("[data-action=undo]").click();assert.equal(await page.locator('[data-control-id^="input"]').count(),2);
 const json=await download(page,()=>page.locator("[data-action=save]").click()),p=JSON.parse(json.text);assert.equal(p.Kind,"RetroBoxDesignerProject");assert.equal(p.Tabs[0].Sections[0].Controls.filter(c=>c.Type==="Input").length,2);
 await page.locator("[data-action=export]").click();const lua=await download(page,()=>page.getByRole("button",{name:"Baixar .lua",exact:true}).click());assert.match(lua.text,/Nome personalizado/);assert.match(lua.text,/dist\/bootstrap\/v2.lua/);await page.locator("[data-action=close-modal]").click();
 await page.locator("#project-file").setInputFiles({name:"round-trip.json",mimeType:"application/json",buffer:Buffer.from(json.text)});assert.equal(await page.locator('[data-control-id^="input"]').count(),2);
}));
test("form field editor and nested selection work and Cancel restores drafts",async()=>open(async page=>{
 await page.locator('.component-tile[data-add="Form"]').click();await page.locator('[data-action="edit-fields"]').click();await page.getByRole("button",{name:"Adicionar campo",exact:true}).click();const count=await page.locator("[data-form-field]").count();await change(page,'[data-field="field-title-'+(count-1)+'"]',"Meu campo novo");await page.locator("#modal").getByRole("button",{name:"Aplicar",exact:true}).click();
 assert.match(await page.locator('[data-control-id="form"]').textContent(),/Meu campo novo/);await page.locator('[data-control-id="form"] [data-control-id]').last().click();assert.equal(await page.locator('[data-action="edit-fields"]').count(),1);
 await page.locator("[data-action=simulate]").click();await page.locator('[data-control-id="form"] input[type=text]').last().fill("rascunho");await page.locator('[data-control-id="form"] .rb-form-buttons button').last().click();assert.equal(await page.locator('[data-control-id="form"] input[type=text]').last().inputValue(),"");
}));
test("visual ports reject incompatible connections and create numeric bindings",async()=>open(async page=>{
 await page.locator('[data-view="flow"]').click();assert.equal(await page.locator(".flow-node").count(),5);await wires(page,3);
 await page.getByRole("button",{name:"click output Then",exact:true}).click();await page.getByRole("button",{name:"format input Value",exact:true}).click();assert.match(await page.locator("#toast").textContent(),/incompatíveis/);await wires(page,3);
 await page.locator("#block-type").selectOption("Constant");await page.getByRole("button",{name:"+ Bloco",exact:true}).click();await page.locator("#block-type").selectOption("Binding");await page.getByRole("button",{name:"+ Bloco",exact:true}).click();await page.locator('#inspector [data-field="Control"]').selectOption("amount");
 await page.getByRole("button",{name:"constant output Value",exact:true}).click();await page.getByRole("button",{name:"binding input Value",exact:true}).click();await wires(page,4);assert.equal(await page.locator("[data-action=export]").isEnabled(),true);
 const head=page.locator('[data-node-id="constant"] .flow-node-head'),box=await head.boundingBox();await page.mouse.move(box.x+50,box.y+10);await page.mouse.down();await page.mouse.move(box.x+130,box.y+75,{steps:5});await page.mouse.up();
 const json=await download(page,()=>page.locator("[data-action=save]").click());assert.notDeepEqual(JSON.parse(json.text).Flow.Nodes.find(n=>n.Id==="constant").Position,{X:660,Y:300});
}));
test("manual translation updates preview and invalid placeholders are rejected",async()=>open(async page=>{
 await page.locator('[data-view="translations"]').click();await change(page,'textarea[aria-label="amount.Title en-US"]',"Quantity");await page.locator("#preview-language").selectOption("en-US");await page.locator('[data-view="interface"]').click();assert.match(await page.locator('[data-control-id="amount"]').textContent(),/Quantity/);
 await page.locator('[data-view="translations"]').click();await change(page,'textarea[aria-label="flow.format.Text en-US"]',"Value {wrong}");assert.match(await page.locator("#toast").textContent(),/parâmetros/);assert.equal(await page.locator("[data-action=export]").isEnabled(),true);
}));
test("optional translator only sends registered message records after explicit action",async()=>open(async page=>{
 await page.locator('.component-tile[data-add="Input"]').click();let payload,count=0;
 await page.route("https://translate.invalid/**",async route=>{if(route.request().method()==="OPTIONS"){await route.fulfill({status:204,headers:{"Access-Control-Allow-Origin":"*","Access-Control-Allow-Methods":"POST","Access-Control-Allow-Headers":"content-type"}});return;}count++;payload=route.request().postDataJSON();await route.fulfill({contentType:"application/json",headers:{"Access-Control-Allow-Origin":"*"},body:JSON.stringify({translations:Object.fromEntries(payload.entries.map(e=>[e.key,"EN "+e.text]))})});});
 await page.locator('[data-view="translations"]').click();await page.getByRole("button",{name:"Coletar textos",exact:true}).click();assert.equal(count,0);await page.getByRole("textbox",{name:"Translation endpoint",exact:true}).fill("https://translate.invalid/translate");await page.getByRole("button",{name:"Traduzir pendentes",exact:true}).click();await page.waitForFunction(()=>document.querySelector("#toast").textContent.includes("adicionadas"));
 assert.equal(count,1);assert.equal(payload.sourceLocale,"pt-BR");assert.ok(payload.entries.every(e=>Object.keys(e).sort().join()==="context,key,text"));const json=await download(page,()=>page.locator("[data-action=save]").click());assert.equal(JSON.parse(json.text).providerURL,undefined);assert.equal(JSON.parse(json.text).Translations["input.Title"].Values["en-US"],"EN Nome");
}));
test("invalid import leaves the existing project intact",async()=>open(async page=>{
 await page.locator("#project-file").setInputFiles({name:"bad.json",mimeType:"application/json",buffer:Buffer.from(JSON.stringify({Kind:"RetroBoxDesignerProject",SchemaVersion:1,Tabs:[null]}))});await page.waitForFunction(()=>!document.querySelector("#toast").hidden);assert.equal(await page.locator('[data-control-id="amount"]').count(),1);assert.equal(await page.locator("[data-action=export]").isEnabled(),true);
}));
test("English editor and mobile property drawers remain usable",async()=>open(async page=>{
 await page.locator("#editor-language").selectOption("en-US");assert.equal(await page.getByRole("button",{name:"Export Luau ↗",exact:true}).isVisible(),true);await page.locator('[data-action="toggle-left"]').click();await page.locator('.component-tile[data-add="Label"]').click();await page.locator('[data-action="toggle-right"]').click();assert.equal(await page.locator('#inspector [data-field="Title"]').isVisible(),true);
},{viewport:{width:640,height:850},locale:"en-US"}));
