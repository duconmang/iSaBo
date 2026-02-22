class SavingsTileData {
  int id;
  int amount;
  bool isPaid;
  DateTime? paidAt;

  SavingsTileData({
    this.id = 0,
    required this.amount,
    this.isPaid = false,
    this.paidAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'isPaid': isPaid,
    'paidAt': paidAt?.toIso8601String(),
  };

  factory SavingsTileData.fromJson(Map<String, dynamic> json) =>
      SavingsTileData(
        id: json['id'] ?? 0,
        amount: json['amount'] ?? 0,
        isPaid: json['isPaid'] ?? false,
        paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt']) : null,
      );
}
