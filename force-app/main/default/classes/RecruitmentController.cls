public with sharing class RecruitmentController {
    
    public class CollegeWrapper{
        @AuraEnabled public String collegeName;
        @AuraEnabled public Id collegeId;
        @AuraEnabled public List<YearWrapper> years;
    }
    public class YearWrapper{
        @AuraEnabled public String year;
        @AuraEnabled public List<ProfileWrapper> profiles;
    }
    public class ProfileWrapper{
        @AuraEnabled public String profileName;
        @AuraEnabled public List<Hiring_Fresh_Graduates__c> students;
    }
    @AuraEnabled(cacheable = true)
    public static List<CollegeWrapper> getRecruitmentData(){
        List<CollegeWrapper> res = new List<CollegeWrapper>();
        List<College_Information__c> colleges = [SELECT Id, Name, (SELECT Id, Name, Email__c, Drive_Year__c, Phone__c, Profile__c, Status__c FROM 
                Hiring_Fresh_Graduates__r ORDER BY Drive_Year__c DESC, Profile__c ASC)  FROM College_Information__c ];
        System.debug(colleges);
        for (College_Information__c col : colleges) {
            CollegeWrapper cw = new CollegeWrapper();
            cw.collegeName = col.Name;
            cw.collegeId = col.Id;
            cw.years = new List<YearWrapper>();
			System.debug(col);
            Map<String, Map<String, List<Hiring_Fresh_Graduates__c>>> yearProfileMap = new Map<String, Map<String, List<Hiring_Fresh_Graduates__c>>>();
            for (Hiring_Fresh_Graduates__c student : col.Hiring_Fresh_Graduates__r) {
                String year = student.Drive_Year__c;
                String profile = student.Profile__c;
                if(!yearProfileMap.containsKey(year)){
                    yearProfileMap.put(year, new Map<String,List<Hiring_Fresh_Graduates__c>>());
                }
                if(!yearProfileMap.get(year).containsKey(profile)){
                    yearProfileMap.get(year).put(profile, new List<Hiring_Fresh_Graduates__c>());
                }
                yearProfileMap.get(year).get(profile).add(student);
                System.debug(yearProfileMap);
            }
            // wrapper
            for (String year  : yearProfileMap.keySet()) {
                System.debug('In year wrapper'+year);
                YearWrapper yw = new YearWrapper();
                yw.year = year;
                yw.profiles = new List<ProfileWrapper>();
                System.debug(yw);
                Map<String, List<Hiring_Fresh_Graduates__c>> profileMap = yearProfileMap.get(year);
                System.debug('Profile map');
                System.debug(profileMap);
                for(String profile: profileMap.keySet()){
                    ProfileWrapper pw = new ProfileWrapper();
                    pw.profileName = profile;
                    pw.students = profileMap.get(profile);
                    yw.profiles.add(pw);
                    System.debug(pw);
                }
                System.debug('afyer profile map processing');
        
                cw.years.add(yw);
                System.debug('afyre add year wp in cw');
                System.debug(cw);
            }
            res.add(cw);
            System.debug(res);
        }
        
        System.debug(res);
        return res;
    }
}