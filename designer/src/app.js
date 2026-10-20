/* Offline UI: project text is inserted only through DOM APIs. */
(function(){
"use strict";
const C=window.RetroBoxDesignerCore,Simulator=window.RetroBoxDesignerSimulator,catalog=JSON.parse(document.getElementById("designer-catalog").textContent),assets=JSON.parse(document.getElementById("designer-assets").textContent),$=s=>document.querySelector(s),storageKey="retrobox-designer-project-v1";
function localRead(key){try{return localStorage.getItem(key);}catch(_){return null;}}
let language=localRead("retrobox-designer-language")||(navigator.language.toLowerCase().startsWith("pt")?"pt-BR":"en-US");
const words={
 tagline:["Monte. Conecte. Exporte.","Build. Connect. Export."],offline:["Funciona offline","Works offline"],help:["Ajuda","Help"],new:["Novo","New"],open:["Abrir JSON","Open JSON"],save:["Salvar JSON","Save JSON"],duplicate:["Duplicar","Duplicate"],delete:["Excluir","Delete"],components:["Componentes","Components"],properties:["Propriedades","Properties"],structure:["Estrutura","Structure"],test:["▶ Testar","▶ Test"],stop:["■ Parar teste","■ Stop test"],export:["Exportar Luau ↗","Export Luau ↗"],connections:["Ligações","Connections"],translations:["Traduções","Translations"],events:["Eventos da prévia","Preview events"],clear:["Limpar","Clear"],previewNote:["Prévia web aproximada · confira no Roblox.","Approximate web preview · verify in Roblox."],
 title:["Título","Title"],description:["Descrição","Description"],value:["Valor inicial","Initial value"],placeholder:["Texto de exemplo","Placeholder"],text:["Texto","Text"],icon:["Ícone","Icon"],theme:["Tema","Theme"],locale:["Idioma","Language"],sourceLocale:["Idioma de origem","Source language"],visible:["Visível","Visible"],disabled:["Desabilitado","Disabled"],translate:["Traduzir","Translate"],apply:["Aplicar","Apply"],cancel:["Cancelar","Cancel"],addTab:["+ Aba","+ Tab"],addSection:["+ Seção","+ Section"],addBlock:["+ Bloco","+ Block"],addState:["+ Estado","+ State"],control:["Componente","Control"],state:["Estado","State"],property:["Propriedade","Property"],action:["Nome da ação","Action name"],
 advancedJSON:["Propriedades avançadas (JSON)","Advanced properties (JSON)"],applyJSON:["Aplicar JSON","Apply JSON"],saveTemplate:["Salvar como componente","Save as component"],download:["Baixar","Download"],copy:["Copiar","Copy"],collect:["Coletar textos","Collect text"],providerRun:["Traduzir pendentes","Translate missing"],required:["Obrigatório","Required"],
 formPending:["Rascunho · aplique para confirmar","Draft · apply to confirm"],valid:["Projeto válido","Project valid"],issues:["Validação do projeto","Project validation"],saved:["Salvo neste navegador","Saved in this browser"],localOnly:["Use Salvar JSON para guardar o projeto","Use Save JSON to keep the project"]
};
const T=(pt,en)=>en!==undefined?(language==="en-US"?en:pt):words[pt]?.[language==="en-US"?1:0]||pt;
function el(tag,attrs={},...children){
 const n=document.createElement(tag);
 for(const [k,v]of Object.entries(attrs)){
  if(k==="on")for(const [event,fn]of Object.entries(v))n.addEventListener(event,fn);
  else if(k==="dataset")for(const [key,value]of Object.entries(v))n.dataset[key]=value;
  else if(k==="text")n.textContent=v;else if(k==="class")n.className=v;else if(k==="style")Object.assign(n.style,v);
  else if(v!==undefined&&v!==null&&v!==false){if(k in n&&!k.startsWith("aria-"))n[k]=v;else n.setAttribute(k,v===true?"":v);}
 }
 for(const c of children.flat())if(c!==undefined&&c!==null)n.append(c instanceof Node?c:document.createTextNode(String(c)));return n;
}
function icon(name){
 const svg=document.createElementNS("http://www.w3.org/2000/svg","svg"),rows=assets.Icons[name]||assets.Icons.code;svg.setAttribute("viewBox","0 0 "+rows[0].length+" "+rows.length);svg.setAttribute("class","pixel-icon");svg.setAttribute("aria-hidden","true");
 const colors={"#":"currentColor",a:"var(--rb-Accent,currentColor)",h:"var(--rb-Highlight,currentColor)",s:"var(--rb-Shadow,currentColor)",m:"var(--rb-Muted,currentColor)",g:"var(--rb-Success,currentColor)",r:"var(--rb-Danger,currentColor)"};
 rows.forEach((row,y)=>[...row].forEach((cell,x)=>{if(cell===".")return;const r=document.createElementNS(svg.namespaceURI,"rect");for(const [key,value]of Object.entries({x,y,width:1,height:1,fill:colors[cell]||"currentColor"}))r.setAttribute(key,value);svg.append(r);}));return svg;
}
const componentIcons={Toggle:"check",Slider:"sliders",Button:"play",Input:"edit",Dropdown:"chevron-down",ColorPicker:"palette",Label:"info",Separator:"minus",Progress:"chart",StatCard:"diamond",Chart:"chart",Console:"terminal",Image:"image",VirtualList:"list",DataTable:"grid",TreeView:"folder",Preview:"eye",Stepper:"check",CardGrid:"grid",Form:"save",Keybind:"keyboard",Row:"grid",Component:"box"};
function starter(){
 const p=C.collectTranslations(C.newProject()),reviewed={"Meu projeto":"My project","Monte, conecte e exporte":"Build, connect and export",Principal:"Main",Controles:"Controls","Ativar recurso":"Enable feature",Quantidade:"Amount","Quantidade: 25":"Amount: 25",Executar:"Run","Quantidade: {value}":"Amount: {value}","Você acionou um evento visual.":"You triggered a visual event."};
 for(const entry of Object.values(p.Translations))if(reviewed[entry.Source])entry.Values["en-US"]=reviewed[entry.Source];return p;
}
const S={project:starter(),selected:{kind:"window",id:""},view:"interface",left:"components",history:[],redo:[],tab:"principal",testing:false,simulator:null,wire:null,query:"",previewLocale:language,exportMode:"standalone",providerBusy:false};
try{const raw=localRead(storageKey);if(raw){const r=C.validateProject(JSON.parse(raw),catalog,{allowDraft:true});if(r.ok){S.project=r.project;S.tab=S.project.Tabs[0].Id;}}}catch(_){}
function toast(message,error=false){const n=$("#toast");n.textContent=message;n.className=error?"error":"";n.hidden=false;clearTimeout(toast.timer);toast.timer=setTimeout(()=>n.hidden=true,5000);}
function current(){if(S.selected.kind==="window")return {node:S.project.Window,kind:"window"};if(S.selected.kind==="flow")return {node:S.project.Flow.Nodes.find(n=>n.Id===S.selected.id),kind:"flow"};if(S.selected.kind==="state")return {node:S.project.States.find(n=>n.Id===S.selected.id),kind:"state"};return C.find(S.project,S.selected.id);}
function ids(p=S.project){const set=new Set();C.walk(p,n=>{if(n)set.add(n.Id);});return set;}
function unique(prefix,set){const base=String(prefix).normalize("NFD").replace(/[\u0300-\u036f]/g,"").replace(/[^A-Za-z0-9_-]/g,"-").toLowerCase().slice(0,45)||"item";let id=base,i=2;while(set.has(id))id=base+"-"+i++;return id;}
function saveSoon(){clearTimeout(S.saveTimer);S.saveTimer=setTimeout(()=>{try{localStorage.setItem(storageKey,JSON.stringify(S.project));$("#save-status").textContent=T("saved")+" · "+new Date().toLocaleTimeString();}catch(_){$("#save-status").textContent=T("localOnly");}},180);}
function rebuildSimulator(){if(!S.testing){S.simulator=null;return;}try{S.simulator=new Simulator(S.project,catalog,S.previewLocale,updatePreviewState);}catch(e){S.testing=false;S.simulator=null;toast(e.message,true);}}
function commit(fn){
 try{const next=C.clone(S.project);fn(next);C.syncTextSources(next);const r=C.validateProject(next,catalog,{allowDraft:true});if(!r.ok)throw Error(r.errors.map(e=>e.message).join("\n"));
 S.history.push(JSON.stringify(S.project));while(S.history.length>30||S.history.length>1&&S.history.reduce((sum,s)=>sum+s.length,0)>6291456)S.history.shift();S.redo=[];S.project=r.project;rebuildSimulator();renderAll();saveSoon();return true;
 }catch(e){toast(e.message,true);return false;}
}
function select(kind,id){S.selected={kind,id};renderLibrary();renderInspector();renderSelection();renderStatus();}
function chooseTab(){return S.project.Tabs.find(t=>t.Id===S.tab)||S.project.Tabs[0];}
function chooseSection(p=S.project){const c=C.find(p,S.selected.id);if(c?.kind==="section")return c.node;if(c?.kind==="control")return c.parent;const tab=p.Tabs.find(t=>t.Id===S.tab)||p.Tabs[0];return tab.Sections.at(-1);}
function addControl(type,parentId,index){
 let created;
 if(!catalog.Controls[type]&&type!=="Row")return;
 const ok=commit(p=>{let parent=parentId?C.find(p,parentId)?.node:chooseSection(p);if(!parent){parent={Id:unique("section",ids(p)),Title:T("Nova seção","New section"),Controls:[]};(p.Tabs.find(t=>t.Id===S.tab)||p.Tabs[0]).Sections.push(parent);}
 if(parent.Type&&parent.Type!=="Row")parent=C.find(p,parent.Id).parent;if(parent.Type==="Row"&&["Row","Form"].includes(type))throw Error(T("Use uma seção para este componente.","Use a section for this component."));
 created=unique(type,ids(p));const n={Id:created,Type:type,Options:C.clone(catalog.Controls[type]?.Defaults||{})};if(type==="Row")n.Children=[];
 const list=parent.Type==="Row"?parent.Children:parent.Controls;list.splice(index===undefined?list.length:index,0,n);});
 if(ok)select("control",created);
}
function addTab(){let id;commit(p=>{id=unique("aba",ids(p));p.Tabs.push({Id:id,Title:T("Nova aba","New tab"),Columns:1,Sections:[]});});if(id){S.tab=id;select("tab",id);renderWorkspace();}}
function addSection(){let id;commit(p=>{id=unique("section",ids(p));(p.Tabs.find(t=>t.Id===S.tab)||p.Tabs[0]).Sections.push({Id:id,Title:T("Nova seção","New section"),Controls:[]});});if(id)select("section",id);}
function renderLanguage(){document.documentElement.lang=language;$("#editor-language").value=language;for(const n of document.querySelectorAll("[data-word]"))n.textContent=T(n.dataset.word);$("[data-action=simulate]").textContent=T(S.testing?"stop":"test");$("#project-name").textContent=S.project.Window.Title;}
function renderLibrary(){
 const panel=$("#library-panel");panel.replaceChildren();document.querySelectorAll("[data-left]").forEach(n=>n.classList.toggle("active",n.dataset.left===S.left));
 if(S.left==="structure"){
  function row(n,kind,depth){const label=n.Options?.Title||n.Title||n.Id;return el("button",{class:"outline"+(S.selected.id===n.Id&&S.selected.kind===kind?" active":""),style:{paddingLeft:8+depth*12+"px"},on:{click:()=>{if(kind==="tab")S.tab=n.Id;select(kind,kind==="window"?"":n.Id);renderWorkspace();}}},icon(componentIcons[n.Type]||"folder"),el("span",{text:label}),el("small",{text:n.Type||kind}));}
  panel.append(row(S.project.Window,"window",0));C.walk(S.project,(n,parent,kind)=>{if(n)panel.append(row(n,kind,kind==="tab"?0:kind==="section"?1:parent?.Type==="Row"?3:2));});panel.append(el("div",{class:"group-title",text:T("state")}));for(const s of S.project.States)panel.append(row(s,"state",0));panel.append(el("button",{text:T("addState"),on:{click:addState}}));return;
 }
 panel.append(el("input",{class:"library-search",type:"search",placeholder:T("Pesquisar componentes…","Search components…"),value:S.query,on:{input:e=>{S.query=e.target.value;renderGroups();}}}),el("div",{class:"structure-actions"},el("button",{text:T("addTab"),on:{click:addTab}}),el("button",{text:T("addSection"),on:{click:addSection}})),el("div",{id:"component-groups"}),el("p",{class:"panel-note",text:T("Clique para adicionar ou arraste para uma seção. Selecione para editar.","Click to add or drag into a section. Select to edit.")}));renderGroups();
}
function renderGroups(){
 const root=$("#component-groups");if(!root)return;root.replaceChildren();
 const groups=[[T("Essenciais","Essentials"),["Toggle","Slider","Button","Input","Dropdown","ColorPicker","Label","Separator"]],[T("Dados e visualizações","Data and views"),["StatCard","Progress","Chart","CardGrid","VirtualList","DataTable"]],[T("Avançados","Advanced"),["Form","TreeView","Preview","Stepper","Console","Image","Keybind","Row"]]];
 for(const [title,list]of groups){const visible=list.filter(s=>s.toLowerCase().includes(S.query.toLowerCase()));if(!visible.length)continue;const grid=el("div",{class:"component-list"});root.append(el("div",{class:"group-title",text:title}),grid);
 for(const type of visible)grid.append(el("button",{class:"component-tile",draggable:true,dataset:{add:type},title:type,on:{click:()=>addControl(type),dragstart:e=>{e.dataTransfer.setData("application/x-retrobox",JSON.stringify({type}));e.dataTransfer.effectAllowed="copy";}}},icon(componentIcons[type]),el("span",{text:type})));
 }
 if(S.project.Templates.length){root.append(el("div",{class:"group-title",text:T("Seus componentes","Your components")}));for(const template of S.project.Templates)root.append(el("button",{class:"component-tile",text:template.Title||template.Id,on:{click:()=>{let id;commit(p=>{const section=chooseSection(p);if(!section)throw Error(T("Adicione uma seção.","Add a section."));id=unique(template.Id,ids(p));(section.Type==="Row"?section.Children:section.Controls).push({Id:id,Type:"Component",Template:template.Id,Props:{}});});if(id)select("control",id);}}}));}
}
function displayText(n,prop,fallback){if(n.Options?.Translate===false)return fallback??"";const locale=S.testing&&S.simulator?S.simulator.locale:S.previewLocale,explicit=n.TextKeys?.[prop],key=explicit&&S.project.Translations[explicit]?.Source===fallback?explicit:Object.keys(S.project.Translations).find(k=>S.project.Translations[k].Source===fallback);return key?C.translation(S.project,key,locale):fallback??"";}
function renderWorkspace(){
 document.querySelectorAll("[data-view]").forEach(n=>n.classList.toggle("active",n.dataset.view===S.view));const root=$("#workspace-body");root.replaceChildren();
 if(S.view==="interface")renderInterface(root);else if(S.view==="flow")renderFlow(root);else renderTranslations(root);$("#simulation-console").hidden=!S.testing;renderConsole();
}
function renderInterface(root){
 const w=S.project.Window,palette=assets.Themes[w.Theme]||assets.Themes.Hacker,stage=el("div",{class:"preview-stage"}),view=el("div",{class:"preview-window",dataset:{nodeId:"",nodeKind:"window"},style:{zoom:$("#zoom").value,width:($("#device").value==="phone"?380:$("#device").value==="tablet"?650:w.Size?.X||790)+"px",minHeight:(w.Size?.Y||570)+"px"},on:{click:()=>{if(!S.testing)select("window","");}}});
 for(const [key,value]of Object.entries(palette))view.style.setProperty("--rb-"+key,value);
 view.append(el("div",{class:"rb-topbar"},el("div",{},el("div",{class:"rb-window-title",text:displayText(w,"Title",w.Title)}),el("div",{class:"rb-subtitle",text:displayText(w,"Subtitle",w.Subtitle)})),el("span",{text:"−  □  ×"})));
 const tabs=el("div",{class:"rb-tabs"});for(const tab of S.project.Tabs)tabs.append(el("button",{class:tab.Id===chooseTab().Id?"active":"",on:{click:e=>{e.stopPropagation();S.tab=tab.Id;renderWorkspace();}}},icon(tab.Icon||"grid"),displayText(tab,"Title",tab.Title)));view.append(tabs);
 const active=chooseTab(),content=el("div",{class:"rb-content",style:{gridTemplateColumns:active.Columns===2&&$("#device").value!=="phone"?"1fr 1fr":"1fr"}});
 for(const section of active.Sections){
  const frame=el("section",{class:"rb-section",dataset:{nodeId:section.Id,nodeKind:"section"},on:{click:e=>{if(!S.testing){e.stopPropagation();select("section",section.Id);}}}}),heading=el("div",{class:"rb-section-title"},icon(section.Icon||"folder"),displayText(section,"Title",section.Title)),drop=el("div",{class:"drop-target",dataset:{parentId:section.Id}});
  setupDrop(drop);for(const n of section.Controls)drop.append(renderControl(n));if(!section.Controls.length)drop.append(el("div",{class:"drop-empty",text:T("Solte componentes aqui","Drop components here")}));frame.append(heading,drop);content.append(frame);
 }
 view.append(content);stage.append(view);root.append(stage);updatePreviewState();renderSelection();
}
function selectControl(id){while(!C.find(S.project,id)&&id.includes("/"))id=id.slice(0,id.lastIndexOf("/"));select("control",id);}
function renderControl(n,nested=false){
 const o=n.Options||{},sim=S.simulator,value=sim?.values[n.Id]??C.defaultValue(n),box=el("div",{class:"rb-component",dataset:{nodeId:n.Id,nodeKind:"control",controlId:n.Id},on:{click:e=>{if(!S.testing){e.stopPropagation();selectControl(n.Id);}}}});
 if(n.Type==="Row"){box.classList.add("rb-row","drop-target");box.dataset.parentId=n.Id;setupDrop(box);for(const child of n.Children)box.append(renderControl(child,true));if(!n.Children.length)box.append(el("div",{class:"drop-empty",text:T("Solte componentes aqui","Drop components here")}));if(!nested)setupMove(box,n);return box;}
 if(n.Type==="Component"){const t=S.project.Templates.find(t=>t.Id===n.Template);for(const child of t?.Controls||[])box.append(renderControl({...child,Id:n.Id+"/"+child.Id,Options:{...child.Options,...n.Props?.[child.Id]}},true));if(!nested)setupMove(box,n);return box;}
 const title=()=>el("div",{class:"rb-component-title"},...(o.Icon?[icon(o.Icon)]:[]),displayText(n,"Title",o.Title||n.Type)),set=v=>{if(S.testing)sim?.setControl(n.Id,v);},action=(text,fn)=>el("button",{class:"rb-action",text,on:{click:e=>{if(S.testing){e.stopPropagation();fn();}}}});
 if(!["Toggle","Separator"].includes(n.Type))box.append(title());if(o.Description)box.append(el("div",{class:"rb-description",text:displayText(n,"Description",o.Description)}));
 if(n.Type==="Toggle")box.append(el("div",{class:"rb-toggle-line"},title(),el("button",{class:"rb-toggle",text:value?"✓":"","aria-label":o.Title||"Toggle",on:{click:e=>{if(S.testing){e.stopPropagation();set(!sim?.values[n.Id]);}}}})));
 else if(n.Type==="Slider")box.append(el("input",{type:"range",min:o.Min,max:o.Max,step:o.Step||1,value:value??o.Min,"aria-label":o.Title,on:{input:e=>set(Number(e.target.value))}}),el("small",{class:"rb-slider-value",text:String(value)+(o.Suffix||"")}));
 else if(n.Type==="Input")box.append(el(o.Multiline?"textarea":"input",{type:"text",value:value||"",placeholder:displayText(n,"Placeholder",o.Placeholder||""),maxLength:o.MaxLength||2048,"aria-label":o.Title,on:{input:e=>set(e.target.value)}}));
 else if(n.Type==="Dropdown"){const input=el("select",{multiple:!!o.Multi,"aria-label":o.Title,on:{change:e=>set(o.Multi?[...e.target.selectedOptions].map(x=>x.value):e.target.value)}});for(const item of o.Options||[])input.append(el("option",{value:item,text:item,selected:o.Multi?Array.isArray(value)&&value.includes(item):value===item}));box.append(input);}
 else if(n.Type==="ColorPicker")box.append(el("input",{type:"color",value:typeof value==="string"&&/^#[0-9a-f]{6}$/i.test(value)?value:"#32df7b","aria-label":o.Title,on:{input:e=>set(e.target.value)}}));
 else if(n.Type==="Button")box.append(action(displayText(n,"Text",o.Text||o.Title||"Run"),()=>sim?.click(n.Id)));
 else if(n.Type==="Keybind")box.append(el("div",{class:"rb-stat"},el("strong",{text:o.Default||"F"}),el("small",{text:o.Mode||"Press"})));
 else if(n.Type==="StatCard")box.append(el("div",{class:"rb-stat"},el("strong",{class:"rb-stat-value",text:value??"—"}),el("small",{text:o.Unit||""})));
 else if(n.Type==="Progress"){const percent=Math.max(0,Math.min(100,(Number(value)-(o.Min||0))/((o.Max||100)-(o.Min||0))*100));box.append(el("div",{class:"rb-progress"},el("i",{style:{width:percent+"%"}}),el("span",{text:Math.round(percent)+"%"})));}
 else if(n.Type==="Separator")box.append(el("div",{class:"rb-section-title",text:displayText(n,"Title",o.Title||"")}));
 else if(n.Type==="Console")box.append(el("textarea",{readOnly:true,rows:4,value:typeof value==="string"?value:"","aria-label":o.Title}));
 else if(n.Type==="Chart"){
  const svg=document.createElementNS("http://www.w3.org/2000/svg","svg"),path=document.createElementNS(svg.namespaceURI,"path");svg.setAttribute("viewBox","0 0 300 120");svg.setAttribute("class","rb-chart");const data=(o.Data||[]).map(x=>typeof x==="number"?x:x.Value).filter(Number.isFinite),max=Math.max(1,...data);
  path.setAttribute("d",data.map((x,i)=>(i?"L":"M")+(10+i*280/Math.max(1,data.length-1))+","+(110-x/max*95)).join(" "));path.setAttribute("fill","none");path.setAttribute("stroke","var(--rb-Accent)");path.setAttribute("stroke-width",3);svg.append(path);box.append(svg);
 }else if(["Image","Preview"].includes(n.Type)){const frame=el("div",{class:"rb-image-preview"});if(typeof o.Image==="string"&&o.Image.startsWith("https://"))frame.append(el("img",{src:o.Image,alt:o.Title||""}));else frame.append(icon("image"),T("Asset Roblox · confira no cliente","Roblox asset · verify in the client"));box.append(frame);}
 else if(n.Type==="Stepper")for(const [i,step]of (o.Steps||[]).entries())box.append(el("div",{class:"rb-step",text:(i+1)+". "+(typeof step==="string"?step:step.Title)}));
 else if(n.Type==="CardGrid"){const grid=el("div",{class:"rb-grid"});for(const item of (o.Items||[]).slice(0,12))grid.append(el("div",{class:"rb-card"+(value===item.Id?" selected-card":""),dataset:{cardId:item.Id},on:{click:e=>{if(S.testing&&item.Enabled!==false){e.stopPropagation();set(item.Id);}}}},el("div",{class:"rb-card-head"},icon(item.Icon||"grid"),el("strong",{text:item.Title||item.Id})),el("p",{text:item.Description||""}),el("div",{class:"rb-badges",text:(item.Badges||[]).join(" · ")})));box.append(grid);}
 else if(n.Type==="VirtualList"){const list=el("div",{class:"rb-small-list"});for(const [i,item]of (o.Items||[]).slice(0,25).entries())list.append(el("div",{text:item.Text||item.Title||item.Id||i+1,on:{click:()=>set(String(item.Id??item.Key??i+1))}}));box.append(list);}
 else if(n.Type==="DataTable"){const table=el("table",{class:"rb-table"},el("tr",{},...(o.Columns||[]).map(c=>el("th",{text:c.Title||c.Key}))));for(const row of (o.Rows||[]).slice(0,10))table.append(el("tr",{on:{click:()=>set(String(row.Id))}},...(o.Columns||[]).map(c=>el("td",{text:row[c.Key]??"—"}))));box.append(table);}
 else if(n.Type==="TreeView"){const list=el("div",{class:"rb-small-list"});function tree(nodes,depth){for(const child of nodes||[]){list.append(el("div",{text:(child.Children?.length?"▾ ":"· ")+(child.Text||child.Title||child.Id),style:{paddingLeft:8+depth*13+"px"},on:{click:()=>set(child.Id)}}));tree(child.Children,depth+1);}}tree(o.Nodes,0);box.append(list);}
 else if(n.Type==="Form"){const form=el("div",{class:"rb-form"});for(const field of o.Fields||[])form.append(renderControl({Id:n.Id+"/"+field.Id,Type:field.Type,Options:field,TextKeys:field.TextKeys},true));form.append(el("small",{text:T("formPending")}),el("div",{class:"rb-form-buttons"},action(T("apply"),()=>sim?.applyForm(n.Id)),action(T("cancel"),()=>{sim?.cancelForm(n.Id);renderWorkspace();})));box.append(form);}
 if(!nested)setupMove(box,n);return box;
}
function renderSelection(){document.querySelectorAll("[data-node-id]").forEach(n=>n.classList.toggle("selected",n.dataset.nodeId===S.selected.id&&n.dataset.nodeKind===S.selected.kind));}
function updatePreviewState(){
 const sim=S.simulator;if(!S.testing||!sim){renderConsole();return;}
 for(const element of document.querySelectorAll("[data-control-id]")){
  const id=element.dataset.controlId,n=sim.controls[id],view=sim.views[id]||{},value=sim.values[id];if(!n)continue;element.hidden=view.Visible===false;
  for(const input of element.querySelectorAll(":scope > input,:scope > select,:scope > button,:scope > .rb-toggle-line > button,:scope > .rb-form > .rb-form-buttons > button"))input.disabled=!sim.available(id);
  const title=element.querySelector(":scope > .rb-component-title");if(title&&view.Title!==undefined)title.textContent=view.Title;
  if(n.Type==="Label"&&title)title.textContent=String(value??"");
  if(n.Type==="Slider"){const input=element.querySelector("input"),text=element.querySelector(".rb-slider-value");if(input&&document.activeElement!==input)input.value=value;if(text)text.textContent=String(value)+(n.Options?.Suffix||"");}
  if(n.Type==="Toggle")element.querySelector(".rb-toggle").textContent=value?"✓":"";
  if(n.Type==="StatCard")element.querySelector(".rb-stat-value").textContent=String(value??"—");
  if(n.Type==="Progress"){const percent=Math.max(0,Math.min(100,(Number(value)-(n.Options?.Min||0))/((n.Options?.Max||100)-(n.Options?.Min||0))*100));element.querySelector(".rb-progress i").style.width=percent+"%";element.querySelector(".rb-progress span").textContent=Math.round(percent)+"%";}
  if(n.Type==="Button"&&view.Text!==undefined)element.querySelector(".rb-action").textContent=view.Text;
  if(n.Type==="CardGrid")element.querySelectorAll("[data-card-id]").forEach(card=>card.classList.toggle("selected-card",card.dataset.cardId===value));
 }
 renderConsole();
}
function renderConsole(){const root=$("#event-log");root.replaceChildren();for(const e of S.simulator?.logs||[])root.append(el("div",{class:e.kind},el("time",{text:e.time}),e.message));root.scrollTop=root.scrollHeight;}
function setupMove(element,n){element.draggable=!S.testing;element.addEventListener("dragstart",e=>{if(S.testing)return;e.stopPropagation();e.dataTransfer.setData("application/x-retrobox",JSON.stringify({move:n.Id}));});}
function setupDrop(element){
 element.addEventListener("dragover",e=>{if(!S.testing){e.preventDefault();e.stopPropagation();element.classList.add("drag-over");}});element.addEventListener("dragleave",()=>element.classList.remove("drag-over"));
 element.addEventListener("drop",e=>{e.preventDefault();e.stopPropagation();element.classList.remove("drag-over");if(S.testing)return;let data;try{data=JSON.parse(e.dataTransfer.getData("application/x-retrobox"));}catch(_){return;}
 const parentId=element.dataset.parentId,hover=e.target.closest("[data-node-id]"),children=[...element.children].filter(c=>c.dataset.nodeId),index=hover?.parentElement===element?children.indexOf(hover):undefined;
 if(data.type)addControl(data.type,parentId,index);else if(data.move)commit(p=>{const from=C.find(p,data.move),parent=C.find(p,parentId)?.node;if(!from||from.kind!=="control"||!parent||parent.Id===from.node.Id||parent.Type==="Row"&&["Row","Form"].includes(from.node.Type))throw Error(T("Destino inválido.","Invalid target."));
 const old=from.parent.Type==="Row"?from.parent.Children:from.parent.Controls,list=parent.Type==="Row"?parent.Children:parent.Controls;old.splice(old.indexOf(from.node),1);list.splice(index===undefined?list.length:Math.max(0,index),0,from.node);});});
}
function property(label,key,value,callback,type="text",choices){
 const wrapper=el("label",{class:"property-field"+(type==="checkbox"?" inline":"")},el("span",{text:label}));let input;
 if(choices){input=el("select",{dataset:{field:key},on:{change:e=>callback(e.target.value)}});for(const item of choices){const c=typeof item==="object"?item:{value:item,text:item};input.append(el("option",{value:c.value,text:c.text,selected:String(value??"")===String(c.value)}));}}
 else input=el(type==="textarea"?"textarea":"input",{type:type==="textarea"?undefined:type,value:type==="checkbox"?undefined:value??"",checked:type==="checkbox"?!!value:undefined,dataset:{field:key},on:{change:e=>callback(type==="checkbox"?e.target.checked:type==="number"?Number(e.target.value):e.target.value)}});
 wrapper.append(input);return wrapper;
}
function changeNode(field,value,option=false){const selected={...S.selected};commit(p=>{const target=selected.kind==="window"?p.Window:selected.kind==="flow"?p.Flow.Nodes.find(n=>n.Id===selected.id):selected.kind==="state"?p.States.find(n=>n.Id===selected.id):C.find(p,selected.id)?.node;if(target)(option?(target.Options||={}):target)[field]=value;});}
function renameId(value){
 const selected={...S.selected};const ok=commit(p=>{const n=selected.kind==="window"?p.Window:selected.kind==="flow"?p.Flow.Nodes.find(n=>n.Id===selected.id):selected.kind==="state"?p.States.find(n=>n.Id===selected.id):C.find(p,selected.id)?.node;if(!n)return;n.Id=value;
 if(selected.kind==="flow")for(const e of p.Flow.Edges){if(e.From===selected.id)e.From=value;if(e.To===selected.id)e.To=value;}
 else for(const node of p.Flow.Nodes){if(selected.kind==="state"&&node.State===selected.id)node.State=value;if(selected.kind==="control"&&node.Control&&(node.Control===selected.id||node.Control.startsWith(selected.id+"/")))node.Control=value+node.Control.slice(selected.id.length);}
 });if(ok){if(selected.kind==="tab"&&S.tab===selected.id)S.tab=value;if(selected.kind!=="window")S.selected.id=value;renderAll();}
}
function reorderSelected(delta){const s=current();if(!s||!["tab","section","control"].includes(s.kind))return;commit(p=>{const f=C.find(p,s.node.Id),list=f.kind==="tab"?p.Tabs:f.kind==="section"?f.parent.Sections:f.parent.Type==="Row"?f.parent.Children:f.parent.Controls,index=list.indexOf(f.node),to=index+delta;if(to<0||to>=list.length)return;list.splice(index,1);list.splice(to,0,f.node);});}
function renderInspector(){
 const panel=$("#inspector"),selected=current();panel.replaceChildren();if(!selected?.node){panel.append(el("p",{class:"panel-note",text:T("Selecione um item para editar.","Select an item to edit.")}));return;}
 const n=selected.node,kind=selected.kind;panel.append(el("h2",{class:"property-title",text:kind==="window"?T("Janela","Window"):n.Type||kind}),el("div",{class:"property-id",text:n.Id||""}),property("Id","Id",n.Id,renameId));
 if(kind==="window"){
  for(const key of ["Title","Subtitle"])panel.append(property(key==="Title"?T("title"):T("Subtítulo","Subtitle"),key,n[key],v=>changeNode(key,v)));
  panel.append(property(T("theme"),"Theme",n.Theme,v=>changeNode("Theme",v),"text",Object.keys(assets.Themes)),property(T("locale"),"Locale",n.Locale||"auto",v=>changeNode("Locale",v),"text",["auto","pt-BR","en-US"]),property(T("sourceLocale"),"SourceLocale",n.SourceLocale||"pt-BR",v=>changeNode("SourceLocale",v),"text",["pt-BR","en-US"]));
  for(const key of ["X","Y"])panel.append(property(key==="X"?T("Largura","Width"):T("Altura","Height"),"Size."+key,n.Size?.[key]||(key==="X"?790:570),v=>commit(p=>{p.Window.Size||={X:790,Y:570};p.Window.Size[key]=v;}),"number"));
  for(const key of ["ShowProfile","PixelIcons","ReducedMotion"])panel.append(property(T({ShowProfile:"Mostrar perfil",PixelIcons:"Ícones pixel art",ReducedMotion:"Reduzir animações"}[key],{ShowProfile:"Show profile",PixelIcons:"Pixel icons",ReducedMotion:"Reduced motion"}[key]),key,n[key]??key!=="ReducedMotion",v=>changeNode(key,v),"checkbox"));return;
 }
 if(kind==="flow"){renderFlowProperties(panel,n);return;}if(kind==="state"){panel.append(property(T("value")+" (JSON)","Value",JSON.stringify(n.Value,null,2),v=>parseChange("Value",v),"textarea"));return;}
 panel.append(el("div",{class:"property-actions"},el("button",{text:"↑",title:T("Mover para cima","Move up"),on:{click:()=>reorderSelected(-1)}}),el("button",{text:"↓",title:T("Mover para baixo","Move down"),on:{click:()=>reorderSelected(1)}})));
 if(kind==="tab"||kind==="section"){
  panel.append(property(T("title"),"Title",n.Title,v=>changeNode("Title",v)),property(T("icon"),"Icon",n.Icon||"",v=>changeNode("Icon",v||undefined),"text",[{value:"",text:"—"},...catalog.IconNames]));
  if(kind==="tab")panel.append(property(T("Colunas","Columns"),"Columns",String(n.Columns||1),v=>changeNode("Columns",Number(v)),"text",["1","2"]));
  else {panel.append(property(T("Lado","Side"),"Side",n.Side||"Left",v=>changeNode("Side",v),"text",["Left","Right"]));for(const key of ["Collapsible","Collapsed"])panel.append(property(key,key,n[key],v=>changeNode(key,v),"checkbox"));panel.append(el("button",{text:T("saveTemplate"),on:{click:saveTemplate}}));}return;
 }
 if(n.Type==="Component"){panel.append(property(T("Modelo","Template"),"Template",n.Template,v=>changeNode("Template",v),"text",S.project.Templates.map(t=>({value:t.Id,text:t.Title||t.Id}))),property("Props (JSON)","Props",JSON.stringify(n.Props||{},null,2),v=>parseChange("Props",v),"textarea"),el("p",{class:"panel-note",text:T('Substitua opções por Id interno: {"coins":{"Title":"Moedas"}}.','Override options by child Id: {"coins":{"Title":"Coins"}}.')}));return;}
 const o=n.Options||{};
 if(n.Type!=="Row"){for(const key of ["Title","Description"])panel.append(property(T(key==="Title"?"title":"description"),key,o[key]||"",v=>changeNode(key,v,true)));panel.append(property(T("icon"),"Icon",o.Icon||"",v=>changeNode("Icon",v||undefined,true),"text",[{value:"",text:"—"},...catalog.IconNames]));}
 if(["Toggle","Input","Slider","Progress","StatCard","ColorPicker","Keybind"].includes(n.Type))panel.append(property(T("value"),"Default",o.Default,v=>changeNode("Default",v,true),n.Type==="Toggle"?"checkbox":["Slider","Progress","StatCard"].includes(n.Type)?"number":n.Type==="ColorPicker"?"color":"text"));
 if(["Slider","Progress"].includes(n.Type))for(const key of ["Min","Max",...(n.Type==="Slider"?["Step"]:[])])panel.append(property(key,key,o[key]??(key==="Max"?100:key==="Step"?1:0),v=>changeNode(key,v,true),"number"));
 if(["Input","Button"].includes(n.Type)){const key=n.Type==="Input"?"Placeholder":"Text";panel.append(property(T(key==="Text"?"text":"placeholder"),key,o[key]||"",v=>changeNode(key,v,true)));}
 if(n.Type!=="Row")for(const key of ["Visible","Disabled","Translate"])panel.append(property(T({Visible:"visible",Disabled:"disabled",Translate:"translate"}[key]),key,o[key]??key!=="Disabled",v=>changeNode(key,v,true),"checkbox"));
 if(n.Type==="Form")panel.append(el("button",{text:T("Editar campos","Edit fields"),dataset:{action:"edit-fields"},on:{click:()=>editFormFields(n)}}),el("p",{class:"panel-note",text:T("Campos transacionais: edite e aplique para confirmar.","Transactional fields: edit and apply to confirm.")}));
 const json=el("textarea",{value:JSON.stringify(o,null,2),rows:9,dataset:{advancedOptions:n.Id},"aria-label":T("advancedJSON")});panel.append(el("hr",{class:"property-divider"}),el("div",{class:"group-title",text:T("advancedJSON")}),json,el("div",{class:"property-actions"},el("button",{text:T("applyJSON"),on:{click:()=>parseChange("Options",json.value)}})));
}
function parseChange(field,text){try{changeNode(field,JSON.parse(text));}catch(e){toast(e.message,true);}}
function editFormFields(node){
 const fields=C.clone(node.Options.Fields),original=fields.map(f=>f.Id),container=el("div",{class:"form-field-editor"});
 function draw(){container.replaceChildren();fields.forEach((f,i)=>{
 const box=el("fieldset",{dataset:{formField:i}},el("legend",{text:f.Id}));
 box.append(property("Id","field-id-"+i,f.Id,v=>f.Id=v),property(T("Tipo","Type"),"field-type-"+i,f.Type,v=>{fields[i]={...C.clone(catalog.Controls[v].Defaults),Id:f.Id,Type:v,Title:f.Title};draw();},"text",["Input","Toggle","Slider","Dropdown","ColorPicker"]),property(T("title"),"field-title-"+i,f.Title,v=>f.Title=v),property(T("required"),"field-required-"+i,f.Required,v=>f.Required=v,"checkbox"),property(T("value"),"field-default-"+i,f.Default,v=>f.Default=v,f.Type==="Toggle"?"checkbox":f.Type==="Slider"?"number":f.Type==="ColorPicker"?"color":"text"));
 if(f.Type==="Slider")for(const key of ["Min","Max","Step"])box.append(property(key,"field-"+key+"-"+i,f[key],v=>f[key]=v,"number"));
 if(f.Type==="Input")box.append(property(T("placeholder"),"field-placeholder-"+i,f.Placeholder,v=>f.Placeholder=v));
 if(f.Type==="Dropdown")box.append(property(T("Opções (uma por linha)","Options (one per line)"),"field-options-"+i,(f.Options||[]).join("\n"),v=>f.Options=v.split("\n").filter(Boolean),"textarea"));
 box.append(el("button",{text:T("delete"),disabled:fields.length<=1,on:{click:()=>{fields.splice(i,1);original.splice(i,1);draw();}}}));container.append(box);
 });}
 draw();modal(T("Campos do formulário","Form fields"),[container,el("div",{class:"modal-actions"},el("button",{text:T("Adicionar campo","Add field"),on:{click:()=>{if(fields.length<64){fields.push({Id:unique("campo",new Set(fields.map(f=>f.Id))),Type:"Input",Title:T("Novo campo","New field"),Default:""});original.push(null);draw();}}}}),el("button",{text:T("cancel"),on:{click:closeModal}}),el("button",{class:"primary",text:T("apply"),on:{click:()=>{if(commit(p=>{C.find(p,node.Id).node.Options.Fields=fields;fields.forEach((f,i)=>{if(original[i]&&original[i]!==f.Id)for(const n of p.Flow.Nodes)if(n.Control===node.Id+"/"+original[i])n.Control=node.Id+"/"+f.Id;});}))closeModal();}}}))]);
}
function renderFlowProperties(panel,n){
 const spec=catalog.FlowNodes[n.Type],controls=C.controlMap(S.project);panel.append(el("p",{class:"panel-note",text:language==="pt-BR"?spec.Description:T("Bloco tipado com ações explícitas.","Typed block with explicit actions.")}));
 for(const [field,kind]of Object.entries(spec.Fields)){
  if(field==="Control"){const choices=Object.values(controls).filter(c=>n.Type==="Click"?c.Type==="Button":kind==="form"?c.Type==="Form":true).map(c=>({value:c.Id,text:c.Id+" · "+c.Type}));panel.append(property(T("control"),field,n.Control||"",v=>commit(p=>{const target=p.Flow.Nodes.find(x=>x.Id===n.Id);if(v){target.Control=v;delete target.State;}else delete target.Control;}),"text",[{value:"",text:"—"},...choices]));}
  else if(field==="State")panel.append(property(T("state"),field,n.State||"",v=>commit(p=>{const target=p.Flow.Nodes.find(x=>x.Id===n.Id);if(v){target.State=v;delete target.Control;}else delete target.State;}),"text",[{value:"",text:"—"},...S.project.States.map(s=>s.Id)]));
  else if(Array.isArray(kind))panel.append(property(T(field==="Property"?"property":field==="Locale"?"locale":field),field,n[field]||kind[0],v=>changeNode(field,v),"text",kind));
  else if(field==="Value")panel.append(property(T("value")+" (JSON)",field,JSON.stringify(n[field]??null),v=>parseChange(field,v),"textarea"));
  else if(["Text","Title"].includes(field)){const entry=S.project.Translations[n[field]];panel.append(property(T(field==="Text"?"text":"title"),field,entry?.Source??n[field]??"",v=>{if(entry)commit(p=>{const e=p.Translations[p.Flow.Nodes.find(x=>x.Id===n.Id)[field]];e.Source=v;e.Values={};});else changeNode(field,v);}));}
  else panel.append(property(T(field==="Action"?"action":field),field,n[field]||"",v=>changeNode(field,v)));
 }
 if(n.Type==="Call")panel.append(el("p",{class:"panel-note",text:T("Conecte uma função em actions no Luau. A prévia marca a ação como pendente.","Connect a function in the Luau actions table. Preview marks the action as pending.")}));
 const links=el("div",{class:"connection-list"});S.project.Flow.Edges.forEach((e,i)=>{if(e.From===n.Id||e.To===n.Id)links.append(el("button",{text:"× "+e.From+"."+e.Out+" → "+e.To+"."+e.Input,on:{click:()=>commit(p=>p.Flow.Edges.splice(i,1))}}));});panel.append(links);
}
function addBlock(type){
 const spec=catalog.FlowNodes[type];if(!spec)return;let id;commit(p=>{id=unique(type,new Set(p.Flow.Nodes.map(n=>n.Id)));const n={Id:id,Type:type,Position:{X:80+p.Flow.Nodes.length%3*290,Y:80+Math.floor(p.Flow.Nodes.length/3)*220}},controls=Object.values(C.controlMap(p));
 for(const [field,kind]of Object.entries(spec.Fields)){if(Array.isArray(kind))n[field]=kind[0];else if(field==="Control"){const c=controls.find(c=>type==="Click"?c.Type==="Button":kind==="form"?c.Type==="Form":true);if(c)n.Control=c.Id;}else if(field==="Value")n.Value=1;else if(field==="Text")n.Text=type==="Format"?"Valor: {value}":T("Sua mensagem","Your message");else if(field==="Title")n.Title=p.Window.Title;else if(field==="Action")n.Action="minha-acao";}p.Flow.Nodes.push(n);});if(id)select("flow",id);
}
function renderFlow(root){
 const type=el("select",{id:"block-type","aria-label":T("addBlock")});for(const [key,spec]of Object.entries(catalog.FlowNodes))type.append(el("option",{value:key,text:spec.Category+" · "+key}));
 root.append(el("div",{class:"flow-toolbar"},type,el("button",{text:T("addBlock"),on:{click:()=>addBlock(type.value)}}),el("button",{text:T("addState"),on:{click:addState}}),el("button",{text:T("Organizar","Arrange"),on:{click:()=>commit(p=>p.Flow.Nodes.forEach((n,i)=>n.Position={X:40+i%3*290,Y:40+Math.floor(i/3)*240}))}}),el("span",{class:"flow-hint",text:S.wire?T("Escolha uma entrada. Esc cancela.","Choose an input. Esc cancels."):T("Conecte saídas e entradas. Arraste o cabeçalho para mover.","Connect outputs to inputs. Drag a header to move.")})));
 const scroll=el("div",{class:"flow-scroll"}),board=el("div",{id:"flow-board",class:"flow-board",style:{zoom:$("#zoom").value}}),svg=document.createElementNS("http://www.w3.org/2000/svg","svg");svg.setAttribute("class","flow-edges");svg.setAttribute("aria-label",T("connections"));board.append(svg);
 for(const [i,n]of S.project.Flow.Nodes.entries()){
  const spec=catalog.FlowNodes[n.Type],pos=n.Position||{X:40+i%3*290,Y:40+Math.floor(i/3)*240},card=el("article",{class:"flow-node"+(S.selected.kind==="flow"&&S.selected.id===n.Id?" selected":""),dataset:{nodeId:n.Id,nodeKind:"flow"},style:{left:pos.X+"px",top:pos.Y+"px"},on:{click:()=>select("flow",n.Id)}});
  const head=el("div",{class:"flow-node-head"},icon(spec.Category==="Event"?"play":"code"),el("strong",{text:n.Type}),el("small",{text:spec.Category}));setupNodeDrag(head,card,n);card.append(head,el("div",{class:"flow-node-summary",text:n.Control||n.State||n.Action||S.project.Translations[n.Text]?.Source||n.Text||n.Operator||JSON.stringify(n.Value)||n.Id}));
  const inputs=el("div"),outputs=el("div");for(const [name,type]of Object.entries(spec.Inputs))inputs.append(port(n,name,type,"input"));for(const [name,type]of Object.entries(spec.Outputs))outputs.append(port(n,name,type,"output"));card.append(el("div",{class:"flow-ports"},inputs,outputs));board.append(card);
 }
 scroll.append(board);root.append(scroll,el("div",{class:"flow-legend",text:T("■ execução · ● valor · azul: número · verde: boolean · roxo: texto","■ execution · ● value · blue: number · green: boolean · purple: text")}));requestAnimationFrame(drawEdges);
}
function port(n,name,type,direction){
 if(type==="any"&&direction==="output"){if(n.Control)type=catalog.Controls[C.controlMap(S.project)[n.Control]?.Type]?.ValueType||"any";else if(n.Type==="Constant"&&["string","number","boolean"].includes(typeof n.Value))type=typeof n.Value;}
 return el("button",{class:"flow-port "+direction+(S.wire?.node===n.Id&&S.wire.port===name&&direction==="output"?" pending":""),dataset:{port:name,direction,type,portNode:n.Id},"aria-label":n.Id+" "+direction+" "+name,title:direction+" · "+type,on:{
  click:e=>{e.stopPropagation();if(direction==="output"){S.wire={node:n.Id,port:name,type};renderWorkspace();}else connectPort(n.Id,name);},
  pointerdown:e=>{if(direction!=="output")return;e.stopPropagation();S.wire={node:n.Id,port:name,type};const move=event=>drawPending(event.clientX,event.clientY),up=event=>{window.removeEventListener("pointermove",move);window.removeEventListener("pointerup",up);const target=document.elementFromPoint(event.clientX,event.clientY)?.closest(".flow-port.input");if(target)connectPort(target.dataset.portNode,target.dataset.port);};window.addEventListener("pointermove",move);window.addEventListener("pointerup",up);}
 }},el("i",{class:"port-dot"}),el("span",{text:name}));
}
function connectPort(to,input){if(!S.wire)return;try{const e=C.edge(S.wire.node,S.wire.port,to,input),next=C.addEdge(S.project,e,catalog);if(commit(p=>p.Flow=next.Flow))S.wire=null;renderWorkspace();}catch(e){S.wire=null;toast(e.message,true);renderWorkspace();}}
function portPoint(id,name,direction){const node=[...document.querySelectorAll(".flow-port")].find(n=>n.dataset.portNode===id&&n.dataset.port===name&&n.dataset.direction===direction);if(!node)return;const box=node.querySelector(".port-dot").getBoundingClientRect(),base=$("#flow-board").getBoundingClientRect(),zoom=Number($("#zoom").value);return {x:(box.x+box.width/2-base.x)/zoom,y:(box.y+box.height/2-base.y)/zoom};}
function curve(a,b){const d=Math.max(60,Math.abs(a.x-b.x)*.45);return "M "+a.x+" "+a.y+" C "+(a.x+d)+" "+a.y+" "+(b.x-d)+" "+b.y+" "+b.x+" "+b.y;}
function drawEdges(){const svg=$(".flow-edges");if(!svg)return;svg.replaceChildren();S.project.Flow.Edges.forEach((e,i)=>{const a=portPoint(e.From,e.Out,"output"),b=portPoint(e.To,e.Input,"input");if(!a||!b)return;const path=document.createElementNS(svg.namespaceURI,"path");path.setAttribute("class","flow-edge"+(catalog.FlowNodes[S.project.Flow.Nodes.find(n=>n.Id===e.From).Type].Outputs[e.Out]==="exec"?" exec":""));path.setAttribute("d",curve(a,b));path.addEventListener("click",event=>{event.stopPropagation();commit(p=>p.Flow.Edges.splice(i,1));});svg.append(path);});}
function drawPending(x,y){const svg=$(".flow-edges"),board=$("#flow-board"),a=S.wire&&portPoint(S.wire.node,S.wire.port,"output");if(!svg||!board||!a)return;svg.querySelector(".flow-pending")?.remove();const rect=board.getBoundingClientRect(),zoom=Number($("#zoom").value),path=document.createElementNS(svg.namespaceURI,"path");path.setAttribute("class","flow-pending");path.setAttribute("d",curve(a,{x:(x-rect.x)/zoom,y:(y-rect.y)/zoom}));svg.append(path);}
function setupNodeDrag(head,card,node){head.addEventListener("pointerdown",e=>{if(e.button!==0)return;e.preventDefault();const startX=e.clientX,startY=e.clientY,x=parseFloat(card.style.left),y=parseFloat(card.style.top),zoom=Number($("#zoom").value);let moved=false;const move=event=>{const dx=(event.clientX-startX)/zoom,dy=(event.clientY-startY)/zoom;if(Math.abs(dx)+Math.abs(dy)>3)moved=true;card.style.left=Math.max(0,x+dx)+"px";card.style.top=Math.max(0,y+dy)+"px";drawEdges();},up=()=>{window.removeEventListener("pointermove",move);window.removeEventListener("pointerup",up);if(moved)commit(p=>p.Flow.Nodes.find(n=>n.Id===node.Id).Position={X:Math.round(parseFloat(card.style.left)),Y:Math.round(parseFloat(card.style.top))});};window.addEventListener("pointermove",move);window.addEventListener("pointerup",up);});}
function addState(){let id;commit(p=>{id=unique("state",new Set(p.States.map(s=>s.Id)));p.States.push({Id:id,Value:0});});if(id){S.left="structure";select("state",id);}}
function saveTemplate(){
 const selected=current();if(selected?.kind!=="section")return;const name=el("input",{value:selected.node.Title||"componente","aria-label":T("Nome do componente","Component name")});
 modal(T("saveTemplate"),[el("p",{text:T("Cria uma fábrica reutilizável com até 32 controles da seção.","Create a reusable factory with up to 32 controls from this section.")}),name,el("div",{class:"modal-actions"},el("button",{text:T("cancel"),on:{click:closeModal}}),el("button",{class:"primary",text:T("save"),on:{click:()=>{if(commit(p=>{
  const list=[];function flat(nodes){for(const n of nodes)if(n.Type==="Row")flat(n.Children);else list.push(C.clone(n));}flat(C.find(p,selected.node.Id).node.Controls);
  if(!list.length||list.length>32||list.some(n=>["Form","Component"].includes(n.Type)))throw Error(T("Use 1–32 controles, sem formulários ou modelos aninhados.","Use 1–32 controls without forms or nested templates."));
  const used=new Set();for(const n of list){n.Id=unique(n.Id,used);used.add(n.Id);delete n.TextKeys;}p.Templates.push({Id:unique(name.value,new Set(p.Templates.map(t=>t.Id))),Title:name.value,Controls:list});
 }))closeModal();}}}))]);
}
function renderTranslations(root){
 const target=S.translationTarget||"en-US",view=el("div",{class:"translation-view"});view.append(el("div",{class:"translation-header"},el("div",{},el("h2",{text:T("translations")}),el("p",{text:T("Textos do projeto, com parâmetros preservados. As traduções entram no Luau exportado.","Project text with preserved parameters. Translations are included in exported Luau.")})),el("button",{class:"primary",text:T("collect"),on:{click:()=>commit(p=>Object.assign(p,C.collectTranslations(p)))}})));
 const locale=el("select",{"aria-label":T("Idioma da tradução","Translation language"),on:{change:e=>{S.translationTarget=e.target.value;renderWorkspace();}}},...["en-US","pt-BR"].map(code=>el("option",{value:code,text:code,selected:code===target}))),search=el("input",{type:"search",placeholder:T("Pesquisar textos…","Search text…"),value:S.translationQuery||"",on:{input:e=>{S.translationQuery=e.target.value;renderTranslationRows();}}}),missing=el("label",{},el("input",{type:"checkbox",checked:!!S.missingOnly,on:{change:e=>{S.missingOnly=e.target.checked;renderTranslationRows();}}})," "+T("Somente pendentes","Missing only"));
 view.append(el("div",{class:"translation-toolbar"},locale,search,missing),el("table",{class:"translation-table"},el("thead",{},el("tr",{},el("th",{text:T("Chave / contexto","Key / context")}),el("th",{text:T("Original","Source")}),el("th",{text:T("Tradução","Translation")+" · "+target}))),el("tbody",{id:"translation-rows"})));
 const endpoint=el("input",{type:"url",value:S.providerURL||"",placeholder:"https://seu-servico.example/translate","aria-label":"Translation endpoint",on:{change:e=>S.providerURL=e.target.value}});
 view.append(el("div",{class:"provider-box"},el("strong",{text:T("Tradução automática opcional","Optional automatic translation")}),el("p",{text:T("Use seu serviço HTTPS com CORS. Apenas mensagens cadastradas são enviadas; valores da prévia e código não são enviados. Chaves privadas ficam no backend.","Use your HTTPS service with CORS. Only registered messages are sent, never preview values or code. Private keys belong in the backend.")}),endpoint,el("div",{class:"button-row"},el("button",{text:T("providerRun"),disabled:S.providerBusy,on:{click:()=>translateMissing(endpoint.value,target)}}),el("button",{text:T("cancel"),disabled:!S.providerBusy,on:{click:()=>S.providerController?.abort()}})),el("p",{},el("code",{text:'POST {sourceLocale,targetLocale,entries:[{key,text,context}]} → {translations:{key:"..."}}'}))));root.append(view);renderTranslationRows();
}
function renderTranslationRows(){
 const root=$("#translation-rows");if(!root)return;root.replaceChildren();const target=S.translationTarget||"en-US",source=S.project.Window.SourceLocale||"pt-BR",query=(S.translationQuery||"").toLowerCase();
 for(const [key,e]of Object.entries(S.project.Translations)){if(S.missingOnly&&(target===source||e.Values[target])||query&&!(key+" "+e.Source).toLowerCase().includes(query))continue;
 root.append(el("tr",{},el("td",{},el("strong",{text:key}),el("p",{text:e.Context||""})),el("td",{text:e.Source}),el("td",{class:target!==source&&!e.Values[target]?"missing":""},el("textarea",{value:e.Values[target]??(target===source?e.Source:""),"aria-label":key+" "+target,on:{change:event=>commit(p=>p.Translations[key].Values[target]=event.target.value)}}))));}
 if(!root.children.length)root.append(el("tr",{},el("td",{colSpan:3,class:"empty-state",text:T("Nenhuma mensagem. Use Coletar textos.","No messages. Use Collect text.")})));
}
async function translateMissing(endpoint,target){
 if(S.providerBusy)return;let url;try{url=new URL(endpoint);}catch(_){toast(T("Informe um endpoint HTTPS válido.","Enter a valid HTTPS endpoint."),true);return;}
 if(url.protocol!=="https:"&&!(url.protocol==="http:"&&["localhost","127.0.0.1"].includes(url.hostname))){toast(T("O endpoint precisa usar HTTPS.","The endpoint must use HTTPS."),true);return;}
 const sourceLocale=S.project.Window.SourceLocale||"pt-BR",entries=Object.entries(S.project.Translations).filter(([,e])=>target!==sourceLocale&&!e.Values[target]).map(([key,e])=>({key,text:e.Source,context:e.Context||""}));
 if(!entries.length){toast(T("Não há traduções pendentes.","No translations are missing."));return;}
 const controller=new AbortController();S.providerController=controller;S.providerBusy=true;S.providerURL=endpoint;const timer=setTimeout(()=>controller.abort(),60000);renderWorkspace();
 try{for(let offset=0;offset<entries.length;offset+=32){
 const batch=entries.slice(offset,offset+32),requested=new Map(batch.map(e=>[e.key,e.text])),response=await fetch(url.href,{method:"POST",headers:{"Content-Type":"application/json"},credentials:"omit",redirect:"error",signal:controller.signal,body:JSON.stringify({sourceLocale,targetLocale:target,entries:batch})});
 if(!response.ok)throw Error("HTTP "+response.status);const text=await response.text();if(C.bytes(text)>1048576)throw Error(T("Resposta excede 1 MiB.","Response exceeds 1 MiB."));const data=C.clone(JSON.parse(text));
 if(!data.translations||typeof data.translations!=="object"||Array.isArray(data.translations))throw Error(T("Resposta sem translations.","Response has no translations object."));
 for(const [key,value]of Object.entries(data.translations))if(!requested.has(key)||typeof value!=="string")throw Error(T("Resposta contém mensagem inesperada.","Response contains an unexpected message."));
 if(!commit(p=>{for(const [key,value]of Object.entries(data.translations))if(p.Translations[key]?.Source===requested.get(key))p.Translations[key].Values[target]=value;}))throw Error(T("A tradução alterou parâmetros ou contém dados inválidos.","Translation changed parameters or contains invalid data."));
 }toast(T("Traduções adicionadas ao projeto.","Translations added to the project."));
 }catch(e){toast(e.name==="AbortError"?T("Tradução cancelada.","Translation cancelled."):e.message,true);}finally{clearTimeout(timer);S.providerBusy=false;S.providerController=null;if(S.view==="translations")renderWorkspace();}
}
function modal(title,children){$("#modal-title").textContent=title;$("#modal-content").replaceChildren(...children);if(!$("#modal").open)$("#modal").showModal();}
function closeModal(){$("#modal").close();}
function download(name,text,type){const url=URL.createObjectURL(new Blob([text],{type})),link=el("a",{href:url,download:name});document.body.append(link);link.click();link.remove();setTimeout(()=>URL.revokeObjectURL(url),1000);}
function filename(extension){return S.project.Window.Id.replace(/[^a-zA-Z0-9_.-]/g,"-").slice(0,80)+extension;}
function showExport(){
 let mode=S.exportMode;const code=el("textarea",{class:"code-output",readOnly:true,value:C.compile(S.project,catalog,mode),spellcheck:false,"aria-label":"Luau export"}),select=el("select",{"aria-label":T("export"),on:{change:e=>{mode=S.exportMode=e.target.value;code.value=C.compile(S.project,catalog,mode);}}},el("option",{value:"standalone",text:T("Script completo com loader","Standalone with loader"),selected:mode==="standalone"}),el("option",{value:"module",text:T("Módulo (recebe Library e ações)","Module (receives Library and actions)"),selected:mode==="module"}));
 modal(T("export"),[el("p",{text:T("Salve JSON para continuar editando. O Luau cria a interface; conecte suas funções em actions. A prévia não executa código dos scripts.","Save JSON to keep editing. Luau creates the interface; connect your functions in actions. Preview does not execute script code.")}),select,code,el("div",{class:"modal-actions"},el("button",{text:T("copy"),on:{click:async()=>{try{await navigator.clipboard.writeText(code.value);toast(T("Copiado.","Copied."));}catch(_){code.select();toast(T("Selecione o texto e copie com Ctrl+C.","Select the text and copy with Ctrl+C."));}}}}),el("button",{class:"primary",text:T("download")+" .lua",on:{click:()=>download(filename(mode==="module"?"-interface.lua":".lua"),code.value,"text/plain;charset=utf-8")}}))]);
}
function showIssues(){const r=C.validateProject(S.project,catalog),errors=[...r.errors,...r.graphErrors];modal(T("issues"),errors.length?[el("ul",{},...errors.map(e=>el("li",{text:e.path+": "+e.message})))]:[el("p",{text:T("Nenhum problema encontrado. A exportação usa APIs reais da RetroBox 2.5.","No problems found. Export uses real RetroBox 2.5 APIs.")})]);}
function showHelp(){const pt=["Adicione componentes por clique ou arraste para uma seção. A sequência é janela → aba → seção → controles. Selecione itens na Estrutura; o painel Propriedades também aceita dados JSON para conteúdo complexo.","Em Ligações, adicione blocos e conecte uma saída a uma entrada, por clique ou arraste. Portas quadradas levam execução; redondas levam valores. Tipos incompatíveis, ciclos e realimentação impedem a exportação. Arraste o cabeçalho para mover um bloco; clique no fio para removê-lo.","Use Testar para experimentar os valores e eventos. Call é um ponto de integração e precisa de um handler no Luau. O editor não avalia código digitado, Lua importado ou scripts de gameplay.","Form tem um editor visual de campos e Aplicar/Cancelar. Salvar como componente transforma uma seção de até 32 controles em uma fábrica reutilizável; cada instância tem IDs e valores próprios.","Coletar textos reúne mensagens para tradução. Dicionários funcionam offline. Tradução automática opcional precisa do seu serviço HTTPS com CORS; parâmetros {value} e {count} são preservados.","Salve o JSON para reabrir o projeto e exporte Luau para a biblioteca real. O salvamento automático depende do navegador; o JSON baixado é portátil. A prévia web aproxima Roblox: confira fontes, gestos, atalhos, imagens/modelos 3D e layout no cliente real."];
 const en=["Add components by clicking or dragging into a section. The assembly order is window → tab → section → controls. Select items in Structure; Properties also accepts JSON for complex data.","In Connections, add blocks and connect an output to an input, by click or drag. Square ports carry execution and round ports carry values. Types, cycles and feedback are checked. Drag headers to move blocks; click a wire to remove it.","Use Test to try values and events. Call needs a handler in exported Luau. The editor does not evaluate typed code, imported Lua or gameplay scripts.","Form has a visual field editor and Apply/Cancel. Save as component creates a reusable factory with up to 32 controls, each instance with its own IDs and values.","Collect text gathers translation messages. Dictionaries work offline. Optional automatic translation needs your HTTPS service with CORS; {value} and {count} parameters are preserved.","Save JSON to reopen projects and export Luau for the actual library. Autosave depends on browser storage; downloaded JSON is portable. The web preview approximates Roblox: verify fonts, gestures, shortcuts, images/models and layout in the real client."];
 modal(T("help"),(language==="en-US"?en:pt).map(text=>el("p",{text})));
}
function deleteSelected(){
 const s={...S.selected};if(s.kind==="window")return;const ok=commit(p=>{
 if(s.kind==="flow"){p.Flow.Nodes=p.Flow.Nodes.filter(n=>n.Id!==s.id);p.Flow.Edges=p.Flow.Edges.filter(e=>e.From!==s.id&&e.To!==s.id);}
 else if(s.kind==="state"){p.States=p.States.filter(n=>n.Id!==s.id);for(const n of p.Flow.Nodes)if(n.State===s.id)delete n.State;}
 else {const f=C.find(p,s.id);if(!f)return;if(f.kind==="tab"&&p.Tabs.length===1)throw Error(T("Mantenha pelo menos uma aba.","Keep at least one tab."));
 const removed=new Set();function collect(n){removed.add(n.Id);for(const child of n.Sections||n.Controls||n.Children||[])collect(child);}collect(f.node);
 const list=f.kind==="tab"?p.Tabs:f.kind==="section"?f.parent.Sections:f.parent.Type==="Row"?f.parent.Children:f.parent.Controls;list.splice(list.indexOf(f.node),1);
 const gone=new Set(p.Flow.Nodes.filter(n=>n.Control&&[...removed].some(id=>n.Control===id||n.Control.startsWith(id+"/"))).map(n=>n.Id));p.Flow.Nodes=p.Flow.Nodes.filter(n=>!gone.has(n.Id));p.Flow.Edges=p.Flow.Edges.filter(e=>!gone.has(e.From)&&!gone.has(e.To));}
 });if(ok){S.selected={kind:"window",id:""};renderAll();}
}
function duplicateSelected(){
 const s=current();if(!s?.node||["window","state"].includes(s.kind))return;let id;
 const ok=commit(p=>{if(s.kind==="flow"){const n=C.clone(p.Flow.Nodes.find(n=>n.Id===s.node.Id));n.Id=id=unique(n.Id,new Set(p.Flow.Nodes.map(n=>n.Id)));n.Position={X:(n.Position?.X||0)+35,Y:(n.Position?.Y||0)+45};p.Flow.Nodes.push(n);}
 else {const f=C.find(p,s.node.Id),n=C.clone(f.node),used=ids(p);function rekey(n){n.Id=unique(n.Id,used);used.add(n.Id);delete n.TextKeys;for(const child of n.Sections||n.Controls||n.Children||[])rekey(child);}rekey(n);id=n.Id;const list=f.kind==="tab"?p.Tabs:f.kind==="section"?f.parent.Sections:f.parent.Type==="Row"?f.parent.Children:f.parent.Controls;list.splice(list.indexOf(f.node)+1,0,n);}});if(ok)select(s.kind,id);
}
function history(redo){const from=redo?S.redo:S.history,to=redo?S.history:S.redo;if(!from.length)return;to.push(JSON.stringify(S.project));S.project=JSON.parse(from.pop());rebuildSimulator();renderAll();saveSoon();}
function renderStatus(){const count=Object.keys(C.controlMap(S.project)).length,r=C.validateProject(S.project,catalog),errors=[...r.errors,...r.graphErrors];$("#selection-status").textContent=count+" "+T("controles","controls")+" · "+S.project.Flow.Nodes.length+" "+T("blocos","blocks")+(S.selected.id?" · "+S.selected.id:"");$("#issues-button").textContent=errors.length?errors.length+" "+T("pendências","issues"):T("valid");$("[data-action=export]").disabled=!!errors.length;$("[data-action=undo]").disabled=!S.history.length;$("[data-action=redo]").disabled=!S.redo.length;}
function renderAll(){renderLanguage();renderLibrary();renderWorkspace();renderInspector();renderStatus();}
const actions={
 help:showHelp,export:showExport,issues:showIssues,import:()=>$("#project-file").click(),save:()=>download(filename(".retrobox.json"),JSON.stringify(S.project,null,2)+"\n","application/json"),
 undo:()=>history(false),redo:()=>history(true),duplicate:duplicateSelected,delete:deleteSelected,"close-modal":closeModal,"window-properties":()=>select("window",""),
 "toggle-left":()=>document.body.classList.toggle("show-left"),"toggle-right":()=>document.body.classList.toggle("show-right"),"clear-console":()=>{if(S.simulator)S.simulator.logs=[];renderConsole();},
 simulate:()=>{if(S.testing){S.testing=false;S.simulator=null;}else{S.testing=true;rebuildSimulator();}renderLanguage();renderWorkspace();},
 new:()=>modal(T("Novo projeto","New project"),[el("p",{text:T("Salve o JSON para manter uma cópia. Você também poderá desfazer esta mudança.","Save JSON to keep a copy. You can also undo this change.")}),el("div",{class:"modal-actions"},el("button",{text:T("cancel"),on:{click:closeModal}}),el("button",{class:"primary",text:T("new"),on:{click:()=>{S.testing=false;S.wire=null;commit(p=>{for(const key of Object.keys(p))delete p[key];Object.assign(p,starter());});S.tab="principal";S.selected={kind:"window",id:""};closeModal();renderAll();}}}))])
};
document.querySelectorAll("[data-action]").forEach(n=>n.addEventListener("click",()=>{try{actions[n.dataset.action]?.();}catch(e){toast(e.message,true);}}));
document.querySelectorAll("[data-view]").forEach(n=>n.addEventListener("click",()=>{S.view=n.dataset.view;S.wire=null;renderWorkspace();renderInspector();}));
document.querySelectorAll("[data-left]").forEach(n=>n.addEventListener("click",()=>{S.left=n.dataset.left;renderLibrary();}));
$("#editor-language").addEventListener("change",e=>{language=e.target.value;try{localStorage.setItem("retrobox-designer-language",language);}catch(_){}renderAll();});
$("#preview-language").value=S.previewLocale;$("#preview-language").addEventListener("change",e=>{S.previewLocale=e.target.value;if(S.simulator){S.simulator.locale=S.previewLocale;S.simulator.refresh();}renderWorkspace();});
$("#device").addEventListener("change",renderWorkspace);$("#zoom").addEventListener("change",renderWorkspace);
$("#project-file").addEventListener("change",async e=>{const file=e.target.files[0];e.target.value="";if(!file)return;try{if(file.size>2097152)throw Error(T("Projeto excede 2 MiB.","Project exceeds 2 MiB."));const result=C.validateProject(JSON.parse(await file.text()),catalog,{allowDraft:true});if(!result.ok)throw Error(result.errors.map(e=>e.message).join("\n"));if(commit(p=>{for(const key of Object.keys(p))delete p[key];Object.assign(p,result.project);})){S.selected={kind:"window",id:""};S.tab=S.project.Tabs[0].Id;renderAll();toast(T("Projeto aberto.","Project opened."));}}catch(error){toast(error.message,true);}});
window.addEventListener("keydown",e=>{if(e.key==="Escape"){S.wire=null;if(S.view==="flow")renderWorkspace();document.body.classList.remove("show-left","show-right");}
 if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==="z"&&!["INPUT","TEXTAREA","SELECT"].includes(document.activeElement?.tagName)){e.preventDefault();history(e.shiftKey);}
 if((e.ctrlKey||e.metaKey)&&e.key.toLowerCase()==="s"){e.preventDefault();actions.save();}
});window.addEventListener("resize",()=>{if(S.view==="flow")requestAnimationFrame(drawEdges);});
renderAll();$("#save-status").textContent=T("Pronto para editar","Ready to edit");
})();
