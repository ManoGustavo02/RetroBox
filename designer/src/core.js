/* Shared data model and Luau compiler. No project source code is evaluated. */
(function(root,factory){const api=factory();if(typeof module==="object"&&module.exports)module.exports=api;else root.RetroBoxDesignerCore=api;})(globalThis,function(){
"use strict";
const forbidden=new Set(["__proto__","constructor","prototype"]), idPattern=/^[A-Za-z0-9_./-]{1,128}$/, groupPattern=/^[A-Za-z0-9_.-]{1,64}$/;
const bytes=s=>new TextEncoder().encode(s).length;
function clone(v,seen=new Set(),depth=0,budget={count:0,bytes:0}){
 if(++budget.count>65536||depth>20)throw Error("O projeto excede o limite de dados.");
 if(v===null||v===undefined||typeof v==="boolean")return v;
 if(typeof v==="number"){if(!Number.isFinite(v))throw Error("Número inválido.");return v;}
 if(typeof v==="string"){budget.bytes+=bytes(v);if(budget.bytes>2097152)throw Error("Textos excedem 2 MiB.");return v;}
 if(typeof v!=="object"||seen.has(v)||(!Array.isArray(v)&&![Object.prototype,null].includes(Object.getPrototypeOf(v))))throw Error("Use somente dados JSON sem ciclos.");
 seen.add(v);const result=Array.isArray(v)?[]:{};
 for(const key of Object.keys(v)){if(forbidden.has(key))throw Error("Chave reservada: "+key);result[key]=clone(v[key],seen,depth+1,budget);}seen.delete(v);return result;
}
function luaString(v){return '"'+String(v).replace(/["\\\x00-\x1f\x7f]/g,c=>c==='"'?'\\"':c==="\\"?"\\\\":"\\"+c.charCodeAt(0).toString().padStart(3,"0"))+'"';}
function lua(v,depth=0){
 if(v===null||v===undefined)return "nil";
 if(typeof v==="string")return luaString(v);if(typeof v==="boolean")return String(v);
 if(typeof v==="number"){if(!Number.isFinite(v))throw Error("Número inválido.");return String(v);}
 if(typeof v!=="object")throw Error("Somente dados podem ser exportados.");
 const pad="    ".repeat(depth),next=pad+"    ", rows=Array.isArray(v)?v.map(x=>lua(x,depth+1)):Object.keys(v).sort().map(k=>"["+luaString(k)+"] = "+lua(v[k],depth+1));
 return rows.length?"{\n"+rows.map(r=>next+r).join(",\n")+"\n"+pad+"}":"{}";
}
const edge=(From,Out,To,Input)=>({From,Out,To,Input});
function newProject(){return {
 Kind:"RetroBoxDesignerProject",SchemaVersion:1,MinVersion:"2.5.1",
 Window:{Id:"meu-projeto",Title:"Meu projeto",Subtitle:"Monte, conecte e exporte",Theme:"Hacker",Locale:"auto",SourceLocale:"pt-BR",Size:{X:790,Y:570}},
 Tabs:[{Id:"principal",Title:"Principal",Icon:"grid",Columns:1,Sections:[{Id:"geral",Title:"Controles",Icon:"settings",Controls:[
 {Id:"enabled",Type:"Toggle",Options:{Title:"Ativar recurso",Default:true}},
 {Id:"amount",Type:"Slider",Options:{Title:"Quantidade",Min:0,Max:100,Step:1,Default:25}},
 {Id:"summary",Type:"Label",Options:{Title:"Quantidade: 25"}},
 {Id:"run",Type:"Button",Options:{Title:"Executar",Text:"Executar"}}]}]}],
 States:[],Templates:[],Translations:{},Flow:{Id:"principal",Nodes:[
 {Id:"read-amount",Type:"Value",Control:"amount",Position:{X:40,Y:40}},
 {Id:"format",Type:"Format",Text:"Quantidade: {value}",Position:{X:340,Y:40}},
 {Id:"summary-binding",Type:"Binding",Control:"summary",Property:"Text",Position:{X:640,Y:40}},
 {Id:"click",Type:"Click",Control:"run",Position:{X:40,Y:270}},
 {Id:"notice",Type:"Notify",Text:"Você acionou um evento visual.",Title:"Meu projeto",Kind:"success",Position:{X:340,Y:270}}],
 Edges:[edge("read-amount","Value","format","Value"),edge("format","Value","summary-binding","Value"),edge("click","Then","notice","Execute")]}
};}
function walk(p,visit){
 function controls(list,parent){if(!Array.isArray(list))return;for(const n of list){visit(n,parent,"control");if(n?.Type==="Row")controls(n.Children,n);}}
 for(const tab of Array.isArray(p.Tabs)?p.Tabs:[]){visit(tab,p,"tab");for(const s of Array.isArray(tab?.Sections)?tab.Sections:[]){visit(s,tab,"section");if(s)controls(s.Controls,s);}}
}
function find(p,id){let result;walk(p,(node,parent,kind)=>{if(node?.Id===id)result={node,parent,kind};});return result;}
function controlMap(p){
 const result=Object.create(null),templates=Object.fromEntries((p.Templates||[]).filter(Boolean).map(t=>[t.Id,t]));
 walk(p,(n,parent,kind)=>{if(!n||kind!=="control"||n.Type==="Row")return;result[n.Id]=n;
 if(n.Type==="Form")for(const f of n.Options?.Fields||[])if(f)result[n.Id+"/"+f.Id]={Id:n.Id+"/"+f.Id,Type:f.Type,Options:f,TextKeys:f.TextKeys};
 if(n.Type==="Component")for(const c of templates[n.Template]?.Controls||[])if(c)result[n.Id+"/"+c.Id]={...c,Id:n.Id+"/"+c.Id,Options:{...c.Options,...n.Props?.[c.Id]}};
 });return result;
}
function defaultValue(n){
 const o=n.Options||{};if(o.Default!==undefined)return clone(o.Default);
 if(n.Type==="Toggle")return false;if(["Slider","Progress","StatCard"].includes(n.Type))return o.Min||0;
 if(["Input","Label","Separator","Console"].includes(n.Type))return n.Type==="Label"?o.Title||"":"";
 if(n.Type==="Form")return Object.fromEntries((o.Fields||[]).map(f=>[f.Id,defaultValue({Type:f.Type,Options:f})]));
 return null;
}
function graphValidation(p,catalog,controls){
 const errors=[],nodes=new Map(),incoming=new Map(),outgoing=new Map(),states=new Map((p.States||[]).filter(Boolean).map(s=>[s.Id,s])),flow=p.Flow;
 const fail=(path,message)=>errors.push({path,message});
 if(!flow||!Array.isArray(flow.Nodes)||flow.Nodes.length>256||!Array.isArray(flow.Edges)||flow.Edges.length>512)return [{path:"Flow",message:"Limite de blocos ou ligações excedido."}];
 for(const n of flow.Nodes){
  const spec=catalog.FlowNodes[n?.Type];
  if(!n||!idPattern.test(n.Id)||nodes.has(n.Id)||!spec){fail("Flow.Nodes","Bloco inválido ou Id repetido.");continue;}
  nodes.set(n.Id,n);incoming.set(n.Id,{});outgoing.set(n.Id,[]);
  if(n.Control&&!controls[n.Control])fail(n.Id,"Componente não encontrado: "+n.Control);
  if(n.State&&!states.has(n.State))fail(n.Id,"Estado não encontrado: "+n.State);
  if(["Value","Binding","SetValue"].includes(n.Type)&&!!n.Control===!!n.State)fail(n.Id,"Escolha um componente ou um estado.");
  if(n.Type==="Click"&&controls[n.Control]?.Type!=="Button")fail(n.Id,"Clique precisa de um botão.");
  if(["Apply","ApplyForm","CancelForm"].includes(n.Type)&&controls[n.Control]?.Type!=="Form")fail(n.Id,"Escolha um formulário.");
  if(["Change","SetVisible","SetDisabled","SetText"].includes(n.Type)&&!n.Control)fail(n.Id,"Escolha o componente.");
  if(n.Type==="Call"&&!groupPattern.test(n.Action||""))fail(n.Id,"Defina um nome de ação válido.");
  if(["Format","Notify"].includes(n.Type)&&typeof n.Text!=="string")fail(n.Id,"Defina o texto.");
  if(n.Position&&(![n.Position.X,n.Position.Y].every(Number.isFinite)||Math.abs(n.Position.X)>20000||Math.abs(n.Position.Y)>20000))fail(n.Id,"Posição inválida.");
  for(const [field,choices]of Object.entries(spec.Fields))if(Array.isArray(choices)&&!choices.includes(n[field]))fail(n.Id,"Valor inválido: "+field);
 }
 function typeOf(value){return value===null||typeof value==="object"?"any":typeof value;}
 function outType(n,port){const t=catalog.FlowNodes[n.Type].Outputs[port];return t!=="any"?t:n.Type==="Constant"?typeOf(n.Value):n.Control?catalog.Controls[controls[n.Control]?.Type]?.ValueType||"any":n.State?typeOf(states.get(n.State)?.Value):"any";}
 const signatures=new Set();
 for(const e of flow.Edges){
  const a=nodes.get(e?.From),b=nodes.get(e?.To);if(!a||!b){fail("Flow.Edges","Ligação aponta para um bloco inexistente.");continue;}
  const out=catalog.FlowNodes[a.Type].Outputs[e.Out],input=catalog.FlowNodes[b.Type].Inputs[e.Input],signature=[e.From,e.Out,e.To,e.Input].join("/");
  if(!out||!input||(out==="exec")!==(input==="exec")){fail("Flow.Edges","Portas incompatíveis.");continue;}
  if(signatures.has(signature))fail("Flow.Edges","Ligação repetida.");signatures.add(signature);outgoing.get(e.From).push(e);
  if(input!=="exec"){
   if(incoming.get(e.To)[e.Input])fail(e.To,"Uma entrada de dados aceita somente uma ligação.");incoming.get(e.To)[e.Input]=e;
   let expected=input;if(["Binding","SetValue"].includes(b.Type)){const prop=b.Property||"Value";expected=["Visible","Disabled"].includes(prop)?"boolean":prop!=="Value"?"string":b.Control?catalog.Controls[controls[b.Control]?.Type]?.ValueType||"any":typeOf(states.get(b.State)?.Value);}
   const actual=outType(a,e.Out);if(expected!=="any"&&actual!=="any"&&expected!==actual)fail(b.Id,"Tipo incompatível: "+actual+" → "+expected);
  }
 }
 function checkCycle(map,message){const marks=new Map();function visit(id){if(marks.get(id)===1)throw Error(message);if(marks.get(id)===2)return;marks.set(id,1);for(const target of map.get(id)||[])visit(target);marks.set(id,2);}try{for(const id of map.keys())visit(id);}catch(e){fail("Flow",e.message);}}
 checkCycle(new Map([...outgoing].map(([id,edges])=>[id,edges.map(e=>e.To)])),"As ligações contêm um ciclo.");
 for(const n of nodes.values())for(const [port,type]of Object.entries(catalog.FlowNodes[n.Type].Inputs))if(type!=="exec"&&!(n.Type==="Notify"&&port==="Message"||n.Type==="Call"&&port==="Value")&&!incoming.get(n.Id)[port])fail(n.Id,"Entrada sem ligação: "+port);
 function sources(id,result,seen=new Set()){if(seen.has(id))return;seen.add(id);const n=nodes.get(id);if(!n)return;if(["Value","Change","Apply"].includes(n.Type))result.add((n.Control?"control/"+n.Control:"state/"+n.State));for(const e of Object.values(incoming.get(id)||{}))sources(e.From,result,seen);}
 const deps=new Map(),properties=new Set();
 for(const n of nodes.values())if(n.Type==="Binding"){
  const target=n.Control?"control/"+n.Control:"state/"+n.State,prop=target+"/"+n.Property;
  if(properties.has(prop))fail(n.Id,"Esta propriedade já possui uma ligação.");properties.add(prop);
  if(n.State&&n.Property!=="Value")fail(n.Id,"Estados recebem a propriedade Value.");
  if(n.State||["Value","Text"].includes(n.Property)){const set=deps.get(target)||new Set();sources(n.Id,set);deps.set(target,set);}
 }
 checkCycle(deps,"As ligações criam realimentação de valores.");return errors;
}
function validateProject(input,catalog,options={}){
 const errors=[],fail=(path,message)=>errors.push({path,message});let p;
 try{p=clone(input);}catch(e){return {ok:false,errors:[{path:"",message:e.message}],graphErrors:[]};}
 if(!p||p.Kind!=="RetroBoxDesignerProject"||p.SchemaVersion!==1)return {ok:false,errors:[{path:"",message:"Formato ou versão de projeto incompatível."}],graphErrors:[]};
 if(!p.Window||!groupPattern.test(p.Window.Id||"")||typeof p.Window.Title!=="string")fail("Window","Defina Id e título da janela.");
 p.States=p.States||[];p.Templates=p.Templates||[];p.Translations=p.Translations||{};p.Flow=p.Flow||{Id:"flow",Nodes:[],Edges:[]};
 if(!Array.isArray(p.Tabs)||p.Tabs.length<1||p.Tabs.length>32)fail("Tabs","Use de 1 a 32 abas.");
 if(!Array.isArray(p.States)||p.States.length>128||!Array.isArray(p.Templates)||p.Templates.length>64)fail("","Limite de estados ou modelos excedido.");
 if(!p.Translations||typeof p.Translations!=="object"||Array.isArray(p.Translations)||Object.keys(p.Translations).length>4096)fail("Translations","Use um dicionário com até 4096 mensagens.");
 if(errors.length)return {ok:false,errors,graphErrors:[],project:p};
 for(const field of ["Locale","SourceLocale","FallbackLocale"])if(p.Window[field]!==undefined&&!(field==="Locale"&&p.Window[field]==="auto")&&!/^[a-z]{2}-[A-Za-z0-9-]+$/.test(p.Window[field]))fail("Window."+field,"Código de idioma inválido.");
 if(p.Window.Theme&&!catalog.ThemeNames.includes(p.Window.Theme))fail("Window.Theme","Tema não encontrado.");
 const size=p.Window.Size;if(size&&(![size.X,size.Y].every(Number.isFinite)||size.X<300||size.Y<300||size.X>2400||size.Y>1800))fail("Window.Size","Tamanho de janela inválido.");
 for(const [key,min,max]of [["Scale",.75,1.5],["TextScale",.8,1.4]])if(p.Window[key]!==undefined&&(!Number.isFinite(p.Window[key])||p.Window[key]<min||p.Window[key]>max))fail("Window."+key,"Escala fora do intervalo.");
 const windowKeys=new Set(["Id","Title","Subtitle","Theme","Locale","SourceLocale","FallbackLocale","Size","Scale","TextScale","ReducedMotion","PixelIcons","PixelDecorations","ShowProfile","Settings","LauncherText","TextKeys"]);
 for(const key of Object.keys(p.Window))if(!windowKeys.has(key))fail("Window."+key,"Opção de janela não suportada.");
 const allowed=new Set(catalog.OptionKeys),seen=new Set(),templates=new Map(),stateIds=new Set();let count=0,sections=0;
 function settings(type,o,path){
  if(!o||typeof o!=="object"||Array.isArray(o)){fail(path,"Propriedades precisam ser um objeto.");return;}
  for(const key of Object.keys(o))if(!allowed.has(key))fail(path+"."+key,"Propriedade não suportada.");
  for(const key of ["Visible","Disabled","Persist","Searchable","Translate","Multi","Live","Multiline"])if(o[key]!==undefined&&typeof o[key]!=="boolean")fail(path+"."+key,"Use verdadeiro ou falso.");
  if(o.Icon!==undefined&&o.Icon!==false&&!catalog.IconNames.includes(o.Icon)&&!/^(rbxassetid:\/\/\d+|\d+)$/.test(String(o.Icon)))fail(path,"Ícone não encontrado.");
  if(type==="Toggle"&&o.Default!==undefined&&typeof o.Default!=="boolean")fail(path,"Valor de Toggle precisa ser boolean.");
  if(["Input","Label","Separator","Console"].includes(type)&&o.Default!==undefined&&typeof o.Default!=="string")fail(path,"Valor inicial precisa ser texto.");
  if(type==="Slider"&&(![o.Min,o.Max].every(Number.isFinite)||o.Max<=o.Min||o.Step!==undefined&&(!Number.isFinite(o.Step)||o.Step<=0)))fail(path,"Intervalo de slider inválido.");
  if(type==="Dropdown"&&(!Array.isArray(o.Options)||o.Options.length>256||o.Options.some(v=>typeof v!=="string")||new Set(o.Options).size!==o.Options.length))fail(path,"Opções de dropdown inválidas ou repetidas.");
  if(type==="ColorPicker"&&typeof o.Default==="string"&&!/^#(?:[0-9a-f]{3}|[0-9a-f]{6})$/i.test(o.Default))fail(path,"Cor HEX inválida.");
  if(type==="Preview"&&o.Mode&&o.Mode!=="Image")fail(path,"Modelos 3D precisam ser conectados no Luau.");
  if(type==="CardGrid"){
   if(!Array.isArray(o.Items)||o.Items.length>5000)fail(path,"Grade aceita até 5000 cards.");
   else {const ids=new Set();for(const item of o.Items){if(!item||typeof item.Id!=="string"||!item.Id||item.Id.length>128||ids.has(item.Id))fail(path,"Id de card inválido ou repetido.");if(item){ids.add(item.Id);if(item.Badges&&(!Array.isArray(item.Badges)||item.Badges.length>4||item.Badges.some(b=>typeof b!=="string"||bytes(b)>64)))fail(path,"Badges de card inválidos.");}}}
   for(const [key,min,max]of [["Height",180,900],["CardHeight",120,300],["MinCardWidth",140,600],["Columns",1,6],["Gap",0,24]])if(o[key]!==undefined&&(!Number.isFinite(o[key])||o[key]<min||o[key]>max))fail(path,"Dimensões da grade inválidas.");
  }
  if(type==="Form"){
   if(!Array.isArray(o.Fields)||o.Fields.length<1||o.Fields.length>64)fail(path,"Formulário precisa de 1–64 campos.");
   else {const ids=new Set();for(const field of o.Fields){
    if(!field||!groupPattern.test(field.Id||"")||ids.has(field.Id)||["_title","_status","_apply","_cancel"].includes(field.Id)||!["Input","Toggle","Slider","Dropdown","ColorPicker"].includes(field.Type)){fail(path,"Campo de formulário inválido ou repetido.");continue;}
    ids.add(field.Id);if(field.Required!==undefined&&typeof field.Required!=="boolean")fail(path,"Required precisa ser boolean.");
    const child={...field};for(const key of ["Id","Type","Required","TextKeys"])delete child[key];settings(field.Type,child,path+"/"+field.Id);
   }}
  }
 }
 for(const t of p.Templates){
  if(!t||!groupPattern.test(t.Id||"")||templates.has(t.Id)||!Array.isArray(t.Controls)||t.Controls.length>32){fail("Templates","Modelo inválido.");continue;}templates.set(t.Id,t);
  const ids=new Set();for(const child of t.Controls){if(!child||!groupPattern.test(child.Id||"")||ids.has(child.Id)||!catalog.Controls[child.Type]||child.Type==="Form"){fail("Templates."+t.Id,"Componente de modelo inválido.");continue;}ids.add(child.Id);settings(child.Type,child.Options,"Templates."+t.Id);}
 }
 walk(p,(n,parent,kind)=>{
  if(!n||!idPattern.test(n.Id||"")||n.Id.startsWith("__retrobox/")||seen.has(n.Id)){fail("Structure","Ids precisam ser únicos e válidos.");return;}seen.add(n.Id);
  if(kind==="tab"&&(!Array.isArray(n.Sections)||![undefined,1,2].includes(n.Columns)))fail(n.Id,"Aba inválida.");
  if(kind==="section"){sections++;if(!Array.isArray(n.Controls))fail(n.Id,"Seção sem lista de componentes.");}
  if(kind==="control"){
   count++;if(n.Type==="Row"){if(parent.Type==="Row"||!Array.isArray(n.Children))fail(n.Id,"Linhas não podem ser aninhadas.");}
   else if(n.Type==="Component"){
    const t=templates.get(n.Template);if(!t||!groupPattern.test(n.Id))fail(n.Id,"Modelo reutilizável inexistente ou Id inválido.");
    if(n.Props!==undefined&&(!n.Props||typeof n.Props!=="object"||Array.isArray(n.Props)))fail(n.Id,"Props precisa ser um objeto.");
    else for(const [id,o]of Object.entries(n.Props||{})){const child=t?.Controls.find(c=>c.Id===id);if(!child)fail(n.Id,"Props aponta para um filho inválido.");else settings(child.Type,{...child.Options,...o},n.Id+"/"+id);}count+=t?.Controls.length||0;
   }else if(!catalog.Controls[n.Type])fail(n.Id,"Componente não suportado.");
   else {settings(n.Type,n.Options||{},n.Id);if(n.Type==="Form"){count+=n.Options?.Fields?.length||0;if(!groupPattern.test(n.Id))fail(n.Id,"Id do formulário inválido.");}}
  }
 });
 if(count>256||sections>128)fail("Structure","Limite de controles ou seções excedido.");
 const aliases=new Set(seen);
 walk(p,n=>{const children=n?.Type==="Form"?n.Options?.Fields:n?.Type==="Component"?templates.get(n.Template)?.Controls:[];for(const child of Array.isArray(children)?children:[])if(child){const key=n.Id+"/"+child.Id;if(aliases.has(key))fail(key,"Id interno de componente em conflito.");aliases.add(key);}});
 for(const state of p.States){if(!state||!groupPattern.test(state.Id||"")||stateIds.has(state.Id))fail("States","Id de estado inválido ou repetido.");if(state)stateIds.add(state.Id);}
 const params=s=>[...new Set(s.match(/\{[A-Za-z0-9_]+\}/g)||[])].sort().join("|");
 for(const [key,entry]of Object.entries(p.Translations)){
  if(!key||bytes(key)>256||!entry||typeof entry.Source!=="string"||bytes(entry.Source)>8192||!entry.Values||typeof entry.Values!=="object"||Array.isArray(entry.Values)){fail("Translations","Mensagem inválida.");continue;}
  for(const [code,value]of Object.entries(entry.Values))if(!/^[a-z]{2}-[A-Za-z0-9-]+$/.test(code)||typeof value!=="string"||bytes(value)>8192||params(value)!==params(entry.Source))fail("Translations."+key,"Tradução inválida ou parâmetros alterados.");
 }
 function keys(owner,path){for(const [property,key]of Object.entries(owner?.TextKeys||{}))if(!["Title","Subtitle","Description","Text","Placeholder"].includes(property)||!p.Translations[key])fail(path,"Chave de tradução desconhecida: "+key);}
 keys(p.Window,"Window");walk(p,n=>{keys(n,n?.Id||"Structure");if(n?.Type==="Form")for(const f of n.Options?.Fields||[])keys(f,n.Id);});
 let graphErrors=[];if(!errors.length)graphErrors=graphValidation(p,catalog,controlMap(p));return {ok:errors.length===0&&(options.allowDraft||graphErrors.length===0),errors,graphErrors,project:p};
}
function addEdge(p,e,catalog){
 const next=clone(p);next.Flow.Edges.push(clone(e));const old=graphValidation(p,catalog,controlMap(p)),issues=graphValidation(next,catalog,controlMap(next)),incomplete=e=>/Entrada sem ligação|Escolha|Defina/.test(e.message);
 const fresh=issues.filter(e=>!incomplete(e)&&!old.some(x=>x.path===e.path&&x.message===e.message));if(fresh.length)throw Error(fresh[0].message);return next;
}
function translation(p,key,locale,args){const entry=p.Translations?.[key],value=entry?(entry.Values?.[locale]??entry.Source):key;return String(value??"").replace(/\{([A-Za-z0-9_]+)\}/g,(all,k)=>args&&args[k]!==undefined?String(args[k]):all);}
function collectTranslations(input){
 const p=clone(input);p.Translations=p.Translations||{};
 function message(owner,property,text,id){if(typeof text!=="string"||!text)return;owner.TextKeys=owner.TextKeys||{};const key=owner.TextKeys[property]||(id+"."+property).slice(0,240);owner.TextKeys[property]=key;if(p.Translations[key]?.Source!==text)p.Translations[key]={Source:text,Context:id+" / "+property,Values:{}};}
 message(p.Window,"Title",p.Window.Title,"window");message(p.Window,"Subtitle",p.Window.Subtitle,"window");
 for(const t of p.Templates||[])for(const child of t.Controls)if(child.Options?.Translate!==false)for(const key of ["Title","Description","Text","Placeholder"])message(child,key,child.Options?.[key],"template."+t.Id+"/"+child.Id);
 walk(p,(n,parent,kind)=>{if(!n||n.Options?.Translate===false)return;if(kind!=="control")message(n,"Title",n.Title,n.Id);else for(const key of ["Title","Description","Text","Placeholder"])message(n,key,n.Options?.[key],n.Id);if(n.Type==="Form")for(const field of n.Options.Fields)for(const key of ["Title","Description","Placeholder"])message(field,key,field[key],n.Id+"/"+field.Id);
 if(n.Type==="Component")for(const [child,o]of Object.entries(n.Props||{}))for(const key of ["Title","Description","Text","Placeholder"]){const text=o[key];if(typeof text==="string"&&text){const id="instance."+n.Id+"/"+child+"."+key;if(p.Translations[id]?.Source!==text)p.Translations[id]={Source:text,Context:n.Id+"/"+child,Values:{}};}}});
 for(const n of p.Flow.Nodes)for(const prop of ["Text","Title"])if(typeof n[prop]==="string"&&n[prop]&&!p.Translations[n[prop]]){const key="flow."+n.Id+"."+prop;p.Translations[key]={Source:n[prop],Context:n.Id,Values:{}};n[prop]=key;}
 return p;
}
function syncTextSources(p){function sync(owner,source){for(const [prop,key]of Object.entries(owner?.TextKeys||{})){const e=p.Translations?.[key],v=source?.[prop];if(e&&typeof v==="string"&&e.Source!==v){e.Source=v;e.Values={};}}}sync(p.Window,p.Window);walk(p,n=>{sync(n,n?.Options||n);if(n?.Type==="Form")for(const f of n.Options?.Fields||[])sync(f,f);});for(const t of p.Templates||[])for(const child of t.Controls||[])sync(child,child.Options);return p;}
function compile(input,catalog,mode="standalone"){
 const checked=validateProject(input,catalog);if(!checked.ok)throw Error([...checked.errors,...checked.graphErrors].map(e=>e.path+": "+e.message).join("\n"));
 const p=collectTranslations(checked.project),lines=["-- RetroBox Designer 2.5.1 | API 2 | generated Luau","-- Reopen JSON in the Designer. Connect custom actions in the actions table."],used=[...new Set(p.Flow.Nodes.filter(n=>n.Type==="Call").map(n=>n.Action))];
 if(mode==="module")lines.push("return function(Library, actions)","actions = actions or {}",'assert(type(Library.GetDesignerCatalog) == "function", "RetroBox 2.5.1 or later is required")');
 else {lines.push('local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/ManoGustavo02/RetroBox/main/dist/bootstrap/v2.lua"))({Channel="stable", MinVersion="2.5.1"})',"local actions = {}");for(const name of used)lines.push("actions["+luaString(name)+"] = function(ctx, value, flow)","    -- TODO: connect your application logic here.",'    return false, "Action is not connected: '+name+'"',"end");}
 for(const name of used)lines.push('assert(type(actions['+luaString(name)+']) == "function", '+luaString("Connect action before creating the interface: "+name)+')');
 const w=clone(p.Window);delete w.TextKeys;delete w.Size;w.Translations=p.Translations;let literal=lua(w);if(p.Window.Size)literal=literal.slice(0,-1)+',\n    ["Size"] = Vector2.new('+p.Window.Size.X+", "+p.Window.Size.Y+")\n}";
 lines.push("local window = Library:CreateWindow("+literal+")","local controls, states = {}, {}");
 function bind(owner,keys,type){
  for(const [property,key]of Object.entries(keys||{})){
   let field=({Title:"TitleLabel",Description:"DescriptionLabel",Text:type==="Button"?"Button":"TitleLabel",Placeholder:"Input"})[property];
   if(type==="Window"&&property==="Subtitle")field="SubtitleLabel";if(type==="Tab")field="Label";if(type==="Section")field="Header";
   if(type==="Form")field=property==="Title"?"Header.TitleLabel":property==="Description"?"Header.DescriptionLabel":null;
   if(field){const line="window:BindText("+owner+"."+field+", "+luaString(property==="Placeholder"?"PlaceholderText":"Text")+", "+luaString(key)+")";lines.push(type==="Form"?"if "+owner+".Header then "+line+" end":line);}
  }
 }
 bind("window",p.Window.TextKeys,"Window");for(const s of p.States)lines.push("states["+luaString(s.Id)+"] = window:CreateState("+lua(s.Value)+")");
 p.Templates.forEach((t,i)=>{
  lines.push("local componentName_"+i+' = "designer-" .. Library:SHA256('+luaString(p.Window.Id+"/"+t.Id)+"):sub(1,24)","Library:RegisterComponent(componentName_"+i+", function(ctx, props)");
  for(const child of t.Controls)lines.push("    do","        local options = "+lua({...child.Options,Id:child.Id}),"        for key,value in pairs(props["+luaString(child.Id)+'] or {}) do if key ~= "Id" then options[key] = value end end',"        ctx:Add("+luaString(child.Type)+", options)","    end");lines.push("end, {Replace=true})");
 });
 let tabN=0,sectionN=0,rowN=0;
 function emit(list,section){
  for(const n of list){
   if(n.Type==="Row"){const row="row_"+ ++rowN;lines.push("local "+row+" = "+section+":CreateRow("+lua(n.Options||{})+")");emit(n.Children,row);continue;}
   const ref="controls["+luaString(n.Id)+"]";
   if(n.Type==="Component"){lines.push(ref+" = "+section+":AddComponent(componentName_"+p.Templates.findIndex(t=>t.Id===n.Template)+", "+lua({Id:n.Id,Props:n.Props||{}})+")","for id,control in pairs("+ref+".Children) do controls["+luaString(n.Id+"/")+" .. id] = control end");continue;}
   lines.push(ref+" = "+section+":"+catalog.Controls[n.Type].Method+"("+lua({...n.Options,Id:n.Id})+")");if(n.Options?.Translate!==false)bind(ref,n.TextKeys,n.Type);
   if(n.Type==="Form")for(const f of n.Options.Fields){lines.push("controls["+luaString(n.Id+"/"+f.Id)+"] = "+ref+".Fields["+luaString(f.Id)+"]");bind(ref+".Fields["+luaString(f.Id)+"]",f.TextKeys,f.Type);}
  }
 }
 for(const tab of p.Tabs){const t="tab_"+ ++tabN;lines.push("local "+t+" = window:CreateTab("+lua({Title:tab.Title,Icon:tab.Icon,Columns:tab.Columns||1})+")");bind(t,tab.TextKeys,"Tab");
 for(const section of tab.Sections){const s="section_"+ ++sectionN;lines.push("local "+s+" = "+t+":CreateSection("+lua({Title:section.Title,Icon:section.Icon,Side:section.Side,Collapsible:section.Collapsible,Collapsed:section.Collapsed})+")");bind(s,section.TextKeys,"Section");emit(section.Controls,s);}}
 lines.push("local flow = window:CreateFlowGraph("+lua(p.Flow)+", {Controls=controls, States=states, Actions=actions})","return {Window=window, Controls=controls, States=states, Flow=flow}");if(mode==="module")lines.push("end");return lines.join("\n\n")+"\n";
}
return {clone,lua,luaString,newProject,walk,find,controlMap,defaultValue,graphValidation,validateProject,addEdge,translation,collectTranslations,syncTextSources,compile,edge,bytes};
});
