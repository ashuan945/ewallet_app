import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_responsive.dart';
import '../../models/mock_data.dart';
import '../../state/app_state.dart';
import '../../widgets/credit_score_ring.dart';
import '../microloan/spark_loan_screen.dart';

class CreditScoreScreen extends StatefulWidget {
  const CreditScoreScreen({super.key});

  @override
  State<CreditScoreScreen> createState() => _CreditScoreScreenState();
}

class _CreditScoreScreenState extends State<CreditScoreScreen> {
  bool _isLoadingAi = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _isLoadingAi = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final score = context.watch<AppState>().user.creditScore;

    return Scaffold(
      appBar: AppBar(title: const Text('Credit Score')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CreditScoreRing(score: score),
            const SizedBox(height: 32),
            _buildAiAnalysisSection(context, score),
            const SizedBox(height: 24),
            _buildAiSuggestionsSection(context, score),
            const SizedBox(height: 24),
            _buildLoanOfferSection(context, score),
          ],
        ),
      ),
    );
  }

  Widget _buildAiAnalysisSection(BuildContext context, int score) {
    if (_isLoadingAi) {
      return _buildAiLoadingCard('AI is analyzing your credit profile...');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFf8f9ff), Color(0xFFeef1ff)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryBlue.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_graph,
                  color: AppTheme.primaryBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Credit Insight',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 15),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Your score is ${score >= 700 ? 'strong' : score >= 529 ? 'improving' : 'below target'}',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 14),
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          _buildInsightItem(
            context,
            isPositive: true,
            title: 'On-Time Payments',
            detail: '100% payment record over 6 months contributes +45 points.',
          ),
          const SizedBox(height: 10),
          _buildInsightItem(
            context,
            isPositive: false,
            title: 'Hard Inquiry',
            detail: 'Spark Loan eligibility check caused a minor -4 point dip.',
          ),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionsSection(BuildContext context, int score) {
    if (_isLoadingAi) {
      return _buildAiLoadingCard('AI is generating personalized policies...');
    }

    final suggestions = [
      {
        'policy': 'Payment Streak',
        'action': 'Pay all bills on time. A 12-month streak unlocks +25 points.',
        'priority': 'High',
        'color': 0xFF00c853,
      },
      {
        'policy': 'Utilization Cap',
        'action': 'Keep credit usage below 30%. Currently at 18.3%.',
        'priority': 'High',
        'color': 0xFF00c853,
      },
      {
        'policy': 'Inquiry Cooldown',
        'action': 'Wait 6 months between loan applications.',
        'priority': 'Medium',
        'color': 0xFFff9800,
      },
    ];

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.policy_outlined,
                  color: AppTheme.accentOrange,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'AI Improvement Policies',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 15),
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...suggestions.map((s) {
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFf8f9fa),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFe0e0e0).withOpacity(0.6),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s['policy'] as String,
                          style: TextStyle(
                            fontSize: AppResponsive.sp(context, 14),
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Color(s['color'] as int).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          s['priority'] as String,
                          style: TextStyle(
                            fontSize: AppResponsive.sp(context, 11),
                            fontWeight: FontWeight.w600,
                            color: Color(s['color'] as int),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s['action'] as String,
                    style: TextStyle(
                      fontSize: AppResponsive.sp(context, 13),
                      color: AppTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAiLoadingCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
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
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightItem(
    BuildContext context, {
    required bool isPositive,
    required String title,
    required String detail,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isPositive
                ? const Color(0xFF00c853).withOpacity(0.1)
                : const Color(0xFFff5252).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isPositive ? Icons.trending_up : Icons.trending_down,
            color: isPositive ? const Color(0xFF00c853) : const Color(0xFFff5252),
            size: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 13),
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                detail,
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 12),
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLoanOfferSection(BuildContext context, int score) {
    final isEligible = score >= 529;
    final String loanAmount;
    final String message;

    if (score >= 697) {
      loanAmount = 'RM 3,500';
      message = 'Your credit score qualifies you for a Micro Loan up to';
    } else if (score >= 651) {
      loanAmount = 'RM 2,500';
      message = 'Your credit score qualifies you for a Micro Loan up to';
    } else if (score >= 529) {
      loanAmount = 'RM 1,000';
      message = 'Your credit score qualifies you for a Micro Loan up to';
    } else {
      loanAmount = '';
      message = 'Improve your credit score to unlock Micro Loan offers.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue,
            AppTheme.primaryBlue.withOpacity(0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.money_outlined,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Micro Loan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isEligible)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Eligible',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isEligible ? message : message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          if (isEligible) ...[
            const SizedBox(height: 6),
            Text(
              loanAmount,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                if (isEligible) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SparkLoanScreen()),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Scroll down to see improvement tips'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              icon: Icon(
                isEligible ? Icons.arrow_forward : Icons.trending_up,
                color: AppTheme.primaryBlue,
                size: 18,
              ),
              label: Text(
                isEligible ? 'Apply for Micro Loan' : 'View Improvement Tips',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsSection() {
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
            'Score Factors',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          ...MockData.scoreFactors.map((factor) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Color(factor['color'] as int),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      factor['label'] as String,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Color(factor['color'] as int).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      factor['value'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(factor['color'] as int),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTipsSection() {
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
          const Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentOrange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Improvement Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...MockData.improvementTips.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
