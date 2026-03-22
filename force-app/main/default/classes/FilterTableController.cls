public with sharing class FilterTableController {


    @AuraEnabled(cacheable=true)
    public static List<Contact> getFilteredContacts(List<String> fields, List<String> conditions, List<String> values, List<String> filterFields, String conjunction){
        String baseQuery = 'SELECT Id,' + String.join(fields, ',') + ' FROM Contact';

        List<String> whereParts = new List<String>();

        for(Integer i=0;i<filterFields.size();i++){
            String field = filterFields[i];
            String cond = conditions[i];
            String val = values[i];

            if(cond == 'Equals'){
                whereParts.add(field + ' = \'' + val + '\'');
            }
            else if(cond == 'Contains'){
                whereParts.add(field + ' LIKE \'%' + val + '%\'');
            }
        }

        if(whereParts.size()>0){
            baseQuery += ' WHERE ' + String.join(whereParts, ' ' + conjunction + ' ');
        }

        baseQuery += ' ORDER BY CreatedDate DESC';

        return Database.query(baseQuery);
    }
}