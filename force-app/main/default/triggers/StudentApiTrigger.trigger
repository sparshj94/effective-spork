trigger StudentApiTrigger on Student__c (after insert) {
	List<Student__c> stList = Trigger.new;
    for(Student__c st : stList){
        SmsSend.send(st.Student_Name__c);
    }
}