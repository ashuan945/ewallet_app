import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/ekyc_verification_service.dart';
import '../../widgets/custom_button.dart';

class KycStatusScreen extends StatefulWidget {
  final EkycResult? ekycResult;

  const KycStatusScreen({super.key, this.ekycResult});

  @override
  State<KycStatusScreen> createState() => _KycStatusScreenState();
}

class _KycStatusScreenState extends State<KycStatusScreen>
    with SingleTickerProviderStateMixin {
  bool _isProcessing = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
        _controller.stop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Whether the face check passed (similarity threshold met)
  bool get _faceCheckPassed {
    final result = widget.ekycResult;
    if (result == null) return false;
    return result.isVerified || result.needsReview;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_isProcessing,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: _isProcessing
                  ? _buildProcessing()
                  : _buildSubmitted(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProcessing() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RotationTransition(
          turns: _animation,
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.primaryBlue.withOpacity(0.2),
                width: 4,
              ),
            ),
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(
                AppTheme.primaryBlue.withOpacity(0.8),
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'Submitting your documents...',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'This may take a few moments',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  /// Main result view after submission — always shows "under review"
  /// with a face-check status indicator.
  Widget _buildSubmitted() {
    final result = widget.ekycResult;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Main icon: hourglass (under review) ──
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_top,
            size: 56,
            color: Colors.orange,
          ),
        ),
        const SizedBox(height: 32),

        // ── Title ──
        const Text(
          'KYC Submitted',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 16),

        // ── Face check status card ──
        _buildFaceCheckCard(result),

        const SizedBox(height: 16),

        // ── Document review note ──
        Text(
          'Your documents are under review. We will notify you within 24 hours once the verification is complete.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            color: AppTheme.textSecondary.withOpacity(0.9),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 48),
        CustomButton(
          text: 'Close',
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }

  /// Card showing the face-check result as a status row.
  Widget _buildFaceCheckCard(EkycResult? result) {
    final passed = _faceCheckPassed;
    final similarity = result?.similarity ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: passed
            ? AppTheme.accentGreen.withOpacity(0.08)
            : AppTheme.accentRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: passed
              ? AppTheme.accentGreen.withOpacity(0.3)
              : AppTheme.accentRed.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            passed ? Icons.check_circle : Icons.cancel,
            color: passed ? AppTheme.accentGreen : AppTheme.accentRed,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passed ? 'Face Check Passed' : 'Face Check Failed',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: passed ? AppTheme.accentGreen : AppTheme.accentRed,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Similarity: ${similarity.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
