class NotificationModel {
  final int id;
  final int userId;
  final String type;
  final String title;
  final String desc;
  final String time;
  final bool read;

  NotificationModel({
    required this.id, required this.userId, required this.type,
    required this.title, required this.desc,
    this.time = 'Just now', this.read = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'type': type, 'title': title,
    'desc': desc, 'time': time, 'read': read ? 1 : 0,
  };

  factory NotificationModel.fromMap(Map<String, dynamic> m) => NotificationModel(
    id: m['id'] as int, userId: m['userId'] as int,
    type: m['type'] as String, title: m['title'] as String,
    desc: m['desc'] as String, time: m['time'] as String? ?? 'Just now',
    read: (m['read'] as int? ?? 0) == 1,
  );
}
