public with sharing class Schedule24_Q3 implements Schedulable{
    
    public void execute(SchedulableContext sc){
        AssigningCase_Q3 ascd = new AssigningCase_Q3();
        Database.executeBatch(ascd,200);
    }
}