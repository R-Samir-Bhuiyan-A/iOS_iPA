class Deposit {
  final String id;
  final int amount;
  final String number;
  final String trxId;
  final String status;

  Deposit({required this.id, required this.amount, required this.number, required this.trxId, required this.status});

  factory Deposit.fromJson(Map<String, dynamic> json) {
    return Deposit(
      id: json['id'],
      amount: json['amount'],
      number: json['number'],
      trxId: json['trx_id'],
      status: json['status'],
    );
  }
}
