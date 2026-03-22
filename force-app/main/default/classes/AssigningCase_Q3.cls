public with sharing class AssigningCase_Q3 implements Database.Batchable<SObject>, Database.Stateful{
    List<Id> userIds = new List<Id>();
    Integer currentIndex = 0;
    public Database.QueryLocator start(Database.BatchableContext bc){
        List<User> userList = new List<User>([SELECT Id FROM User WHERE Profile.Name = 'Support Agent' AND isActive = True LIMIT 10]);
        for (User us : userList) {
            userIds.add(us.Id);
        }

        return Database.getQueryLocator([SELECT ID, OwnerId FROM Case WHERE Status != 'Closed']);
    }

    public void execute(Database.BatchableContext bc, List<Case> caseList){

        List<Case> casesToUpdate = new List<Case>();

        for (Case c : caseList) {
            // Assign the case to the agent
            c.OwnerId = userIds[currentIndex];
            casesToUpdate.add(c);

            currentIndex++;

            if (currentIndex >= userIds.size()) {
                currentIndex = 0;
            }
        }

        if (!casesToUpdate.isEmpty()) {
            update casesToUpdate;
        }
    }  

    public void finish(Database.BatchableContext bc){
        System.debug('Case Reassign successfully');
    }

}