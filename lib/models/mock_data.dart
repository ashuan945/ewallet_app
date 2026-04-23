import 'user_model.dart';

class MockData {
  static const User currentUser = User(
    name: 'Ahmad Bin Abdullah',
    email: 'ahmad.abdullah@email.com',
    phone: '+60 12-345 6789',
    balance: 2450.80,
    kycStatus: KycStatus.notVerified,
    creditScore: 742,
  );

  static const KycData mockOcrData = KycData(
    nationality: Nationality.malaysian,
    idNumber: '880101-01-1234',
    fullName: 'Ahmad Bin Abdullah',
    dateOfBirth: '01 Jan 1988',
    address: '123 Jalan Bukit Bintang, 55100 Kuala Lumpur',
    occupation: 'Employed',
    businessType: 'Private Limited (Sdn Bhd)',
  );

  static final List<Map<String, dynamic>> recentScans = [
    {'merchant': '7-Eleven KLCC', 'amount': 12.50, 'date': 'Today, 10:23 AM'},
    {
      'merchant': 'Shell petrol station',
      'amount': 55.00,
      'date': 'Yesterday, 6:45 PM',
    },
    {'merchant': 'MyNews SS15', 'amount': 8.90, 'date': '22 Apr, 9:15 AM'},
  ];

  static final List<Map<String, dynamic>> scoreFactors = [
    {'label': 'Payment History', 'value': 'Excellent', 'color': 0xFF00c853},
    {'label': 'Credit Utilization', 'value': 'Good', 'color': 0xFF00bfa5},
    {'label': 'Account Age', 'value': 'Fair', 'color': 0xFFff9800},
    {'label': 'Recent Inquiries', 'value': 'Good', 'color': 0xFF00bfa5},
  ];

  static final List<String> improvementTips = [
    'Pay all your bills on time every month',
    'Keep your credit utilization below 30%',
    'Avoid opening too many new accounts at once',
    'Check your credit report regularly for errors',
    'Maintain a mix of credit types for better scoring',
  ];

  static final List<Map<String, dynamic>> services = [
    {
      'title': 'Micro Savings',
      'subtitle': 'Save small, earn more',
      'icon': 'savings',
      'color': 0xFF00c853,
    },
    {
      'title': 'Micro Loan',
      'subtitle': 'Quick cash up to RM 10,000',
      'icon': 'money',
      'color': 0xFFff9800,
    },
    {
      'title': 'Business Loan',
      'subtitle': 'Grow your business',
      'icon': 'business',
      'color': 0xFF0047ba,
    },
    {
      'title': 'Insurance',
      'subtitle': 'Protect what matters',
      'icon': 'shield',
      'color': 0xFF7c4dff,
    },
    {
      'title': 'Investments',
      'subtitle': 'Grow your wealth',
      'icon': 'trending_up',
      'color': 0xFF00bfa5,
    },
    {
      'title': 'Pay Bills',
      'subtitle': 'Utilities & more',
      'icon': 'receipt',
      'color': 0xFFe53935,
    },
  ];
}
