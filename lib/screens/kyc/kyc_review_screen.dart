import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/kyc_step_indicator.dart';
import '../../widgets/styled_text_field.dart';
import 'kyc_status_screen.dart';

class KycReviewScreen extends StatefulWidget {
  const KycReviewScreen({super.key});

  @override
  State<KycReviewScreen> createState() => _KycReviewScreenState();
}

class _KycReviewScreenState extends State<KycReviewScreen> {
  String? _occupation;
  String? _businessType;
  bool _confirmed = false;

  @override
  void initState() {
    super.initState();
    final kycData = context.read<AppState>().kycData;
    _occupation = kycData.occupation ?? AppConstants.occupations.first;
    _businessType = kycData.businessType ?? AppConstants.businessTypes.first;
  }

  @override
  Widget build(BuildContext context) {
    final kycData = context.watch<AppState>().kycData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const KycStepIndicator(currentStep: 3),
              const SizedBox(height: 28),
              const Text(
                'Review Your Information',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Please verify the details extracted from your document',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      StyledTextField(
                        label: 'Full Name',
                        initialValue: kycData.fullName,
                        readOnly: true,
                        suffix: const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'ID Number',
                        initialValue: kycData.idNumber,
                        readOnly: true,
                        suffix: const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Date of Birth',
                        initialValue: kycData.dateOfBirth,
                        readOnly: true,
                        suffix: const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Address',
                        initialValue: kycData.address,
                        readOnly: true,
                        maxLines: 2,
                        suffix: const Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Occupation',
                        value: _occupation,
                        items: AppConstants.occupations,
                        onChanged: (val) {
                          setState(() {
                            _occupation = val;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        label: 'Business Type',
                        value: _businessType,
                        items: AppConstants.businessTypes,
                        onChanged: (val) {
                          setState(() {
                            _businessType = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: _confirmed,
                            onChanged: (val) {
                              setState(() {
                                _confirmed = val ?? false;
                              });
                            },
                            activeColor: AppTheme.primaryBlue,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'I confirm that all information provided is accurate and true to the best of my knowledge.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary.withOpacity(
                                    0.9,
                                  ),
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Submit',
                onPressed: _confirmed
                    ? () {
                        context.read<AppState>().updateKycField(
                          occupation: _occupation,
                          businessType: _businessType,
                        );
                        context.read<AppState>().submitKyc();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KycStatusScreen(),
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

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(
                Icons.arrow_drop_down,
                color: AppTheme.textSecondary,
              ),
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
