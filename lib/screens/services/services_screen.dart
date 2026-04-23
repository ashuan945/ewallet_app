import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/mock_data.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Services')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: GridView.builder(
          itemCount: MockData.services.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final service = MockData.services[index];
            return _ServiceGridCard(
              title: service['title'] as String,
              subtitle: service['subtitle'] as String,
              iconName: service['icon'] as String,
              color: Color(service['color'] as int),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${service['title']} coming soon')),
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
  final String iconName;
  final Color color;
  final VoidCallback onTap;

  const _ServiceGridCard({
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.color,
    required this.onTap,
  });

  IconData _getIcon(String name) {
    switch (name) {
      case 'savings':
        return Icons.savings_outlined;
      case 'money':
        return Icons.money_outlined;
      case 'business':
        return Icons.business_center_outlined;
      case 'shield':
        return Icons.shield_outlined;
      case 'trending_up':
        return Icons.trending_up_outlined;
      case 'receipt':
        return Icons.receipt_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_getIcon(iconName), color: color, size: 26),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
