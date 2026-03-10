import { LightningElement, wire, track } from 'lwc';

export default class KanbanBoard extends LightningElement {
    draggedTaskId;
    stages = ['To Do', 'In Progres', 'QA Sandbox', 'Production'];
    @track tasks = []
    isInputFieldToDisplay = false;
    isToDrag = false;
    isSelected = false;
    @track selectedTasks = [];
    @track Values;
    handleAddTask(){
        this.isInputFieldToDisplay = true;
    }
    handleReadyTask(){
        console.log('in ready task');
        this.selectedTasks.map(res=>{
            console.log(res.task);
            console.log(res.isDragable);
            
        })
    }
    handleCheckbox(){
        this.isSelected = !this.isSelected
        
    }
    
     handleChangeCheck(event) {      
        this.Values =  event.target.value;
        // console.log(event.target.value) ;
        console.log('chk',event.target.checked);
        
        if (event.target.checked) {
            console.log('tru');
            this.tasks.map(t=>{
                console.log(t.task);
                console.log(t.isDragable);
            })
            // this.tasks.filter(t=>t.task===this.Values).forEach(t=>t.isDragable = true);
            this.tasks.filter(t=>t.task===this.Values).forEach(t=>{
                //change color also 
                t.isDragable = true
                this.selectedTasks.push({task:this.Values, isDragable:true});
            });

            this.selectedTasks.map(t=>{
                console.log('r',t.task);
                console.log(t.isDragable);
                
            })

            // this.selectedTasks.push( {task: this.Values, isDragable:true});
            // console.log(this.selectedTasks[0].task);
            
        } else {
            // try {
            //     this.index = this.selectedTasks.indexOf( this.Values);
            //     this.selectedTasks.splice(this.index, 1);
            // } catch (err) {
            //     //error message
            // }
            console.log('else');
            
        }
        // this.selectedTasks.map(res =>{
        //     console.log(res);
            
        // })
    }

    addTask(){
        // console.log('add taks2');
        const task = this.template.querySelector('lightning-input').value;
        // console.log('t1',task);
        this.tasks.push({task:task, isDragable:false});
        // this.tasks = [...this.tasks, ...task];
        // console.log('tarr',task);
        this.isInputFieldToDisplay = false;
    }

    handleDragStart(event) {
        if(this.isToDrag){
            this.draggedTaskId = event.currentTarget.dataset.id;
        }
        
    }

    handleDragOver(event) {
        event.preventDefault(); // allow drop
    }

    handleDrop(event) {
        event.preventDefault();
    }
}