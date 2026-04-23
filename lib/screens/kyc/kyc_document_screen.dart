import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../models/user_model.dart';
import '../../state/app_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/document_upload_box.dart';
import '../../widgets/kyc_step_indicator.dart';
import 'kyc_selfie_screen.dart';

class KycDocumentScreen extends StatefulWidget {
  const KycDocumentScreen({super.key});

  @override
  State<KycDocumentScreen> createState() => _KycDocumentScreenState();
}

class _KycDocumentScreenState extends State<KycDocumentScreen> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _frontImage;
  Uint8List? _backImage;
  Uint8List? _passportImage;

  bool get _canContinue {
    final nationality = context.read<AppState>().kycData.nationality;
    if (nationality == Nationality.malaysian) {
      return _frontImage != null && _backImage != null;
    }
    return _passportImage != null;
  }

  Future<void> _pickImage(bool isFront) async {
    final source = await _showImageSourceDialog();
    if (source == null) return;

    final picked = await _picker.pickImage(source: source, maxWidth: 1200);
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      if (context.read<AppState>().kycData.nationality ==
          Nationality.malaysian) {
        if (isFront) {
          _frontImage = bytes;
        } else {
          _backImage = bytes;
        }
      } else {
        _passportImage = bytes;
      }
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

  void _removeImage(bool isFront) {
    setState(() {
      if (context.read<AppState>().kycData.nationality ==
          Nationality.malaysian) {
        if (isFront) {
          _frontImage = null;
        } else {
          _backImage = null;
        }
      } else {
        _passportImage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final nationality = context.watch<AppState>().kycData.nationality;
    final isMalaysian = nationality == Nationality.malaysian;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
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
              Text(
                isMalaysian ? 'Upload MyKad' : 'Upload Passport',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isMalaysian
                    ? 'Please upload clear photos of your MyKad front and back'
                    : 'Please upload a clear photo of your passport data page',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              if (isMalaysian) ...[
                DocumentUploadBox(
                  label: 'MyKad Front',
                  imageBytes: _frontImage,
                  onTap: () => _pickImage(true),
                  onRemove: _frontImage != null
                      ? () => _removeImage(true)
                      : null,
                ),
                const SizedBox(height: 16),
                DocumentUploadBox(
                  label: 'MyKad Back',
                  imageBytes: _backImage,
                  onTap: () => _pickImage(false),
                  onRemove: _backImage != null
                      ? () => _removeImage(false)
                      : null,
                ),
              ] else ...[
                DocumentUploadBox(
                  label: 'Passport Data Page',
                  imageBytes: _passportImage,
                  onTap: () => _pickImage(true),
                  onRemove: _passportImage != null
                      ? () => _removeImage(true)
                      : null,
                ),
              ],
              const Spacer(),
              CustomButton(
                text: 'Continue',
                onPressed: _canContinue
                    ? () {
                        context.read<AppState>().setKycDocuments(
                          front: _frontImage,
                          back: _backImage,
                          passport: _passportImage,
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KycSelfieScreen(),
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
}
