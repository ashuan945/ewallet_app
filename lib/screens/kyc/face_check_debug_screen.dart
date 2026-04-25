import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/ekyc_verification_service.dart';

class FaceCheckDebugScreen extends StatelessWidget {
  final EkycResult result;

  const FaceCheckDebugScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Check Debug'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusCard(),
            const SizedBox(height: 20),
            _buildDetailsCard(),
            const SizedBox(height: 20),
            _buildRawDataCard(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Continue'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (result.status) {
      case 'VERIFIED':
        statusColor = AppTheme.accentGreen;
        statusText = 'VERIFIED';
        statusIcon = Icons.check_circle;
        break;
      case 'PENDING':
        statusColor = AppTheme.accentOrange;
        statusText = 'PENDING REVIEW';
        statusIcon = Icons.pending;
        break;
      case 'FAILED':
      default:
        statusColor = AppTheme.accentRed;
        statusText = 'FAILED';
        statusIcon = Icons.error;
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Column(
        children: [
          Icon(statusIcon, size: 64, color: statusColor),
          const SizedBox(height: 16),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
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
            'Verification Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            'Similarity Score',
            '${result.similarity.toStringAsFixed(1)}%',
          ),
          const Divider(),
          _buildDetailRow('Risk Score', result.riskScore),
          const Divider(),
          _buildDetailRow('Document Type', result.documentType),
          const Divider(),
          _buildDetailRow('Extracted Name', result.extractedName ?? 'N/A'),
          const Divider(),
          _buildDetailRow('Document Number', result.documentNumber ?? 'N/A'),
          const Divider(),
          _buildDetailRow('Country', result.country ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRawDataCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Raw API Response',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          SelectableText(
            'Status: ${result.status}\n'
            'Similarity: ${result.similarity}%\n'
            'Risk Score: ${result.riskScore}\n'
            'Message: ${result.message}\n'
            'Document Type: ${result.documentType}\n'
            'Name: ${result.extractedName}\n'
            'Document Number: ${result.documentNumber}\n'
            'Country: ${result.country}',
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
