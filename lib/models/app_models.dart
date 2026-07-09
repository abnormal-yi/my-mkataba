enum UserRole { rider, owner, admin }

enum ContractStatus { active, expired, blocked, pending }

enum PaymentStatus { paid, unpaid, missed, pending }

enum PaymentType { daily, weekly, monthly }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? createdBy;
  final String? photoUrl;

  const User({
    required this.id, required this.name, required this.email,
    this.phone = '', required this.role, this.createdBy, this.photoUrl,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'], name: j['name'], email: j['email'],
    phone: j['phone'] ?? '', role: UserRole.values.firstWhere((r) => r.name == j['role']),
    createdBy: j['created_by'], photoUrl: j['photo_url'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'name': name, 'email': email, 'phone': phone,
    'role': role.name, if (createdBy != null) 'created_by': createdBy,
    if (photoUrl != null) 'photo_url': photoUrl,
  };

  User copyWith({String? name, String? email, String? phone, String? photoUrl}) => User(
    id: id, name: name ?? this.name, email: email ?? this.email,
    phone: phone ?? this.phone, role: role, createdBy: createdBy,
    photoUrl: photoUrl ?? this.photoUrl,
  );
}

class Contract {
  final String id;
  final String ownerId;
  final String ownerName;
  final String riderId;
  final String riderName;
  final String vehiclePlate;
  final String vehicleType;
  final DateTime startDate;
  final DateTime endDate;
  final PaymentType paymentType;
  final double totalAmount;
  final double dailyTarget;
  final ContractStatus status;
  final bool agreementAccepted;
  final DateTime? agreementDate;
  final int missedPayments;

  const Contract({
    required this.id, required this.ownerId, required this.ownerName,
    required this.riderId, required this.riderName,
    required this.vehiclePlate, required this.vehicleType,
    required this.startDate, required this.endDate,
    required this.paymentType, required this.totalAmount, required this.dailyTarget,
    this.status = ContractStatus.active, this.agreementAccepted = false,
    this.agreementDate, this.missedPayments = 0,
  });

  factory Contract.fromJson(Map<String, dynamic> j) => Contract(
    id: j['id'], ownerId: j['owner_id'], ownerName: j['owner_name'],
    riderId: j['rider_id'], riderName: j['rider_name'],
    vehiclePlate: j['plate_number'], vehicleType: j['vehicle_type'],
    startDate: DateTime.parse(j['start_date']),
    endDate: DateTime.parse(j['end_date']),
    paymentType: PaymentType.values.firstWhere((t) => t.name == j['payment_type']),
    totalAmount: (j['total_amount'] as num).toDouble(),
    dailyTarget: (j['daily_target'] as num).toDouble(),
    status: ContractStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => ContractStatus.active),
    agreementAccepted: j['agreement_accepted'] ?? false,
    agreementDate: j['agreement_date'] != null ? DateTime.parse(j['agreement_date']) : null,
    missedPayments: j['missed_payments'] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'owner_id': ownerId, 'owner_name': ownerName,
    'rider_id': riderId, 'rider_name': riderName,
    'plate_number': vehiclePlate, 'vehicle_type': vehicleType,
    'start_date': startDate.toIso8601String(),
    'end_date': endDate.toIso8601String(),
    'payment_type': paymentType.name, 'total_amount': totalAmount,
    'daily_target': dailyTarget, 'status': status.name,
    'agreement_accepted': agreementAccepted,
    if (agreementDate != null) 'agreement_date': agreementDate!.toIso8601String(),
    'missed_payments': missedPayments,
  };

  int get daysRemaining => endDate.difference(DateTime.now()).inDays;
  int get totalDays => endDate.difference(startDate).inDays;
  int get daysElapsed => DateTime.now().difference(startDate).inDays;
}

class Payment {
  final String id;
  final String contractId;
  final DateTime date;
  final double amountPaid;
  final double targetAmount;
  final PaymentStatus status;
  final String method;
  final bool isPartial;
  final String? riderId;

  const Payment({
    required this.id, required this.contractId, required this.date,
    required this.amountPaid, required this.targetAmount,
    this.status = PaymentStatus.pending, this.method = 'M-Pesa',
    this.isPartial = false, this.riderId,
  });

