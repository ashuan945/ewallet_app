import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/user_model.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/kyc_step_indicator.dart';
import 'kyc_document_screen.dart';

class KycIntroScreen extends StatefulWidget {
  const KycIntroScreen({super.key});

  @override
  State<KycIntroScreen> createState() => _KycIntroScreenState();
}

class _KycIntroScreenState extends State<KycIntroScreen> {
  Nationality? _selectedNationality;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Your Account'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KycStepIndicator(currentStep: -1),
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user,
                    size: 36,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Account Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Complete verification to unlock all features',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                ),
              ),
              const SizedBox(height: 28),
              _buildInfoItem(
                Icons.security,
                'Secure your account',
                'Protect your funds and personal information',
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                Icons.account_balance_wallet,
                'Higher transaction limits',
                'Send and receive larger amounts seamlessly',
              ),
              const SizedBox(height: 16),
              _buildInfoItem(
                Icons.speed,
                'Faster processing',
                'Enjoy instant approvals on services',
              ),
              const SizedBox(height: 32),
              const Text(
                'Select Nationality',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _NationalityCard(
                      label: 'Malaysian',
                      icon: Icons.flag,
                      isSelected: _selectedNationality == Nationality.malaysian,
                      onTap: () {
                        setState(() {
                          _selectedNationality = Nationality.malaysian;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _NationalityCard(
                      label: 'Non-Malaysian',
                      icon: Icons.public,
                      isSelected:
                          _selectedNationality == Nationality.nonMalaysian,
                      onTap: () {
                        setState(() {
                          _selectedNationality = Nationality.nonMalaysian;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Verify Account',
                onPressed: _selectedNationality != null
                    ? () {
                        context.read<AppState>().setKycNationality(
                          _selectedNationality!,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KycDocumentScreen(),
                          ),
                        );
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppTheme.primaryBlue, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
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
      ],
    );
  }
}

class _NationalityCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NationalityCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryBlue : AppTheme.borderLight,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryBlue.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.textSecondary,
              size: 28,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
