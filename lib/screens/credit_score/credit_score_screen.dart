import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_responsive.dart';
import '../../models/ai_credit_insight.dart';
import '../../state/app_state.dart';
import '../../services/credit_insight_service.dart';
import '../../widgets/credit_score_ring.dart';
import '../microloan/spark_loan_screen.dart';

class CreditScoreScreen extends StatefulWidget {
  const CreditScoreScreen({super.key});

  @override
  State<CreditScoreScreen> createState() => _CreditScoreScreenState();
}

class _CreditScoreScreenState extends State<CreditScoreScreen> {
  AiCreditInsight? _insight;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchInsight();
  }

  Future<void> _fetchInsight() async {
    try {
      final insight = await CreditInsightService.fetchInsight(userId: 'U001');
      if (mounted) {
        context.read<AppState>().setAiCreditInsight(insight);
        setState(() {
          _insight = insight;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appScore = context.watch<AppState>().user.creditScore;
    final apiScore = _insight?.creditScore.round() ?? appScore;
    final displayScore = _insight != null ? apiScore : appScore;

    return Scaffold(
      appBar: AppBar(title: const Text('Credit Score')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CreditScoreRing(score: displayScore),
            const SizedBox(height: 32),
            if (_error != null)
              _buildErrorCard(_error!)
            else ...[
              _buildAiAnalysisSection(context, displayScore),
              const SizedBox(height: 24),
              _buildAiSuggestionsSection(context, displayScore),
            ],
            const SizedBox(height: 24),
            _buildLoanOfferSection(context, displayScore),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFffebee),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFef5350).withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFef5350)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unable to load AI insight: $message',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFFc62828),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiAnalysisSection(BuildContext context, int score) {
    if (_isLoading) {
      return _buildAiLoadingCard('AI is analyzing your credit profile...');
    }

    final explanations = _insight?.scoreExplanation ?? [];
    final drivers = _insight?.futureScoreDrivers ?? [];
    final allInsights = [...explanations, ...drivers];

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
          const SizedBox(height: 12),
          if (allInsights.isEmpty)
            const Text(
              'No detailed insights available.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...allInsights.map((text) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildAnalysisItem(context, text: text),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildAiSuggestionsSection(BuildContext context, int score) {
    if (_isLoading) {
      return _buildAiLoadingCard('AI is generating personalized policies...');
    }

    final plans = _insight?.improvementPlan ?? [];

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
          if (plans.isEmpty)
            const Text(
              'No improvement suggestions available.',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            )
          else
            ...plans.asMap().entries.map((entry) {
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
                            'Action ${entry.key + 1}',
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
                            color: AppTheme.primaryBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'AI Suggested',
                            style: TextStyle(
                              fontSize: AppResponsive.sp(context, 11),
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      entry.value,
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

  Widget _buildAnalysisItem(BuildContext context, {required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.info_outline,
            color: AppTheme.primaryBlue,
            size: 14,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 13),
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanOfferSection(BuildContext context, int score) {
    final isEligible = true;
    final String loanAmount;
    final String message;

    if (score >= 697) {
      loanAmount = 'RM 3,500';
      message = 'Your credit score qualifies you for a Spark Loan up to';
    } else if (score >= 651) {
      loanAmount = 'RM 2,500';
      message = 'Your credit score qualifies you for a Spark Loan up to';
    } else if (score >= 529) {
      loanAmount = 'RM 1,000';
      message = 'Your credit score qualifies you for a Spark Loan up to';
    } else {
      loanAmount = 'RM 500';
      message = 'Your credit score qualifies you for a Spark Loan up to';
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
                  'Spark Loan',
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
            message,
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SparkLoanScreen()),
                );
              },
              icon: const Icon(
                Icons.arrow_forward,
                color: AppTheme.primaryBlue,
                size: 18,
              ),
              label: const Text(
                'Apply for Spark Loan',
                style: TextStyle(
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
}
