import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/constants.dart';
import '../../models/user_model.dart';
import '../../services/ekyc_verification_service.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/kyc_step_indicator.dart';
import '../../widgets/styled_text_field.dart';
import 'kyc_status_screen.dart';

class KycReviewScreen extends StatefulWidget {
  final EkycResult? ekycResult;

  const KycReviewScreen({super.key, this.ekycResult});

  @override
  State<KycReviewScreen> createState() => _KycReviewScreenState();
}

class _KycReviewScreenState extends State<KycReviewScreen> {
  String? _occupation;
  String? _businessType;
  bool _isSubmitting = false;

  late TextEditingController _fullNameController;
  late TextEditingController _idNumberController;
  late TextEditingController _countryController;
  late TextEditingController _dobController;
  late TextEditingController _expiryController;

  /// Underlying DateTime values (kept in sync with controllers)
  DateTime? _dob;
  DateTime? _expiry;

  /// Whether the document is a passport (determines which fields to show)
  bool get _isPassport => widget.ekycResult?.isPassport ?? false;

  @override
  void initState() {
    super.initState();
    final kycData = context.read<AppState>().kycData;
    _fullNameController = TextEditingController(text: kycData.fullName ?? '');
    _idNumberController = TextEditingController(text: kycData.idNumber ?? '');

    // Use extracted country from API, fallback to nationality selection
    _countryController = TextEditingController(
      text:
          kycData.extractedCountry ??
          (kycData.nationality == Nationality.malaysian ? 'Malaysia' : 'Other'),
    );

    _dob = kycData.dateOfBirth;
    _expiry = kycData.dateOfExpiry;
    _dobController = TextEditingController(
      text: kycData.dateOfBirth != null ? formatDmy(kycData.dateOfBirth!) : '',
    );
    _expiryController = TextEditingController(
      text: kycData.dateOfExpiry != null ? formatDmy(kycData.dateOfExpiry!) : '',
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _idNumberController.dispose();
    _countryController.dispose();
    _dobController.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<AppState>();

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
              const KycStepIndicator(currentStep: 2),
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
              Text(
                _isPassport
                    ? 'Please verify the details extracted from your passport'
                    : 'Please verify the details extracted from your IC',
                style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ── Common fields ──
                      StyledTextField(
                        label: 'Full Name',
                        controller: _fullNameController,
                        suffix: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: _isPassport ? 'Passport Number' : 'IC Number',
                        controller: _idNumberController,
                        suffix: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Country',
                        controller: _countryController,
                        suffix: const Icon(
                          Icons.edit_outlined,
                          size: 18,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StyledTextField(
                        label: 'Date of Birth',
                        controller: _dobController,
                        readOnly: true,
                        suffix: IconButton(
                          icon: const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: AppTheme.textSecondary,
                          ),
                          onPressed: () => _pickDate(
                            context: context,
                            initialDate: _dob,
                            firstDate: DateTime(1900),
                            lastDate: DateTime.now(),
                            onPicked: (date) {
                              setState(() {
                                _dob = date;
                                _dobController.text = formatDmy(date);
                              });
                            },
                          ),
                        ),
                      ),

                      // ── Passport-only field ──
                      if (_isPassport) ...[
                        const SizedBox(height: 16),
                        StyledTextField(
                          label: 'Date of Expiry',
                          controller: _expiryController,
                          readOnly: true,
                          suffix: IconButton(
                            icon: const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: () => _pickDate(
                              context: context,
                              initialDate: _expiry,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2050),
                              onPicked: (date) {
                                setState(() {
                                  _expiry = date;
                                  _expiryController.text = formatDmy(date);
                                });
                              },
                            ),
                          ),
                        ),
                      ],

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
                        hintText: 'Select occupation',
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
                        hintText: 'Select business type',
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _isSubmitting
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : CustomButton(
                      text: 'Submit',
                      onPressed: () async {
                        // Validate required fields
                        if (_fullNameController.text.trim().isEmpty) {
                          _showError(context, 'Full Name is required');
                          return;
                        }
                        if (_idNumberController.text.trim().isEmpty) {
                          _showError(
                            context,
                            _isPassport
                                ? 'Passport Number is required'
                                : 'IC Number is required',
                          );
                          return;
                        }
                        if (_dob == null) {
                          _showError(context, 'Date of Birth is required');
                          return;
                        }
                        if (_isPassport && _expiry == null) {
                          _showError(context, 'Date of Expiry is required');
                          return;
                        }
                        if (_occupation == null) {
                          _showError(context, 'Please select an Occupation');
                          return;
                        }
                        if (_businessType == null) {
                          _showError(context, 'Please select a Business Type');
                          return;
                        }

                        // Save edited data to AppState
                        context.read<AppState>().updateKycField(
                          fullName: _fullNameController.text.trim(),
                          idNumber: _idNumberController.text.trim(),
                          dateOfBirth: _dob,
                          dateOfExpiry: _isPassport ? _expiry : null,
                          occupation: _occupation,
                          businessType: _businessType,
                        );

                        setState(() {
                          _isSubmitting = true;
                        });

                        try {
                          final appState = context.read<AppState>();
                          final kycData = appState.kycData;
                          final userId = 'user_0001';

                          final isMalaysian =
                              kycData.nationality == Nationality.malaysian;
                          final documentType = isMalaysian ? 'IC' : 'PASSPORT';
                          final documentKey = isMalaysian
                              ? kycData.icFrontKey
                              : kycData.passportKey;

                          if (documentKey == null) {
                            throw Exception('Document key is missing');
                          }
                          if (kycData.selfieKey == null) {
                            throw Exception('Selfie key is missing');
                          }

                          final result =
                              await EkycVerificationService.submitKyc(
                                userId: userId,
                                documentType: documentType,
                                documentKey: documentKey,
                                icBackKey: isMalaysian
                                    ? kycData.icBackKey
                                    : null,
                                selfieKey: kycData.selfieKey!,
                                fullName: _fullNameController.text.trim(),
                                idNumber: _idNumberController.text.trim(),
                                dateOfBirth: _dob!,
                                dateOfExpiry: _isPassport ? _expiry : null,
                                country: _countryController.text.trim(),
                                occupation: _occupation!,
                                businessType: _businessType!,
                                similarity: widget.ekycResult?.similarity,
                                riskScore: widget.ekycResult?.riskScore,
                              );

                          if (!result.isSuccess) {
                            throw Exception(result.message);
                          }

                          // Always set KYC status to pending after submission.
                          // Even if face check passed, document review is still required.
                          appState.updateKycStatus(KycStatus.pending);

                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => KycStatusScreen(
                                  ekycResult: widget.ekycResult,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            _showError(context, 'Submit failed: $e');
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isSubmitting = false;
                            });
                          }
                        }
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show a date picker and return the selected date.
  Future<void> _pickDate({
    required BuildContext context,
    required DateTime? initialDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required ValueChanged<DateTime> onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String? hintText,
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
              hint: hintText != null
                  ? Text(
                      hintText,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textSecondary,
                      ),
                    )
                  : null,
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
