public interface LoanCalculations{
    void calculateEMI(Decimal loanAmount, Double interestRate, Double tenure);
    void calculatePayableAmount(Decimal loanAmount, Double interestRate, Double tenure);
}