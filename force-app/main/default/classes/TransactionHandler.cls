public abstract class TransactionHandler {
    public abstract void processTransaction(String type, Decimal amount);
    
    public void validateTransaction(Decimal amount){
        if(amount<0){
            System.debug('Negative Amount, so Invalid Transaction');
        } else{
            
        }
        System.debug('Positive Amount, Valid Transaction');
    }
}