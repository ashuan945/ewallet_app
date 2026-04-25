import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/aws_upload_service.dart';
import '../../services/ekyc_verification_service.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/kyc_step_indicator.dart';
import '../../widgets/selfie_frame.dart';
import 'kyc_review_screen.dart';

class KycSelfieScreen extends StatefulWidget {
  const KycSelfieScreen({super.key});

  @override
  State<KycSelfieScreen> createState() => _KycSelfieScreenState();
}

class _KycSelfieScreenState extends State<KycSelfieScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _selfieImage;
  bool _showPreview = false;
  bool _isUploading = false;

  Future<void> _takeSelfie() async {
    final picked = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _selfieImage = bytes;
      _showPreview = true;
    });
  }

  void _retake() {
    setState(() {
      _selfieImage = null;
      _showPreview = false;
    });
  }

  /// Show dialog when face check similarity is below 80%.
  /// User must retake the selfie — they cannot proceed.
  void _showFaceCheckFailedDialog(EkycResult result) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.cancel, color: AppTheme.accentRed, size: 28),
            const SizedBox(width: 8),
            const Text('Face Check Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your selfie did not match the document photo.',
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Similarity: ${result.similarity.toStringAsFixed(1)}%',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.accentRed,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please ensure good lighting and remove any accessories (glasses, hat) before trying again.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              _retake(); // reset selfie
            },
            child: const Text('Retake Selfie'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Selfie'),
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
              const KycStepIndicator(currentStep: 1),
              const SizedBox(height: 28),
              const Text(
                'Selfie Verification',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Take a clear selfie to verify your identity',
                style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 24),
              SelfieFrame(
                capturedImage: _selfieImage,
                showPreview: _showPreview,
              ),
              const Spacer(),
              if (!_showPreview) ...[
                CustomButton(
                  text: 'Take Selfie',
                  icon: Icons.camera_alt,
                  onPressed: _takeSelfie,
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Retake',
                        isOutlined: true,
                        onPressed: _isUploading ? null : _retake,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _isUploading
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            )
                          : CustomButton(
                              text: 'Confirm',
                              onPressed: () async {
                                if (_selfieImage == null) return;

                                // Show loading
                                setState(() {
                                  _isUploading = true;
                                });

                                try {
                                  // Fixed userId for testing (same as document screen)
                                  final userId = 'user_0001';

                                  final selfieKey =
                                      await AwsUploadService.uploadFile(
                                        fileType: 'selfie',
                                        userId: userId,
                                        fileBytes: _selfieImage!,
                                        contentType: 'image/jpeg',
                                      );

                                  setState(() {
                                    _isUploading =
                                        true; // Keep loading for verification
                                  });

                                  // Save selfie key to state (use actual key from upload)
                                  context.read<AppState>().setKycSelfieKey(
                                    selfieKey,
                                  );

                                  // Save to local state
                                  context.read<AppState>().setKycSelfie(
                                    _selfieImage!,
                                  );

                                  // Call verification API to extract data
                                  final kycData = context
                                      .read<AppState>()
                                      .kycData;
                                  final isMalaysian =
                                      kycData.nationality ==
                                      Nationality.malaysian;

                                  final documentType = isMalaysian
                                      ? 'IC'
                                      : 'PASSPORT';
                                  final documentKey = isMalaysian
                                      ? kycData.icFrontKey
                                      : kycData.passportKey;

                                  if (documentKey == null) {
                                    throw Exception('Document not uploaded');
                                  }

                                  // Call verification API
                                  final result =
                                      await EkycVerificationService.verifyIdentity(
                                        userId: userId,
                                        documentType: documentType,
                                        documentKey: documentKey,
                                        selfieKey: selfieKey,
                                      );

                                  // Store extracted data in AppState
                                  // NOTE: We do NOT update kycStatus here because
                                  // verify-ekyc no longer persists to DynamoDB.
                                  // Status will be updated after submit-kyc succeeds.
                                  context.read<AppState>().updateKycField(
                                    fullName: result.extractedName,
                                    idNumber: result.documentNumber,
                                    dateOfBirth: result.dateOfBirth,
                                    dateOfExpiry: result.dateOfExpiry,
                                    extractedCountry: result.country,
                                  );

                                  setState(() {
                                    _isUploading = false;
                                  });

                                  if (!mounted) return;

                                  // ── Face check gating ──
                                  // < 80%: Failed — ask user to redo
                                  // >= 80%: Proceed to review screen
                                  if (result.similarity < 80) {
                                    _showFaceCheckFailedDialog(result);
                                    return;
                                  }

                                  // Go to review screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          KycReviewScreen(ekycResult: result),
                                    ),
                                  );
                                } catch (e) {
                                  setState(() {
                                    _isUploading = false;
                                  });

                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '❌ Selfie upload failed: $e',
                                        ),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
