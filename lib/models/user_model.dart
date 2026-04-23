import 'dart:typed_data';

enum KycStatus { notVerified, pending, verified }

class User {
  final String name;
  final String email;
  final String phone;
  final double balance;
  final KycStatus kycStatus;
  final String? profileImageUrl;
  final int creditScore;

  const User({
    required this.name,
    required this.email,
    required this.phone,
    required this.balance,
    this.kycStatus = KycStatus.notVerified,
    this.profileImageUrl,
    this.creditScore = 0,
  });

  User copyWith({
    String? name,
    String? email,
    String? phone,
    double? balance,
    KycStatus? kycStatus,
    String? profileImageUrl,
    int? creditScore,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      balance: balance ?? this.balance,
      kycStatus: kycStatus ?? this.kycStatus,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      creditScore: creditScore ?? this.creditScore,
    );
  }
}

enum Nationality { malaysian, nonMalaysian }

class KycData {
  final Nationality? nationality;
  final String? idNumber;
  final String? fullName;
  final String? dateOfBirth;
  final String? address;
  final String? occupation;
  final String? businessType;
  final Uint8List? frontDocument;
  final Uint8List? backDocument;
  final Uint8List? passportDocument;
  final Uint8List? selfie;

  const KycData({
    this.nationality,
    this.idNumber,
    this.fullName,
    this.dateOfBirth,
    this.address,
    this.occupation,
    this.businessType,
    this.frontDocument,
    this.backDocument,
    this.passportDocument,
    this.selfie,
  });

  KycData copyWith({
    Nationality? nationality,
    String? idNumber,
    String? fullName,
    String? dateOfBirth,
    String? address,
    String? occupation,
    String? businessType,
    Uint8List? frontDocument,
    Uint8List? backDocument,
    Uint8List? passportDocument,
    Uint8List? selfie,
  }) {
    return KycData(
      nationality: nationality ?? this.nationality,
      idNumber: idNumber ?? this.idNumber,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      address: address ?? this.address,
      occupation: occupation ?? this.occupation,
      businessType: businessType ?? this.businessType,
      frontDocument: frontDocument ?? this.frontDocument,
      backDocument: backDocument ?? this.backDocument,
      passportDocument: passportDocument ?? this.passportDocument,
      selfie: selfie ?? this.selfie,
    );
  }
}
