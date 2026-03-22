public with sharing class QuizController {
    
    @AuraEnabled(cacheable = true)
    public static List<Question__c> getQuizQuestions(){
        List<Question__c> allQuestions = [SELECT Id, Name, OptionA__c, OptionB__c, OptionC__c, OptionD__c, Correct_Answer__c FROM Question__c LIMIT 10];
        List<Question__c> randomQuestions = new List<Question__c>();

        while(randomQuestions.size() < 10 && allQuestions.size() > 0){

            Integer randomIndex = Math.mod(
                Math.abs(Crypto.getRandomInteger()),
                allQuestions.size()
            );

            randomQuestions.add(allQuestions[randomIndex]);
            allQuestions.remove(randomIndex);
        }

        return randomQuestions;
    }

    @AuraEnabled
    public static String saveAttendee(String firstName, String lastName, String email){
        Quiz_Attendee__c qa = new Quiz_Attendee__c();
        qa.First_Name__c = firstName;
        qa.Last_Name__c = lastName;
        qa.Email__c = email;
        Database.insert(qa,false);
        return 'Successfully created';
    }
}