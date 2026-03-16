import { LightningElement, track } from 'lwc';

export default class KanbanSelf extends LightningElement {

    @track tasks=[];
    @track isModalOpen = false;
    newTaskName ='';
    taskCounterId = 1;



    get todoTasks(){
        return this.tasks.filter(t=>t.stage==='To Do').map(t=>({
            ...t,
            isDraggable:t.isReady,
            cssClass: t.isReady ? 'ready-task task-card' : 'task-card'
        }))
    }
    get inProcessTasks(){
        return this.formatTaskForStage('In Process');
    }
    get qaTasks(){
        return this.formatTaskForStage('QA Sandbox');
    }
    get prodTasks(){
        return this.formatTaskForStage('Production');
    }

    formatTaskForStage(stage){
        return this.tasks.filter(t=> t.stage===stage).map(tsk=>({
            ...tsk,
            isDraggable: stage!=='Production',
            cssClass: 'task-card ready-task'
        }))
    }


    handleAddTask(){
        this.isModalOpen = true;
    }

    handleInputChange(event){
        this.newTaskName = event.target.value;
    }

    saveNewTask(){
        if(this.newTaskName.trim()!==''){
            this.tasks.push({
                id:String(this.taskCounterId++),
                name:this.newTaskName,
                stage:'To Do',
                isReady:false,
                selected:false
            });
            this.closeModal();
        }
    }
    handleReadyTask(){
        this.tasks = this.tasks.map(tsk=>{
            if(tsk.selected && tsk.stage==='To Do'){
                return {...tsk, isReady:true}
            }
            return tsk;
        })
    }
    handleCheckboxChange(event){
        let id = event.target.dataset.id;
        let isChecked = event.target.checked;
        let index = this.tasks.findIndex(t=>t.id===id);
        this.tasks[index].selected = isChecked;
    }

    closeModal() {
        this.isModalOpen = false;
        this.newTaskName = '';
    }
    handleDragStart(event) {
        const taskId = event.target.dataset.id;
        event.dataTransfer.setData('taskId', taskId);
    }
    handleDragOver(event) {
        event.preventDefault(); 
    }
    handleDrop(event){
        event.preventDefault();
        const taskId = event.dataTransfer.getData('taskId');
        const newStage = event.currentTarget.dataset.stage;
        const taskindex = this.tasks.findIndex(t=>t.id===taskId);
        if (taskindex !== -1) {
            if (this.tasks[taskindex].stage === 'Production') {
                return; 
            }
            
            this.tasks[taskindex].stage = newStage;
            this.tasks = [...this.tasks];
        }
    }
}