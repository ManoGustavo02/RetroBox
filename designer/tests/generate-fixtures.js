"use strict";
const fs=require("node:fs"),path=require("node:path"),C=require("../src/core.js"),catalog=require("../schema.json");
const examples=path.join(__dirname,"../examples"),fixtures=path.join(__dirname,"fixtures");fs.mkdirSync(fixtures,{recursive:true});
function save(name,p){fs.writeFileSync(path.join(examples,name+".retrobox.json"),JSON.stringify(p,null,2)+"\n");fs.writeFileSync(path.join(fixtures,name+".lua"),C.compile(p,catalog,"module"));}
save("starter",C.newProject());
const all=C.newProject();all.Window.Id="all-components";all.Flow={Id:"all-components",Nodes:[],Edges:[]};all.Tabs[0].Sections[0].Controls=Object.entries(catalog.Controls).map(([Type,s])=>({Id:Type.toLowerCase(),Type,Options:C.clone(s.Defaults)}));save("all-components",all);
const p=C.newProject();p.Window.Id="reusable-form";p.Templates=[{Id:"stats",Controls:[{Id:"coins",Type:"StatCard",Options:{Title:"Moedas",Default:5}},{Id:"key",Type:"Keybind",Options:{Default:"F",Title:"Atalho"}}]}];p.Tabs[0].Sections[0].Controls.push({Id:"stats1",Type:"Component",Template:"stats",Props:{}},{Id:"settings",Type:"Form",Options:C.clone(catalog.Controls.Form.Defaults)});save("reusable-form",p);
