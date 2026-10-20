(function(root,factory){if(typeof module==="object"&&module.exports)module.exports=factory(require("./core.js"));else root.RetroBoxDesignerSimulator=factory(root.RetroBoxDesignerCore);})(globalThis,function(C){
"use strict";
return class Simulator {
 constructor(project,catalog,locale="pt-BR",update=()=>{}){
  const checked=C.validateProject(project,catalog);if(!checked.ok)throw Error([...checked.errors,...checked.graphErrors].map(e=>e.message).join("\n"));
  this.project=checked.project;this.catalog=catalog;this.locale=locale;this.onUpdate=update;this.controls=C.controlMap(this.project);this.values=Object.create(null);this.states=Object.create(null);this.views=Object.create(null);this.drafts=Object.create(null);this.logs=[];
  this.nodes=new Map(this.project.Flow.Nodes.map(n=>[n.Id,n]));this.inputs=new Map();this.outputs=new Map();
  for(const [id,n]of Object.entries(this.controls)){this.values[id]=C.defaultValue(n);this.views[id]={Visible:n.Options?.Visible!==false,Disabled:!!n.Options?.Disabled};}
  for(const s of this.project.States)this.states[s.Id]=C.clone(s.Value);
  for(const n of this.nodes.values()){this.inputs.set(n.Id,{});this.outputs.set(n.Id,{});}
  for(const e of this.project.Flow.Edges){this.inputs.get(e.To)[e.Input]=e;(this.outputs.get(e.From)[e.Out]||=[]).push(e);}
  for(const [id,n]of Object.entries(this.controls))if(n.Type==="Form")this.drafts[id]=C.clone(this.values[id]);this.refresh();
 }
 available(id){let key=id;while(key){const v=this.views[key];if(v&&(v.Disabled||!v.Visible))return false;const i=key.lastIndexOf("/");if(i<0)break;key=key.slice(0,i);}return !!this.controls[id];}
 log(kind,message){this.logs.push({kind,message,time:new Date().toLocaleTimeString()});if(this.logs.length>200)this.logs.shift();}
 input(n,port,cache){const e=this.inputs.get(n.Id)[port];return e?this.evaluate(e.From,cache):undefined;}
 read(n){return C.clone(n.State?this.states[n.State]:this.values[n.Control]);}
 evaluate(id,cache=new Map()){
  if(cache.has(id))return cache.get(id);
  const value=this.evaluateUncached(id,cache);cache.set(id,value);return value;
 }
 evaluateUncached(id,cache){
  const n=this.nodes.get(id),type=n.Type;if(type==="Constant")return C.clone(n.Value);if(["Value","Change","Apply"].includes(type))return this.read(n);
  if(type==="Not")return !this.input(n,"Value",cache);if(type==="Format")return C.translation(this.project,n.Text,this.locale,{value:this.input(n,"Value",cache)});
  const a=this.input(n,"A",cache),b=this.input(n,"B",cache);if(type==="And")return a&&b;if(type==="Or")return a||b;
  if(type==="Compare"){const same=C.lua(a)===C.lua(b);return {"==":()=>same,"~=":()=>!same,">":()=>a>b,">=":()=>a>=b,"<":()=>a<b,"<=":()=>a<=b}[n.Operator]();}
  if(type!=="Math"||![a,b].every(Number.isFinite))throw Error("Math precisa de números.");if(n.Operator==="/"&&b===0)throw Error("Divisão por zero.");
  const result={"+":()=>a+b,"-":()=>a-b,"*":()=>a*b,"/":()=>a/b,min:()=>Math.min(a,b),max:()=>Math.max(a,b)}[n.Operator]();if(!Number.isFinite(result))throw Error("Resultado numérico inválido.");return result;
 }
 normalize(id,value){const n=this.controls[id],o=n.Options||{};
  if(n.Type==="Slider"){if(typeof value!=="number"||!Number.isFinite(value))throw Error("Slider precisa de um número.");return Math.max(o.Min,Math.min(o.Max,Math.round((value-o.Min)/(o.Step||1))*(o.Step||1)+o.Min));}
  if(n.Type==="Toggle"&&typeof value!=="boolean")throw Error("Toggle precisa de verdadeiro/falso.");
  if(["Input","Label","Separator","Console"].includes(n.Type))return String(value??"");return C.clone(value);
 }
 write(n,value,property){
  if(n.State){this.states[n.State]=C.clone(value);return;}const id=n.Control,control=this.controls[id];
  if(property==="Value"&&["Form","Component"].includes(control.Type)){
   if(!value||typeof value!=="object"||Array.isArray(value))throw Error("O grupo precisa de um objeto de valores.");
   const prepared=Object.entries(value).map(([key,v])=>{const child=id+"/"+key;if(!this.controls[child])throw Error("Campo inexistente: "+key);return [child,this.normalize(child,v)];});
   for(const [key,v]of prepared){this.values[key]=v;if(control.Type==="Form")this.drafts[id][key.slice(id.length+1)]=C.clone(v);}
  }else if(property==="Value"||property==="Text"&&control.Type!=="Button")this.values[id]=this.normalize(id,value);
  else this.views[id][property]=C.clone(value);
 }
 refresh(){
  if(this.refreshing)return;this.refreshing=true;
  try{const bindings=[...this.nodes.values()].filter(n=>n.Type==="Binding"),maximum=bindings.length+2;
   for(let i=0;i<=maximum;i++){const before=JSON.stringify([this.values,this.states,this.views]);
    for(const [id,n]of Object.entries(this.controls))if(n.Type==="Component")this.values[id]=Object.fromEntries(Object.keys(this.controls).filter(key=>key.startsWith(id+"/")).map(key=>[key.slice(id.length+1),C.clone(this.values[key])]));
    for(const n of bindings)this.write(n,this.input(n,"Value"),n.Property);
    if(before===JSON.stringify([this.values,this.states,this.views]))break;if(i===maximum)throw Error("Os valores não estabilizaram.");
   }
  }catch(e){this.log("error",e.message);}this.refreshing=false;
 }
 setControl(id,value){
  if(!this.available(id))return;const old=JSON.stringify(this.values[id]);this.values[id]=this.normalize(id,value);
  for(const [formId,n]of Object.entries(this.controls))if(n.Type==="Form"&&id.startsWith(formId+"/"))this.drafts[formId][id.slice(formId.length+1)]=C.clone(this.values[id]);
  if(old!==JSON.stringify(this.values[id])){this.refresh();for(const n of this.nodes.values())if(n.Type==="Change"&&(n.Control===id||this.controls[n.Control]?.Type==="Component"&&id.startsWith(n.Control+"/")))this.trigger(n.Id);}
  this.refresh();this.onUpdate(this);
 }
 click(id){if(!this.available(id))return;for(const n of this.nodes.values())if(n.Type==="Click"&&n.Control===id)this.trigger(n.Id);this.onUpdate(this);}
 applyForm(id){
  const n=this.controls[id];if(!n||n.Type!=="Form")throw Error("Formulário inexistente.");if(!this.available(id))return false;const value=this.drafts[id];
  const invalid=n.Options.Fields.find(f=>f.Required&&(value[f.Id]==null||String(value[f.Id]).trim()===""));if(invalid){this.log("error","Campo obrigatório: "+invalid.Title);this.onUpdate(this);return false;}
  const changed=JSON.stringify(this.values[id])!==JSON.stringify(value);this.values[id]=C.clone(value);
  if(changed)for(const event of this.nodes.values())if(["Apply","Change"].includes(event.Type)&&event.Control===id)this.trigger(event.Id);
  this.refresh();this.onUpdate(this);return true;
 }
 cancelForm(id){this.drafts[id]=C.clone(this.values[id]);for(const [key,v]of Object.entries(this.drafts[id]))this.values[id+"/"+key]=C.clone(v);this.refresh();this.onUpdate(this);}
 trigger(id){
  let count=0;const next=(n,port)=>{for(const e of this.outputs.get(n.Id)[port]||[])execute(this.nodes.get(e.To));};
  const execute=n=>{
   if(++count>512)throw Error("Limite de execução do fluxo excedido.");const type=n.Type;
   if(type==="Branch"){next(n,this.input(n,"Condition")?"True":"False");return;}
   if(["SetValue","SetVisible","SetDisabled","SetText"].includes(type))this.write(n,this.input(n,"Value"),{SetValue:"Value",SetVisible:"Visible",SetDisabled:"Disabled",SetText:"Text"}[type]);
   else if(type==="Notify")this.log(n.Kind||"normal",this.input(n,"Message")||C.translation(this.project,n.Text,this.locale));
   else if(type==="Call"){this.log("pending","Conecte a ação no Luau: "+n.Action);return;}
   else if(type==="SetLocale")this.locale=n.Locale==="auto"?"pt-BR":n.Locale;
   else if(type==="ApplyForm"){if(!this.applyForm(n.Control))return;}else if(type==="CancelForm")this.cancelForm(n.Control);
   else throw Error("Ação inválida: "+type);next(n,"Then");
  };
  try{this.log("event","Evento: "+id);next(this.nodes.get(id),"Then");this.refresh();}catch(e){this.log("error",e.message);}
 }
};
});
