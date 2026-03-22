import { LightningElement, wire, track } from 'lwc';
import getOpportunities from '@salesforce/apex/OpportunityKanbanController.getOpportunities';
import getStages from '@salesforce/apex/OpportunityKanbanController.getStages';
import updateOpportunity from '@salesforce/apex/OpportunityKanbanController.updateOpportunity';

export default class OpportunityKanban extends LightningElement {

@track columns = {};
@track stages = [];
@track showModal = false;
@track showTheme = false;
@track selected = {};
dragId;
colors = {};

@wire(getStages)
stageData({data}){
if(data){
this.stages = data;
}
}

@wire(getOpportunities)
oppData({data}){
if(data){
this.columns = {};
this.stages.forEach(s=>this.columns[s]=[]);
data.forEach(o=>{
if(!this.columns[o.StageName]){
this.columns[o.StageName] = [];
}
this.columns[o.StageName].push(o);
});
}
}

handleDrag(event){
this.dragId = event.target.dataset.id;
}

allowDrop(event){
event.preventDefault();
}

handleDrop(event){

event.preventDefault();

let stage = event.currentTarget.dataset.stage;

let opp;

Object.keys(this.columns).forEach(s=>{
this.columns[s] = this.columns[s].filter(o=>{
if(o.Id===this.dragId){
opp=o;
return false;
}
return true;
});
});

opp.StageName = stage;

this.columns[stage].push(opp);

updateOpportunity({opp:opp});
}

openModal(event){

let id = event.currentTarget.dataset.id;

Object.values(this.columns).forEach(list=>{
list.forEach(o=>{
if(o.Id===id){
this.selected = {...o};
}
});
});

this.showModal = true;
}

handleChange(event){

let field = event.target.dataset.field;
this.selected[field] = event.target.value;

localStorage.setItem(this.selected.Id,JSON.stringify(this.selected));
}

save(){

updateOpportunity({opp:this.selected}).then(()=>{

Object.keys(this.columns).forEach(s=>{
this.columns[s]=this.columns[s].map(o=>{
return o.Id===this.selected.Id ? this.selected : o;
});
});

localStorage.removeItem(this.selected.Id);

this.showModal=false;

});
}

openDraft(event){

let id = event.currentTarget.dataset.id;

let draft = localStorage.getItem(id);

if(draft){
this.selected = JSON.parse(draft);
this.showModal=true;
}
}

openTheme(){
this.showTheme=true;
}

handleColor(event){

let stage = event.target.dataset.stage;
let color = event.target.value;

let regex = /^#[0-9A-Fa-f]{6}$/;

if(regex.test(color)){
this.colors[stage] = color;
}
}

applyTheme(){

this.stages.forEach(stage=>{

let column = this.template.querySelector(`[data-stage="${stage}"]`);

if(column && this.colors[stage]){
column.style.backgroundColor = this.colors[stage];
}

});

this.showTheme=false;
}
}