class PaymentModel {
  final int id;
  final String contractId;
  final int riderId;
  final int ownerId;
  final String riderName;
  final String ownerName;
  final String date;
  final int amount;
  final String method;
  final String status;

  PaymentModel({
    required this.id, required this.contractId, required this.riderId,
    required this.ownerId, this.riderName = '', this.ownerName = '',
    required this.date, required this.amount,
    this.method = 'M-Pesa', this.status = 'pending',
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'contractId': contractId, 'riderId': riderId,
    'ownerId': ownerId, 'riderName': riderName, 'ownerName': ownerName,
    'date': date, 'amount': amount, 'method': method, 'status': status,
  };

  factory PaymentModel.fromMap(Map<String, dynamic> m) => PaymentModel(
    id: m['id'] as int, contractId: m['contractId'] as String,
    riderId: m['riderId'] as int, ownerId: m['ownerId'] as int,
    riderName: m['riderName'] as String? ?? '',
    ownerName: m['ownerName'] as String? ?? '',
    date: m['date'] as String, amount: m['amount'] as int,
    method: m['method'] as String? ?? 'M-Pesa',
    status: m['status'] as String? ?? 'pending',
  );
}
