public virtual class GeneralAccount {
	protected String accountHolderName;
    protected String accountType;
    protected Decimal currentBalance;
    public virtual Integer getDailyLimit(){
        return 0;
    }
}