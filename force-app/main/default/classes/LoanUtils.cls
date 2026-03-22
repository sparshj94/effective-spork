public class LoanUtils {
	String name = 'Sparsh';
    Decimal loanAmount = 1000000;
    Date startDate = Date.newInstance(2026,01,31);
    Double tenureInYears = 10;
    public final Double annualInterestRate = 7.2;
    public void calculateInterestAmt(){
        Decimal interestAmount = (loanAmount*annualInterestRate*tenureInYears)/100;
        Decimal amount = interestAmount.setScale(2);
        System.debug('Interest Amount ' + amount);
    }
    
    public void calculateEndDate(){
        Integer days = (Integer)tenureInYears*365;
        Date endDate = startDate.addDays(days);
        System.debug('End Date '+endDate);
    }
    
    public void calculateEMI(){
        // P*R*(1+R)N/((1+R)N-1)
        Decimal monthlyInterestRate = annualInterestRate/12/100;
        Double tenureInMonths = tenureInYears*12;
        
        Double powVal = Math.pow((Double)(1+monthlyInterestRate),tenureInMonths);
        Decimal emi = loanAmount * monthlyInterestRate * 
             (Decimal)powVal/((Decimal)powVal -1);
        System.debug('Monthly Emi '+emi.setScale(2));
    }
    
}