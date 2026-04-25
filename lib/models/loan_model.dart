enum LoanStatus { active, paidOff, pending }

class LoanPayment {
  final DateTime date;
  final double amount;

  const LoanPayment({required this.date, required this.amount});
}

class Loan {
  final String id;
  final double amount;
  final String purpose;
  final double interestRate;
  final int tenureMonths;
  final double monthlyInstallment;
  final double totalRepayment;
  double remainingBalance;
  DateTime nextDueDate;
  LoanStatus status;
  final List<LoanPayment> payments;
  final DateTime createdAt;

  Loan({
    required this.id,
    required this.amount,
    required this.purpose,
    required this.interestRate,
    required this.tenureMonths,
    required this.monthlyInstallment,
    required this.totalRepayment,
    required this.remainingBalance,
    required this.nextDueDate,
    this.status = LoanStatus.active,
    this.payments = const [],
    required this.createdAt,
  });

  double get progress => totalRepayment > 0
      ? (totalRepayment - remainingBalance) / totalRepayment
      : 0.0;

  Loan copyWith({
    double? remainingBalance,
    DateTime? nextDueDate,
    LoanStatus? status,
    List<LoanPayment>? payments,
  }) {
    return Loan(
      id: id,
      amount: amount,
      purpose: purpose,
      interestRate: interestRate,
      tenureMonths: tenureMonths,
      monthlyInstallment: monthlyInstallment,
      totalRepayment: totalRepayment,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      status: status ?? this.status,
      payments: payments ?? this.payments,
      createdAt: createdAt,
    );
  }
}
