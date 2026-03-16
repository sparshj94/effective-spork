import { LightningElement, track } from 'lwc';

export default class KanbanBoard extends LightningElement {
    // Start with a completely empty array for dynamic user creation
    @track tasks = [];
    
    @track isModalOpen = false;
    newTaskName = '';
    
    // Start the counter at 1 for dynamically generated tasks
    taskIdCounter = 1; 

    // Getters to filter tasks for each column and compute their CSS/Draggable state
    get todoTasks() {
        return this.tasks.filter(t => t.stage === 'To Do').map(t => ({
            ...t,
            cssClass: t.isReady ? 'task-card ready-task' : 'task-card',
            isDraggable: t.isReady
        }));
    }

    get inProcessTasks() { return this.formatTasksForStage('In Process'); }
    get qaTasks() { return this.formatTasksForStage('QA Sandbox'); }
    get prodTasks() { return this.formatTasksForStage('Production'); }

    // Helper for formatting tasks outside of 'To Do'
    formatTasksForStage(stage) {
        return this.tasks.filter(t => t.stage === stage).map(t => ({
            ...t,
            cssClass: 'task-card ready-task', // Keeps the color once moved
            isDraggable: stage !== 'Production' // Disables dragging if in Production
        }));
    }

    // Modal Handlers
    handleAddTask() {
        this.isModalOpen = true;
    }

    closeModal() {
        this.isModalOpen = false;
        this.newTaskName = '';
    }

    handleInputChange(event) {
        this.newTaskName = event.target.value;
    }

    // This method handles the dynamic creation of tasks
    saveNewTask() {
        if (this.newTaskName.trim() !== '') {
            this.tasks = [
                ...this.tasks,
                {
                    id: String(this.taskIdCounter++), // Assigns a unique ID to every new task
                    name: this.newTaskName,
                    stage: 'To Do',
                    isReady: false,
                    selected: false
                }
            ]
            // this.tasks.push({
            //     id: String(this.taskIdCounter++), // Assigns a unique ID to every new task
            //     name: this.newTaskName,
            //     stage: 'To Do',
            //     isReady: false,
            //     selected: false
            // });
            this.closeModal();
        }
    }

    // Checkbox and Ready Button Logic
    handleCheckboxChange(event) {
        const taskId = event.target.dataset.id;
        const isChecked = event.target.checked;
        
        // const taskIndex = this.tasks.findIndex(t => t.id === taskId);
        this.tasks = this.tasks.map(tsk=>{
            if(tsk.id===taskId){
                return {...tsk, selected:isChecked}
            }
            return tsk;
        })
        // if (taskIndex !== -1) {
        //     this.tasks[taskIndex].selected = isChecked;
        // }
    }

    handleReadyTask() {
        this.tasks = this.tasks.map(task => {
            if (task.stage === 'To Do' && task.selected) {
                return { ...task, isReady: true };
            }
            return task;
        });
    }

    // Drag and Drop Logic
    handleDragStart(event) {
        const taskId = event.target.dataset.id;
        event.dataTransfer.setData('taskId', taskId);
    }

    handleDragOver(event) {
        event.preventDefault(); 
    }

    handleDrop(event) {
        event.preventDefault();
        const taskId = event.dataTransfer.getData('taskId');
        const newStage = event.currentTarget.dataset.stage;

        const taskIndex = this.tasks.findIndex(t => t.id === taskId);
        
        if (taskIndex !== -1) {
            if (this.tasks[taskIndex].stage === 'Production') {
                return; 
            }
            
            this.tasks[taskIndex].stage = newStage;
            this.tasks = [...this.tasks];
        }
    }
}