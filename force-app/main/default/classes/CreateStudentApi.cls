@RestResource(urlMapping = '/createstudent')
global class CreateStudentApi {
	
    @HttpPost
    global static String createStudent(){
        RestRequest req = RestContext.request;
        String str = req.requestBody.toString();
        Map<String,Object> mapObj = (Map<String,Object>)json.deserializeUntyped(str);
        String name = String.valueOf(mapObj.get('Name'));
        String phone = String.valueOf(mapObj.get('phone'));
        String email = String.valueOf(mapObj.get('email'));
        String courseOpted = String.valueOf(mapObj.get('courseOpted'));
        Student__c st = new Student__c(	Student_Name__c = name, Student_Phone__c = phone, 	Student_Email__c = email, Course_Opted__c = courseOpted);
        Database.saveResult sv = Database.insert(st,false);
        Map<String, Object> result = new Map<String,Object>();
        if(sv.isSuccess()){
            result.put('Status', 'Success');
            result.put('Id', sv.getId());
            result.put('Name', st.Student_Name__c);
        } else{
            List<Database.error> err = sv.getErrors();
            String error = '';
            for(Database.Error e : err){
                error+=e.getMessage();
            }
            result.put('Status', 'Error');
            result.put('Message', error);
            //return error;
        }
        String res = JSON.serialize(result);
        return res;
    }
}