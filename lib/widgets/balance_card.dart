import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../core/app_responsive.dart';
import '../state/app_state.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isVisible = appState.isBalanceVisible;
    final balance = appState.user.balance;
    final formatter = NumberFormat.currency(symbol: 'RM ', decimalDigits: 2);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppResponsive.w(context, 20)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF005ce6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppResponsive.r(context, 20)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                'Wallet Balance',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: AppResponsive.sp(context, 14),
                ),
              ),
              GestureDetector(
                onTap: appState.toggleBalanceVisibility,
                child: Icon(
                  isVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                  size: AppResponsive.w(context, 20),
                ),
              ),
            ],
          ),
          SizedBox(height: AppResponsive.h(context, 12)),
          Text(
            isVisible ? formatter.format(balance) : 'RM ****',
            style: TextStyle(
              color: Colors.white,
              fontSize: AppResponsive.sp(context, 32),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppResponsive.h(context, 16)),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppResponsive.w(context, 12),
              vertical: AppResponsive.h(context, 6),
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppResponsive.r(context, 8)),
            ),
            child: Text(
              'Account: **** 8821',
              style: TextStyle(
                color: Colors.white70,
                fontSize: AppResponsive.sp(context, 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
