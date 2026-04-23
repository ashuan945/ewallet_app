import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/user_model.dart';
import '../../state/app_state.dart';
import '../kyc/kyc_intro_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildProfileHeader(user),
            const SizedBox(height: 24),
            _buildKycCard(context, user.kycStatus),
            const SizedBox(height: 24),
            _buildSettingsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 3,
              ),
            ),
            child: const Center(
              child: Icon(Icons.person, size: 40, color: AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            user.phone,
            style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildKycCard(BuildContext context, KycStatus status) {
    final isVerified = status == KycStatus.verified;
    final isPending = status == KycStatus.pending;

    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (status) {
      case KycStatus.verified:
        statusColor = AppTheme.accentGreen;
        statusText = 'Verified';
        statusIcon = Icons.verified;
        break;
      case KycStatus.pending:
        statusColor = AppTheme.accentOrange;
        statusText = 'Pending Review';
        statusIcon = Icons.pending;
        break;
      case KycStatus.notVerified:
        statusColor = AppTheme.accentRed;
        statusText = 'Not Verified';
        statusIcon = Icons.error_outline;
        break;
    }

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
          const Text(
            'KYC Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 22),
              const SizedBox(width: 10),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (!isVerified && !isPending) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const KycIntroScreen()),
                  );
                },
                icon: const Icon(Icons.verified_user_outlined),
                label: const Text('Account Verification'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context) {
    final items = [
      _SettingsItem(
        icon: Icons.person_outline,
        title: 'Personal Information',
        onTap: () {},
      ),
      _SettingsItem(icon: Icons.lock_outline, title: 'Security', onTap: () {}),
      _SettingsItem(
        icon: Icons.notifications_outlined,
        title: 'Notifications',
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.help_outline,
        title: 'Help Center',
        onTap: () {},
      ),
      _SettingsItem(
        icon: Icons.logout,
        title: 'Logout',
        color: AppTheme.accentRed,
        onTap: () {},
      ),
    ];

    return Container(
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
        children: items.asMap().entries.map((entry) {
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                leading: Icon(
                  item.icon,
                  color: item.color ?? AppTheme.primaryBlue,
                ),
                title: Text(
                  item.title,
                  style: TextStyle(
                    color: item.color ?? AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                onTap: item.onTap,
              ),
              if (entry.key < items.length - 1)
                const Divider(height: 1, indent: 56),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });
}
