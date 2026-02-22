class SavingsGoal {
  int id;
  String? name;
  double? targetAmount;
  DateTime? startDate;
  double savedAmount;
  // Bank info for VietQR
  String? bankId;
  String? accountNo;
  String? accountName;

  SavingsGoal({
    this.id = 0,
    this.name,
    this.targetAmount,
    this.startDate,
    this.savedAmount = 0,
    this.bankId,
    this.accountNo,
    this.accountName,
  });

  double get progress {
    if (targetAmount == null || targetAmount == 0) return 0;
    return (savedAmount / targetAmount!) * 100;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'startDate': startDate?.toIso8601String(),
    'savedAmount': savedAmount,
    'bankId': bankId,
    'accountNo': accountNo,
    'accountName': accountName,
  };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'] ?? 0,
    name: json['name'],
    targetAmount: (json['targetAmount'] as num?)?.toDouble(),
    startDate: json['startDate'] != null
        ? DateTime.parse(json['startDate'])
        : null,
    savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0,
    bankId: json['bankId'],
    accountNo: json['accountNo'],
    accountName: json['accountName'],
  );
}