  factory Payment.fromJson(Map<String, dynamic> j) => Payment(
    id: j['id'], contractId: j['contract_id'],
    date: DateTime.parse(j['date']),
    amountPaid: (j['amount_paid'] as num).toDouble(),
    targetAmount: (j['target_amount'] as num).toDouble(),
    status: PaymentStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => PaymentStatus.pending),
    method: j['method'] ?? 'M-Pesa',
    isPartial: j['is_partial'] ?? false,
    riderId: j['rider_id'],
  );

  Map<String, dynamic> toJson() => {
    'id': id, 'contract_id': contractId, 'date': date.toIso8601String(),
    'amount_paid': amountPaid, 'target_amount': targetAmount,
    'status': status.name, 'method': method,
    'is_partial': isPartial, if (riderId != null) 'rider_id': riderId,
  };
}

class RiderPaymentSummary {
  final double totalAmount;
  final double amountPaid;
  final double remainingBalance;
  final int missedDays;
  final int totalDays;
  final int paidDays;

  const RiderPaymentSummary({
    required this.totalAmount, required this.amountPaid,
    required this.remainingBalance, required this.missedDays,
    required this.totalDays, required this.paidDays,
  });

  factory RiderPaymentSummary.fromJson(Map<String, dynamic> j) => RiderPaymentSummary(
    totalAmount: (j['total_amount'] as num).toDouble(),
    amountPaid: (j['amount_paid'] as num).toDouble(),
    remainingBalance: (j['remaining_balance'] as num).toDouble(),
    missedDays: j['missed_days'], totalDays: j['total_days'], paidDays: j['paid_days'],
  );
}

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationType type;

  const AppNotification({
    required this.id, required this.userId, required this.title,
    required this.message, required this.timestamp,
    this.isRead = false, required this.type,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: j['id'], userId: j['user_id'], title: j['title'],
    message: j['message'], timestamp: DateTime.parse(j['timestamp']),
    isRead: j['is_read'] ?? false,
    type: NotificationType.values.firstWhere((t) => t.name == j['type']),
  );
}

enum NotificationType {
  paymentReminder, missedPayment, contractExpiry,
  contractCreated, accountBlocked, general,
}

class RiderSummary {
  final String riderId;
  final String riderName;
  final String? photoUrl;
  final String vehiclePlate;
  final ContractStatus contractStatus;
  final int daysRemaining;
  final double balanceRemaining;
  final int missedPayments;
  final bool isBlocked;

  const RiderSummary({
    required this.riderId, required this.riderName, this.photoUrl,
    required this.vehiclePlate, required this.contractStatus,
    required this.daysRemaining, required this.balanceRemaining,
    this.missedPayments = 0, this.isBlocked = false,
  });

  factory RiderSummary.fromJson(Map<String, dynamic> j) => RiderSummary(
    riderId: j['rider_id'], riderName: j['rider_name'],
    photoUrl: j['photo_url'], vehiclePlate: j['plate_number'],
    contractStatus: ContractStatus.values.firstWhere((s) => s.name == j['status'], orElse: () => ContractStatus.active),
    daysRemaining: j['days_remaining'], balanceRemaining: (j['balance_remaining'] as num).toDouble(),
    missedPayments: j['missed_payments'] ?? 0, isBlocked: j['is_blocked'] ?? false,
  );
}

class SystemStats {
  final int totalUsers, totalOwners, totalRiders;
  final int activeContracts, expiredContracts, blockedContracts;
  final double totalRevenue;

  const SystemStats({
    required this.totalUsers, required this.totalOwners, required this.totalRiders,
    required this.activeContracts, required this.expiredContracts,
    required this.blockedContracts, required this.totalRevenue,
  });

  factory SystemStats.fromJson(Map<String, dynamic> j) => SystemStats(
    totalUsers: j['total_users'], totalOwners: j['total_owners'],
    totalRiders: j['total_riders'], activeContracts: j['active_contracts'],
    expiredContracts: j['expired_contracts'], blockedContracts: j['blocked_contracts'],
    totalRevenue: (j['total_revenue'] as num).toDouble(),
  );
}
