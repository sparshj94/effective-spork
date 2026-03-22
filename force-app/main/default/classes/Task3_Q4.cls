public with sharing class Task3_Q4 {
    
    public void createTask(Id userId){
        Task tsk = new Task();
        tsk.Subject = 'Verification Task';
        tsk.Status = 'In Progress';
        tsk.Priority = 'High';
        tsk.OwnerId = userId;
        tsk.Description = 'Verify 2000 Account and Contact Records';
        Database.insert(tsk, false);
    }
}