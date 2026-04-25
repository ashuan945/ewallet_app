import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_responsive.dart';
import '../../state/app_state.dart';
import '../../widgets/balance_card.dart';
import '../../widgets/quick_action_button.dart';
import '../microloan/spark_loan_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Good Morning,',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.name.split(' ').first,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const BalanceCard(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  QuickActionButton(
                    icon: Icons.add_rounded,
                    label: 'Add Money',
                    onTap: () => _showSnack(context, 'Add Money coming soon'),
                  ),
                  QuickActionButton(
                    icon: Icons.send_rounded,
                    label: 'Send',
                    onTap: () => _showSnack(context, 'Send money coming soon'),
                  ),
                  QuickActionButton(
                    icon: Icons.payments_rounded,
                    label: 'Pay',
                    onTap: () => _showSnack(context, 'Pay coming soon'),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(16),
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
                    const Text(
                      'Credit Score',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 6,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 25,
                                        child: Container(
                                          color: const Color(0xFFe53935),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 25,
                                        child: Container(
                                          color: const Color(0xFFff9800),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 25,
                                        child: Container(
                                          color: const Color(0xFF00bfa5),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 25,
                                        child: Container(
                                          color: AppTheme.accentGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              SizedBox(
                                height: 8,
                                child: LayoutBuilder(
                                  builder: (context, constraints) {
                                    final clampedScore = user.creditScore.clamp(
                                      300,
                                      850,
                                    );
                                    final progress = (clampedScore - 300) / 550;
                                    return Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        Positioned(
                                          left:
                                              (constraints.maxWidth *
                                                  progress) -
                                              4,
                                          top: -10,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppTheme.primaryBlue,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black26,
                                                  blurRadius: 2,
                                                  offset: Offset(0, 1),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${user.creditScore}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              _riskLabel(user.creditScore),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: _riskColor(user.creditScore),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your credit score reflects your financial health and payment behavior. A higher score unlocks better loan rates and exclusive rewards.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          context.read<AppState>().setNavIndex(1);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryBlue,
                          side: const BorderSide(color: AppTheme.primaryBlue),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text(
                          'More Details',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Quick Services',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  TextButton(onPressed: () {}, child: const Text('See All')),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: AppResponsive.h(context, 130),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _ServiceCard(
                      title: 'Micro Loan',
                      subtitle: 'Up to RM 3.5K',
                      imageAsset: 'assets/icons/microloan.png',
                      color: AppTheme.accentOrange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SparkLoanScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 12),
                    _ServiceCard(
                      title: 'Biz Cash',
                      subtitle: 'Grow business',
                      icon: Icons.business_center_outlined,
                      color: AppTheme.primaryBlue,
                      onTap: () => _showSnack(context, 'Biz Cash'),
                    ),
                    const SizedBox(width: 12),
                    _ServiceCard(
                      title: 'Pay Bills',
                      subtitle: 'Utilities & more',
                      icon: Icons.receipt_long_outlined,
                      color: const Color(0xFFe53935),
                      onTap: () => _showSnack(context, 'Pay Bills'),
                    ),
                    const SizedBox(width: 12),
                    _ServiceCard(
                      title: 'Prepaid Top-up',
                      subtitle: 'Reload anytime',
                      icon: Icons.phone_android_outlined,
                      color: const Color(0xFF7c4dff),
                      onTap: () => _showSnack(context, 'Prepaid Top-up'),
                    ),
                    const SizedBox(width: 12),
                    _ServiceCard(
                      title: 'Parking',
                      subtitle: 'Pay & go',
                      icon: Icons.local_parking_outlined,
                      color: const Color(0xFF00bfa5),
                      onTap: () => _showSnack(context, 'Parking'),
                    ),
                    const SizedBox(width: 12),
                    _ServiceCard(
                      title: 'Toll / RFID',
                      subtitle: 'Touchless toll',
                      icon: Icons.sensors_outlined,
                      color: const Color(0xFF0047ba),
                      onTap: () => _showSnack(context, 'Toll / RFID'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _riskLabel(int score) {
    if (score >= 697) return 'Good';
    if (score >= 651) return 'Fair';
    if (score >= 529) return 'Low';
    return 'Poor';
  }

  static Color _riskColor(int score) {
    if (score >= 697) return AppTheme.accentGreen;
    if (score >= 651) return const Color(0xFFffc107);
    if (score >= 529) return const Color(0xFFff9800);
    return const Color(0xFFe53935);
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData? icon;
  final String? imageAsset;
  final Color color;
  final VoidCallback onTap;

  const _ServiceCard({
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
        width: AppResponsive.w(context, 150),
        padding: EdgeInsets.all(AppResponsive.w(context, 16)),
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
              width: AppResponsive.w(context, 40),
              height: AppResponsive.w(context, 40),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset!,
                      width: AppResponsive.w(context, 22),
                      height: AppResponsive.w(context, 22),
                    )
                  : Icon(
                      icon!,
                      color: color,
                      size: AppResponsive.w(context, 22),
                    ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 14),
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 12),
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
