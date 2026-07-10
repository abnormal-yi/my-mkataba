class ContractModel {
  final int id;
  final String contractId;
  final int ownerId;
  final int riderId;
  final String ownerName;
  final String riderName;
  final String startDate;
  final String endDate;
  final String paymentType;
  final int dailyAmount;
  final int totalAmount;
  final int paidAmount;
  final String motorcycle;
  final String plate;
  final String status;
  final String agreementText;
  final String signedDate;
  final String region;
  final int gracePeriod;

  ContractModel({
    required this.id, required this.contractId, required this.ownerId,
    required this.riderId, required this.ownerName, required this.riderName,
    required this.startDate, required this.endDate, required this.paymentType,
    required this.dailyAmount, required this.totalAmount,
    this.paidAmount = 0, required this.motorcycle, this.status = 'Pending',
    this.plate = '', this.agreementText = '', this.signedDate = '', this.region = 'Arusha',
    this.gracePeriod = 3,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'contractId': contractId, 'ownerId': ownerId,
    'riderId': riderId, 'ownerName': ownerName, 'riderName': riderName,
    'startDate': startDate, 'endDate': endDate, 'paymentType': paymentType,
    'dailyAmount': dailyAmount, 'totalAmount': totalAmount,
    'paidAmount': paidAmount, 'motorcycle': motorcycle, 'plate': plate, 'status': status,
    'agreementText': agreementText, 'signedDate': signedDate,
    'region': region, 'gracePeriod': gracePeriod,
  };

  factory ContractModel.fromMap(Map<String, dynamic> m) => ContractModel(
    id: m['id'] as int, contractId: m['contractId'] as String,
    ownerId: m['ownerId'] as int, riderId: m['riderId'] as int,
    ownerName: m['ownerName'] as String, riderName: m['riderName'] as String,
    startDate: m['startDate'] as String, endDate: m['endDate'] as String,
    paymentType: m['paymentType'] as String,
    dailyAmount: m['dailyAmount'] as int, totalAmount: m['totalAmount'] as int,
    paidAmount: m['paidAmount'] as int? ?? 0,
    motorcycle: m['motorcycle'] as String,
    plate: m['plate'] as String? ?? '',
    status: m['status'] as String? ?? 'Pending',
    agreementText: m['agreementText'] as String? ?? '',
    signedDate: m['signedDate'] as String? ?? '',
    region: m['region'] as String? ?? 'Arusha',
    gracePeriod: m['gracePeriod'] as int? ?? 3,
  );

  factory ContractModel.empty() => ContractModel(
    id: 0, contractId: '', ownerId: 0, riderId: 0,
    ownerName: '', riderName: '', startDate: '', endDate: '',
    paymentType: '', dailyAmount: 0, totalAmount: 0,
    paidAmount: 0, motorcycle: '',
  );

  ContractModel copyWith({int? paidAmount, String? status}) => ContractModel(
    id: id, contractId: contractId, ownerId: ownerId, riderId: riderId,
    ownerName: ownerName, riderName: riderName, startDate: startDate,
    endDate: endDate, paymentType: paymentType, dailyAmount: dailyAmount,
    totalAmount: totalAmount,     paidAmount: paidAmount ?? this.paidAmount,
    motorcycle: motorcycle, plate: plate, status: status ?? this.status,
    agreementText: agreementText, signedDate: signedDate, region: region,
    gracePeriod: gracePeriod,
  );
}
