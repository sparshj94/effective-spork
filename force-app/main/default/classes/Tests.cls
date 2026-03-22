public class Tests {
    public static void mm(){
    
        List<Contact> conList = new List<Contact>();
        for(Integer i=1; i<=15; i++){
            conList.add(new Contact(LastName = 'Testmmm '+i, AccountId='001fj00000e6Md7AAE'));
        }
		Database.insert(conList);
        System.debug('Contact inserted success');
		
    }
    public static void mn(){
        List<AggregateResult> cs = [SELECT  Status, COUNT(Id)cnt FROM Case group by Status];
        for(AggregateResult css : cs){
            System.debug(css);
            System.debug(css.get('cnt'));
        }
    }
    
    public static void b(){
        List<Student__c> st = [select name, test__c from student__c];
        for(Student__c stt: st){
            System.debug(stt.test__c);
        }
    }
}