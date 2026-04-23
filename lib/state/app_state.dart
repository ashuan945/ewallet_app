import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../models/mock_data.dart';

class AppState extends ChangeNotifier {
  int _currentNavIndex = 0;
  User _user = MockData.currentUser;
  KycData _kycData = const KycData();
  bool _isBalanceVisible = true;

  int get currentNavIndex => _currentNavIndex;
  User get user => _user;
  KycData get kycData => _kycData;
  bool get isBalanceVisible => _isBalanceVisible;

  void setNavIndex(int index) {
    _currentNavIndex = index;
    notifyListeners();
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void setKycNationality(Nationality nationality) {
    _kycData = _kycData.copyWith(nationality: nationality);
    notifyListeners();
  }

  void setKycDocuments({
    Uint8List? front,
    Uint8List? back,
    Uint8List? passport,
  }) {
    _kycData = _kycData.copyWith(
      frontDocument: front,
      backDocument: back,
      passportDocument: passport,
    );
    notifyListeners();
  }

  void setKycSelfie(Uint8List selfie) {
    _kycData = _kycData.copyWith(selfie: selfie);
    notifyListeners();
  }

  void updateKycField({String? occupation, String? businessType}) {
    _kycData = _kycData.copyWith(
      occupation: occupation ?? _kycData.occupation,
      businessType: businessType ?? _kycData.businessType,
    );
    notifyListeners();
  }

  void submitKyc() {
    _user = _user.copyWith(kycStatus: KycStatus.pending);
    _kycData = MockData.mockOcrData.copyWith(
      nationality: _kycData.nationality,
      frontDocument: _kycData.frontDocument,
      backDocument: _kycData.backDocument,
      passportDocument: _kycData.passportDocument,
      selfie: _kycData.selfie,
      occupation: _kycData.occupation,
      businessType: _kycData.businessType,
    );
    notifyListeners();
  }

  void resetKyc() {
    _kycData = const KycData();
    notifyListeners();
  }
}
