import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_theme.dart';
import '../../core/app_responsive.dart';
import '../../models/loan_model.dart';
import '../../state/app_state.dart';
import 'my_loans_tab.dart';

class SparkLoanScreen extends StatefulWidget {
  const SparkLoanScreen({super.key});

  @override
  State<SparkLoanScreen> createState() => _SparkLoanScreenState();
}

class _SparkLoanScreenState extends State<SparkLoanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _selectedAmount = 500;
  String? _businessPurpose;
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  final List<String> _businessPurposes = [
    'Inventory',
    'Equipment',
    'Marketing',
    'Working Capital',
    'Others',
  ];

  static const double _minLoan = 500;

  static String _riskLabel(int score) {
    if (score >= 697) return 'Good';
    if (score >= 651) return 'Fair';
    if (score >= 529) return 'Low';
    return 'Poor';
  }

  static Color _riskColor(int score) {
    if (score >= 697) return AppTheme.accentGreen;
    if (score >= 651) return const Color(0xFFffc107);
    if (score >= 529) return const Color(0xFFff9800);
    return AppTheme.accentRed;
  }

  static double _maxLoan(int score) {
    if (score >= 697) return 3500;
    if (score >= 651) return 2500;
    if (score >= 529) return 1000;
    return 500;
  }

  static double _monthlyRate(int score) {
    if (score >= 697) return 0.01;
    if (score >= 651) return 0.0125;
    if (score >= 529) return 0.015;
    return 0.02;
  }

  static int _recommendedTenure(double amount) {
    if (amount <= 1000) return 3;
    if (amount <= 2000) return 6;
    return 9;
  }

  double _monthlyInstallment(int score, double amount) {
    final rate = _monthlyRate(score);
    final tenure = _recommendedTenure(amount);
    final totalInterest = amount * rate * tenure;
    return (amount + totalInterest) / tenure;
  }

  double _totalRepayment(int score, double amount) {
    final rate = _monthlyRate(score);
    final tenure = _recommendedTenure(amount);
    final totalInterest = amount * rate * tenure;
    return amount + totalInterest;
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final apiScore = appState.aiCreditInsight?.creditScore.round();
    final score = apiScore ?? appState.user.creditScore;
    final maxLoan = _maxLoan(score);

    if (_selectedAmount > maxLoan) {
      _selectedAmount = maxLoan;
    }

    final monthlyRate = _monthlyRate(score);
    final tenure = _recommendedTenure(_selectedAmount);
    final monthlyPayment = _monthlyInstallment(score, _selectedAmount);
    final totalRepayment = _totalRepayment(score, _selectedAmount);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spark Loan'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryBlue,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: 'Create New Loan'),
            Tab(text: 'My Loans'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          SingleChildScrollView(
            padding: AppResponsive.padding(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildCreditScoreCard(context, score),
                const SizedBox(height: 20),
                _buildAiRecommendationCard(
                  context,
                  score,
                  maxLoan,
                  monthlyRate,
                ),
                const SizedBox(height: 24),
                _buildBusinessPurposeSelector(context),
                const SizedBox(height: 24),
                _buildAmountSelector(context, maxLoan),
                const SizedBox(height: 24),
                _buildRepaymentSummaryCard(
                  context,
                  _selectedAmount,
                  monthlyRate,
                  tenure,
                  monthlyPayment,
                  totalRepayment,
                ),
                const SizedBox(height: 24),
                _buildTermsCheckbox(context),
                const SizedBox(height: 12),
                _buildApplyButton(
                  context,
                  score,
                  monthlyRate,
                  tenure,
                  monthlyPayment,
                  totalRepayment,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const MyLoansTab(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Text(
      'Fuel your first step into business',
      style: TextStyle(
        fontSize: AppResponsive.sp(context, 18),
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildCreditScoreCard(BuildContext context, int score) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _riskColor(score).withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 16),
                  fontWeight: FontWeight.bold,
                  color: _riskColor(score),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Credit Score',
                  style: TextStyle(
                    fontSize: AppResponsive.sp(context, 13),
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_riskLabel(score)} Risk',
                  style: TextStyle(
                    fontSize: AppResponsive.sp(context, 15),
                    fontWeight: FontWeight.w600,
                    color: _riskColor(score),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiRecommendationCard(
    BuildContext context,
    int score,
    double maxLoan,
    double rate,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryBlue, Color(0xFF3366CC)],
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'AI Recommended',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Based on your credit score, you qualify for:',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 14),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAiStat(
                  context,
                  'Amount Range',
                  'RM ${_minLoan.toStringAsFixed(0)} – RM ${maxLoan.toStringAsFixed(0)}',
                ),
              ),
              Expanded(
                child: _buildAiStat(
                  context,
                  'Interest Rate',
                  '${(rate * 100).toStringAsFixed(2)}% / month',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAiStat(
            context,
            'Repayment Period',
            '3 months',
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildAiStat(
    BuildContext context,
    String label,
    String value, {
    bool fullWidth = false,
  }) {
    return Column(
      crossAxisAlignment: fullWidth
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 12),
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 15),
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessPurposeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Business Purpose',
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 16),
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButtonFormField<String>(
              value: _businessPurpose,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: InputBorder.none,
              ),
              hint: const Text(
                'Select how you will use this loan',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
              icon: const Icon(Icons.keyboard_arrow_down),
              items: _businessPurposes.map((purpose) {
                return DropdownMenuItem<String>(
                  value: purpose,
                  child: Text(purpose),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _businessPurpose = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSelector(BuildContext context, double maxLoan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Loan Amount',
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 16),
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'RM ${_selectedAmount.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 18),
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryBlue,
            inactiveTrackColor: AppTheme.primaryLight,
            thumbColor: AppTheme.primaryBlue,
            overlayColor: AppTheme.primaryBlue.withOpacity(0.2),
            trackHeight: 6,
          ),
          child: Slider(
            value: _selectedAmount,
            min: _minLoan,
            max: maxLoan,
            divisions: maxLoan > _minLoan
                ? ((maxLoan - _minLoan) / 100).round()
                : null,
            onChanged: (value) {
              setState(() {
                _selectedAmount = (value / 100).round() * 100;
                if (_selectedAmount < _minLoan) _selectedAmount = _minLoan;
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RM ${_minLoan.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 12),
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              'RM ${maxLoan.toStringAsFixed(0)}',
              style: TextStyle(
                fontSize: AppResponsive.sp(context, 12),
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          children: [
            _buildAmountChip(context, 500, maxLoan),
            _buildAmountChip(context, 1000, maxLoan),
            _buildAmountChip(context, 2000, maxLoan),
            _buildAmountChip(context, maxLoan, maxLoan, label: 'Max'),
          ],
        ),
      ],
    );
  }

  Widget _buildAmountChip(
    BuildContext context,
    double amount,
    double maxLoan, {
    String? label,
  }) {
    final isSelected = _selectedAmount == amount;
    final isDisabled = amount > maxLoan;

    return ChoiceChip(
      label: Text(label ?? 'RM ${amount.toStringAsFixed(0)}'),
      selected: isSelected,
      onSelected: isDisabled
          ? null
          : (selected) {
              setState(() {
                _selectedAmount = amount;
              });
            },
      selectedColor: AppTheme.primaryBlue,
      backgroundColor: const Color(0xFFF3F4F6),
      labelStyle: TextStyle(
        color: isDisabled
            ? AppTheme.textSecondary.withOpacity(0.5)
            : isSelected
            ? Colors.white
            : AppTheme.textPrimary,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  Widget _buildRepaymentSummaryCard(
    BuildContext context,
    double amount,
    double rate,
    int tenure,
    double monthlyPayment,
    double totalRepayment,
  ) {
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
          Text(
            'Repayment Summary',
            style: TextStyle(
              fontSize: AppResponsive.sp(context, 16),
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            context,
            'Loan Amount',
            'RM ${amount.toStringAsFixed(0)}',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            context,
            'Interest Rate',
            '${(rate * 100).toStringAsFixed(2)}% / month',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(context, 'Repayment Period', '$tenure months'),
          const Divider(height: 24),
          _buildSummaryRow(
            context,
            'Monthly Installment',
            'RM ${monthlyPayment.toStringAsFixed(2)}',
            isHighlight: true,
          ),
          const SizedBox(height: 10),
          _buildSummaryRow(
            context,
            'Total Repayment',
            'RM ${totalRepayment.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 14),
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppResponsive.sp(context, 14),
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight ? AppTheme.primaryBlue : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (value) {
            setState(() {
              _termsAccepted = value ?? false;
            });
          },
          activeColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _termsAccepted = !_termsAccepted;
              });
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'I agree to the Spark Loan Terms & Conditions and understand that late payments may affect my credit score.',
                style: TextStyle(
                  fontSize: AppResponsive.sp(context, 13),
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApplyButton(
    BuildContext context,
    int score,
    double monthlyRate,
    int tenure,
    double monthlyPayment,
    double totalRepayment,
  ) {
    final canApply = _businessPurpose != null && _termsAccepted;

    return ElevatedButton(
      onPressed: canApply
          ? () {
              final loan = Loan(
                id: 'SL-${DateTime.now().millisecondsSinceEpoch}',
                amount: _selectedAmount,
                purpose: _businessPurpose!,
                interestRate: monthlyRate,
                tenureMonths: tenure,
                monthlyInstallment: monthlyPayment,
                totalRepayment: totalRepayment,
                remainingBalance: totalRepayment,
                nextDueDate: DateTime.now().add(const Duration(days: 30)),
                status: LoanStatus.pending,
                createdAt: DateTime.now(),
              );
              context.read<AppState>().addLoan(loan);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Spark Loan created successfully!'),
                  backgroundColor: AppTheme.accentGreen,
                ),
              );
              setState(() {
                _businessPurpose = null;
                _termsAccepted = false;
                _selectedAmount = 500;
              });
              _tabController.animateTo(1);
            }
          : null,
      child: const Text('Apply Now'),
    );
  }

}
