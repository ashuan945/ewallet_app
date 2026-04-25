import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/mock_data.dart';
import '../models/loan_model.dart';

class AppState extends ChangeNotifier {
  int _currentNavIndex = 0;
  User _user = MockData.currentUser;
  KycData _kycData = const KycData();
  bool _isBalanceVisible = true;
  final List<Loan> _loans = [
    Loan(
      id: 'SL-001',
      amount: 2000,
      purpose: 'Inventory',
      interestRate: 0.01,
      tenureMonths: 6,
      monthlyInstallment: 353.33,
      totalRepayment: 2120.00,
      remainingBalance: 1060.00,
      nextDueDate: DateTime.now().add(const Duration(days: 15)),
      status: LoanStatus.active,
      payments: [
        LoanPayment(
          date: DateTime.now().subtract(const Duration(days: 45)),
          amount: 353.33,
        ),
        LoanPayment(
          date: DateTime.now().subtract(const Duration(days: 15)),
          amount: 353.33,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 75)),
    ),
    Loan(
      id: 'SL-002',
      amount: 1000,
      purpose: 'Equipment',
      interestRate: 0.0125,
      tenureMonths: 3,
      monthlyInstallment: 337.50,
      totalRepayment: 1012.50,
      remainingBalance: 0,
      nextDueDate: DateTime.now(),
      status: LoanStatus.paidOff,
      payments: [
        LoanPayment(
          date: DateTime.now().subtract(const Duration(days: 90)),
          amount: 337.50,
        ),
        LoanPayment(
          date: DateTime.now().subtract(const Duration(days: 60)),
          amount: 337.50,
        ),
        LoanPayment(
          date: DateTime.now().subtract(const Duration(days: 30)),
          amount: 337.50,
        ),
      ],
      createdAt: DateTime.now().subtract(const Duration(days: 100)),
    ),
  ];

  int get currentNavIndex => _currentNavIndex;
  User get user => _user;
  KycData get kycData => _kycData;
  bool get isBalanceVisible => _isBalanceVisible;
  List<Loan> get loans => List.unmodifiable(_loans);

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void setKycNationality(Nationality nationality) {
    _kycData = _kycData.copyWith(nationality: nationality);
    notifyListeners();
  }

  void setKycDocuments({
    Uint8List? front,
    Uint8List? back,
    Uint8List? passport,
  }) {
    _kycData = _kycData.copyWith(
      frontDocument: front,
      backDocument: back,
      passportDocument: passport,
    );
    notifyListeners();
  }

  void setKycSelfie(Uint8List selfie) {
    _kycData = _kycData.copyWith(selfie: selfie);
    notifyListeners();
  }

  void setKycSelfieKey(String selfieKey) {
    _kycData = _kycData.copyWith(selfieKey: selfieKey);
    notifyListeners();
  }

  void updateKycField({
    String? occupation,
    String? businessType,
    String? icFrontKey,
    String? icBackKey,
    String? passportKey,
    String? selfieKey,
    String? fullName,
    String? idNumber,
    DateTime? dateOfBirth,
    DateTime? dateOfExpiry,
    String? extractedCountry,
  }) {
    _kycData = _kycData.copyWith(
      occupation: occupation ?? _kycData.occupation,
      businessType: businessType ?? _kycData.businessType,
      icFrontKey: icFrontKey,
      icBackKey: icBackKey,
      passportKey: passportKey,
      selfieKey: selfieKey,
      fullName: fullName,
      idNumber: idNumber,
      dateOfBirth: dateOfBirth,
      dateOfExpiry: dateOfExpiry,
      extractedCountry: extractedCountry,
    );
    notifyListeners();
  }

  void updateKycStatus(KycStatus status) {
    _user = _user.copyWith(kycStatus: status);
    notifyListeners();
  }

  void resetKyc() {
    _kycData = const KycData();
    notifyListeners();
  }

  void addLoan(Loan loan) {
    _loans.add(loan);
    notifyListeners();
  }

  void makePayment(String loanId, double amount) {
    final index = _loans.indexWhere((l) => l.id == loanId);
    if (index == -1) return;

    final loan = _loans[index];
    final newBalance = loan.remainingBalance - amount;
    final updatedPayments = [
      ...loan.payments,
      LoanPayment(date: DateTime.now(), amount: amount),
    ];

    _loans[index] = loan.copyWith(
      remainingBalance: newBalance > 0 ? newBalance : 0,
      nextDueDate: loan.nextDueDate.add(const Duration(days: 30)),
      status: newBalance <= 0 ? LoanStatus.paidOff : LoanStatus.active,
      payments: updatedPayments,
    );

    _user = _user.copyWith(balance: _user.balance - amount);
    notifyListeners();
  }
}
