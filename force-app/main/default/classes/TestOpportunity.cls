@IsTest
public class TestOpportunity {
    
    @testSetup
    static void setup(){
        
        Account acc1 = new Account(Name = 'Testm1');
        Account acc2 = new Account(Name = 'Testm2');
        List<Account> accList = new List<Account>{acc1,acc2};
        insert accList;
        
        Opportunity op1 = new Opportunity(AccountId = acc1.Id, Name= 'OppT1', CloseDate=System.today(), Amount=1000, StageName = 'Prospecting');
        Opportunity op2 = new Opportunity(AccountId = acc2.Id, Name= 'OppT2', CloseDate=System.today(), Amount=1000, StageName = 'Prospecting');
        List<Opportunity> oppList = new List<Opportunity>{op1,op2};
        insert oppList;
    }
    
    @IsTest
    static void test2(){
        Account acc1 = new Account(Name = 'Testm1');
        Account acc2 = new Account(Name = 'Testm2');
        List<Account> accList = new List<Account>{acc1,acc2};
        insert accList;
        
        Opportunity op1 = new Opportunity(AccountId = acc1.Id, Name= 'OppT1', CloseDate=System.today(), Amount=1000, StageName = 'Prospecting');
        List<Opportunity> oppList = new List<Opportunity>{op1};
        insert oppList;
        
        //delete accList[0];
        //System.assert(false,'Cannot Delete');
        delete accList[1];
        System.assert(false,'Can Delete');
    }
}