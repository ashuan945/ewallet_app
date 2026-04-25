import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_responsive.dart';
import '../../models/loan_model.dart';
import '../../state/app_state.dart';
import 'loan_detail_screen.dart';

class MyLoansTab extends StatelessWidget {
  const MyLoansTab({super.key});

  @override
  Widget build(BuildContext context) {
    final loans = List<Loan>.from(context.watch<AppState>().loans);
    loans.sort((a, b) {
      final priority = {
        LoanStatus.pending: 0,
        LoanStatus.active: 1,
        LoanStatus.paidOff: 2,
      };
      return priority[a.status]!.compareTo(priority[b.status]!);
    });

    if (loans.isEmpty) {
      return _buildEmptyState(context);
    }

    return ListView.separated(
      padding: AppResponsive.padding(context),
      itemCount: loans.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final loan = loans[index];
        return _buildLoanCard(context, loan);
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppResponsive.padding(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                color: AppTheme.primaryBlue,
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Loans Yet',
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 20),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Create your first Spark Loan to start growing your business.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 14),
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanCard(BuildContext context, Loan loan) {
    final statusColor = loan.status == LoanStatus.paidOff
        ? AppTheme.accentGreen
        : loan.status == LoanStatus.active
        ? AppTheme.primaryBlue
        : const Color(0xFFffc107);

    final statusLabel = loan.status == LoanStatus.paidOff
        ? 'Paid Off'
        : loan.status == LoanStatus.active
        ? 'Active'
        : 'Pending';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => LoanDetailScreen(loan: loan)),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
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
                Expanded(
                  child: Text(
                    loan.purpose,
                    style: TextStyle(
                      fontSize: AppResponsive.sp(context, 15),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: AppResponsive.sp(context, 12),
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLoanStat(
                    context,
                    'Amount',
                    'RM ${loan.amount.toStringAsFixed(0)}',
                  ),
                ),
                Expanded(
                  child: _buildLoanStat(
                    context,
                    'Remaining',
                    'RM ${loan.remainingBalance.toStringAsFixed(0)}',
                  ),
                ),
              ],
            ),
            if (loan.status == LoanStatus.active) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Next due: ${DateFormat('dd MMM yyyy').format(loan.nextDueDate)}',
                    style: TextStyle(
                      fontSize: AppResponsive.sp(context, 12),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoanStat(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 12),
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 15),
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
