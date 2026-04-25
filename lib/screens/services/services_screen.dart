import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../core/app_responsive.dart';
import '../microloan/spark_loan_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = [
      (
        title: 'Micro Loan',
        subtitle: 'Up to RM 3.5K',
        imageAsset: 'assets/icons/microloan.png',
        icon: null,
        color: AppTheme.accentOrange,
      ),
      (
        title: 'Biz Cash',
        subtitle: 'Grow business',
        imageAsset: null,
        icon: Icons.business_center_outlined,
        color: AppTheme.primaryBlue,
      ),
      (
        title: 'Pay Bills',
        subtitle: 'Utilities & more',
        imageAsset: null,
        icon: Icons.receipt_long_outlined,
        color: const Color(0xFFe53935),
      ),
      (
        title: 'Prepaid Top-up',
        subtitle: 'Reload anytime',
        imageAsset: null,
        icon: Icons.phone_android_outlined,
        color: const Color(0xFF7c4dff),
      ),
      (
        title: 'Parking',
        subtitle: 'Pay & go',
        imageAsset: null,
        icon: Icons.local_parking_outlined,
        color: const Color(0xFF00bfa5),
      ),
      (
        title: 'Toll / RFID',
        subtitle: 'Touchless toll',
        imageAsset: null,
        icon: Icons.sensors_outlined,
        color: const Color(0xFF0047ba),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = AppResponsive.gridColumns(context);
            return GridView.builder(
              itemCount: services.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: AppResponsive.w(context, 14),
                mainAxisSpacing: AppResponsive.w(context, 14),
                childAspectRatio: constraints.maxWidth / (columns * 190),
              ),
              itemBuilder: (context, index) {
                final service = services[index];
                return _ServiceGridCard(
                  title: service.title,
                  subtitle: service.subtitle,
                  icon: service.icon,
                  imageAsset: service.imageAsset,
                  color: service.color,
                  onTap: () {
                    if (service.title == 'Micro Loan') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SparkLoanScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${service.title} coming soon')),
                      );
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ServiceGridCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imageAsset;
  final Color color;
  final VoidCallback onTap;

  const _ServiceGridCard({
    required this.title,
    required this.subtitle,
    this.icon,
    this.imageAsset,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppResponsive.w(context, 18)),
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
            Container(
              width: AppResponsive.w(context, 56),
              height: AppResponsive.w(context, 56),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset!,
                      width: AppResponsive.w(context, 32),
                      height: AppResponsive.w(context, 32),
                    )
                  : Icon(
                      icon!,
                      color: color,
                      size: AppResponsive.w(context, 32),
                    ),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 16),
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 13),
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
