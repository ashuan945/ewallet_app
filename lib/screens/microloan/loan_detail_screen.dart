import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_responsive.dart';
import '../../models/loan_model.dart';
import '../../state/app_state.dart';

class LoanDetailScreen extends StatelessWidget {
  final Loan loan;

  const LoanDetailScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Details')),
      body: SingleChildScrollView(
        padding: AppResponsive.padding(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLoanSummaryCard(context),
            const SizedBox(height: 20),
            if (loan.status == LoanStatus.active)
              _buildNextPaymentCard(context),
            if (loan.status == LoanStatus.active) const SizedBox(height: 20),
            if (loan.status == LoanStatus.pending) _buildPendingCard(context),
            if (loan.status == LoanStatus.pending) const SizedBox(height: 20),
            _buildPaymentHistory(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanSummaryCard(BuildContext context) {
    final progress = loan.progress.clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Loan Summary',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 16),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              _buildStatusBadge(context),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            'Original Amount',
            'RM ${loan.amount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            context,
            'Interest Rate',
            '${(loan.interestRate * 100).toStringAsFixed(2)}% / month',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(context, 'Tenure', '${loan.tenureMonths} months'),
          const SizedBox(height: 10),
          _buildSummaryRow(
            context,
            'Total Repayment',
            'RM ${loan.totalRepayment.toStringAsFixed(2)}',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            context,
            'Remaining Balance',
            'RM ${loan.remainingBalance.toStringAsFixed(2)}',
            isHighlight: true,
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppTheme.primaryLight,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% paid',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 12),
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final label = loan.status == LoanStatus.paidOff
        ? 'Paid Off'
        : loan.status == LoanStatus.active
        ? 'Active'
        : 'Pending';
    final color = loan.status == LoanStatus.paidOff
        ? AppTheme.accentGreen
        : loan.status == LoanStatus.active
        ? AppTheme.primaryBlue
        : const Color(0xFFffc107);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppResponsive.sp(context, 12),
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildNextPaymentCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF3366CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Next Payment',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 14),
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'RM ${loan.monthlyInstallment.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 24),
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Due by ${DateFormat('dd MMM yyyy').format(loan.nextDueDate)}',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 13),
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showPaymentBottomSheet(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Pay Now',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFffc107).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.hourglass_top, color: Color(0xFFffc107), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Awaiting Approval',
                  style: TextStyle(
                    fontSize: AppResponsive.sp(context, 15),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your loan application is under review. You will be notified once it is approved.',
                  style: TextStyle(
                    fontSize: AppResponsive.sp(context, 13),
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment History',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 16),
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          if (loan.payments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'No payments made yet.',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 14),
                  color: AppTheme.textSecondary,
                ),
              ),
            )
          else
            ...loan.payments.map((payment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppTheme.accentGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: AppTheme.accentGreen,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('dd MMM yyyy').format(payment.date),
                          style: TextStyle(
                            fontSize: AppResponsive.sp(context, 14),
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'RM ${payment.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: AppResponsive.sp(context, 14),
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 14),
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 14),
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight ? AppTheme.primaryBlue : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _showPaymentBottomSheet(BuildContext context) {
    final userBalance = context.read<AppState>().user.balance;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Make Payment',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 20),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Wallet Balance: RM ${userBalance.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 14),
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Amount to Pay',
                      style: TextStyle(
                        fontSize: AppResponsive.sp(context, 13),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'RM ${loan.monthlyInstallment.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: AppResponsive.sp(context, 28),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: userBalance >= loan.monthlyInstallment
                      ? () {
                          context.read<AppState>().makePayment(
                            loan.id,
                            loan.monthlyInstallment,
                          );
                          Navigator.pop(sheetContext);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment successful!'),
                              backgroundColor: AppTheme.accentGreen,
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    userBalance >= loan.monthlyInstallment
                        ? 'Confirm Payment'
                        : 'Insufficient Balance',
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}
