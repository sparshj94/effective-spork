public class LoanDetails implements LoanCalculations{
    public void calculateEMI(Decimal loanAmount, Double interestRate, Double tenure){
        System.debug('Calculating EMI Wait....');
    }
    public void calculatePayableAmount(Decimal loanAmount, Double interestRate, Double tenure){
        System.debug('Calculating Payable Amount Wait....');
    }
    public void calculateRemainingInstallements(){
        System.debug('Calculating Remaining Installements Wait....');
    }
}