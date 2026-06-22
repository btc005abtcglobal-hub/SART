class WalletModel {
  final String id;
  final double balance;
  final String cardNumber;
  final String cardType;
  final List<String> linkedPaymentMethods;

  const WalletModel({
    required this.id,
    required this.balance,
    required this.cardNumber,
    required this.cardType,
    required this.linkedPaymentMethods,
  });

  WalletModel copyWith({
    String? id,
    double? balance,
    String? cardNumber,
    String? cardType,
    List<String>? linkedPaymentMethods,
  }) {
    return WalletModel(
      id: id ?? this.id,
      balance: balance ?? this.balance,
      cardNumber: cardNumber ?? this.cardNumber,
      cardType: cardType ?? this.cardType,
      linkedPaymentMethods: linkedPaymentMethods ?? this.linkedPaymentMethods,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'balance': balance,
      'cardNumber': cardNumber,
      'cardType': cardType,
      'linkedPaymentMethods': linkedPaymentMethods,
    };
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: json['id'] as String,
      balance: (json['balance'] as num).toDouble(),
      cardNumber: json['cardNumber'] as String,
      cardType: json['cardType'] as String,
      linkedPaymentMethods: List<String>.from(json['linkedPaymentMethods'] as List),
    );
  }
}
