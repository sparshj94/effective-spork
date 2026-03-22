public class BankUtilities {
	static Double globalInterestRate;
    Decimal accountBalance;
    
    public BankUtilities(Double globalInterestRate, Decimal accountBalance){
        BankUtilities.globalInterestRate = globalInterestRate;
        this.accountBalance = accountBalance;
    }
    
    // 2. Have to create inner class or normal class.
}