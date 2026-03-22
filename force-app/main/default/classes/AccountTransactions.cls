public class AccountTransactions extends TransactionHandler {
    public override void processTransaction(String type, Decimal amount){
        System.debug('Transaction processed....');
    }
}