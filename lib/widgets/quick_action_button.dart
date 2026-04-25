import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/app_responsive.dart';

class QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const QuickActionButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppResponsive.w(context, 56),
            height: AppResponsive.w(context, 56),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.1)),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: AppResponsive.w(context, 26),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 13),
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
