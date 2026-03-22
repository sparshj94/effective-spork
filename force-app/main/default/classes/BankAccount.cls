global class BankAccount {
	global String accountHolderName;
    protected String accountType;
    private Decimal startingBalance;
    
    public BankAccount(String accountHolderName, String accountType, Decimal startingBalance){
        this.accountHolderName = accountHolderName;
        this.accountType = accountType;
        this.startingBalance = startingBalance;
    }
    
    public Decimal getStartingBalance(){
        return startingBalance;
    }
}