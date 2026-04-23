import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
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

  Future<void> _takeSelfie() async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, maxWidth: 800);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _selfieImage = bytes;
      _showPreview = true;
    });
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Source'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library,
                color: AppTheme.primaryBlue,
              ),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  void _retake() {
    setState(() {
      _selfieImage = null;
      _showPreview = false;
    });
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
              const KycStepIndicator(currentStep: 2),
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
                        onPressed: _retake,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'Confirm',
                        onPressed: () {
                          if (_selfieImage != null) {
                            context.read<AppState>().setKycSelfie(
                              _selfieImage!,
                            );
                          }
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const KycReviewScreen(),
                            ),
                          );
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
