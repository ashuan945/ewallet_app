import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/mock_data.dart';

class ScanToPayScreen extends StatefulWidget {
  const ScanToPayScreen({super.key});

  @override
  State<ScanToPayScreen> createState() => _ScanToPayScreenState();
}

class _ScanToPayScreenState extends State<ScanToPayScreen> {
  bool _flashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBackground,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const Text(
                    'Scan to Pay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        _flashOn ? Icons.flash_on : Icons.flash_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _flashOn = !_flashOn;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            LayoutBuilder(
              builder: (context, constraints) {
                final frameSize = (constraints.maxWidth * 0.65).clamp(
                  200.0,
                  280.0,
                );
                final innerSize = frameSize * 0.75;
                final cornerOffset = frameSize * 0.12;
                final cornerLength = frameSize * 0.09;
                return SizedBox(
                  width: frameSize,
                  height: frameSize,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: frameSize - 20,
                        height: frameSize - 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      _buildCorner(
                        top: cornerOffset,
                        left: cornerOffset,
                        length: cornerLength,
                      ),
                      _buildCorner(
                        top: cornerOffset,
                        right: cornerOffset,
                        length: cornerLength,
                      ),
                      _buildCorner(
                        bottom: cornerOffset,
                        left: cornerOffset,
                        length: cornerLength,
                      ),
                      _buildCorner(
                        bottom: cornerOffset,
                        right: cornerOffset,
                        length: cornerLength,
                      ),
                      Container(
                        width: innerSize,
                        height: innerSize,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.primaryBlue.withOpacity(0.6),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        width: innerSize,
                        height: 2,
                        color: AppTheme.primaryBlue.withOpacity(0.8),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR Code Detected: Merchant ABC'),
                      backgroundColor: AppTheme.accentGreen,
                    ),
                  );
                },
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Simulate Scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Upload from Gallery',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recent Scans',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        itemCount: MockData.recentScans.length,
                        itemBuilder: (context, index) {
                          final scan = MockData.recentScans[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryLight,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.storefront_outlined,
                                    color: AppTheme.primaryBlue,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        scan['merchant'] as String,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        scan['date'] as String,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'RM ${(scan['amount'] as double).toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    double length = 24,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: length,
        height: length,
        decoration: BoxDecoration(
          border: Border(
            top: top != null
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            bottom: bottom != null
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            left: left != null
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
            right: right != null
                ? const BorderSide(color: Colors.white, width: 3)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }
}
