public class BankAccountUtils {
    public static void accountNumberFormatter(String accountNumber){
        String newNum='';
        Integer count = 0;
        for(Integer i = 0; i<accountNumber.length(); i++){
            if(count==4){
                newNum+='-';
                count=0;
            }
            newNum+=accountNumber.substring(i,i+1);
            count++;
        }
        System.debug(newNum);
    }
	
    public void convertRecordIdToBlob(String recordId){
        Blob b = Blob.valueOf(recordId);
        System.debug(b);
    }
    
    public void decodeBlob(Blob data){
        System.debug(data);
    }
    
    public void validateAccountId(String sfId){
        System.debug(sfId.length());
    }
    
    
}