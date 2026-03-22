public with sharing class SysAdminReviewQ_Q4 implements Queueable{
    User userInfos = [SELECT Id, Name FROM User WHERE Profile.Name = 'System Administrator' AND isActive = True AND Name = 'Sparsh Jain'];
    Id userId = userInfos.Id;

    public void execute(QueueableContext qc){
        Task3_Q4 tsk = new Task3_Q4();
        tsk.createTask(userId);
    }
}