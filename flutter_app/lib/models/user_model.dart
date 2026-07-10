class UserModel {
  final int id;
  final String name;
  final String email;
  final String password;
  final String role;
  final String initials;
  final String phone;
  final String nationalId;
  final String status;
  final String region;
  final int createdBy;
  final bool firstLogin;
  final String? photo;

  UserModel({
    required this.id, required this.name, required this.email,
    required this.password, required this.role, required this.initials,
    this.phone = '', this.nationalId = '', this.status = 'Active',
    this.region = 'Arusha', this.createdBy = 0, this.firstLogin = false,
    this.photo,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'email': email, 'password': password,
    'role': role, 'initials': initials, 'phone': phone,
    'nationalId': nationalId, 'status': status, 'region': region,
    'createdBy': createdBy, 'firstLogin': firstLogin ? 1 : 0, 'photo': photo ?? '',
  };

  factory UserModel.fromMap(Map<String, dynamic> m) => UserModel(
    id: m['id'] as int, name: m['name'] as String,
    email: m['email'] as String, password: m['password'] as String,
    role: m['role'] as String, initials: m['initials'] as String,
    phone: m['phone'] as String? ?? '',
    nationalId: m['nationalId'] as String? ?? '',
    status: m['status'] as String? ?? 'Active',
    region: m['region'] as String? ?? 'Arusha',
    createdBy: m['createdBy'] as int? ?? 0,
    firstLogin: (m['firstLogin'] as int? ?? 0) == 1,
    photo: m['photo'] as String?,
  );
}
