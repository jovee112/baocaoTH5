class Student {
  String id;
  String name;
  String studentId; // Mã sinh viên
  String className;
  double gpa;
  String email;
  String? avatarUrl;
  DateTime? birthDate; // Ngày sinh

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.className,
    required this.gpa,
    required this.email,
    this.avatarUrl,
    this.birthDate,
  });

  // Đây là chìa khóa để dùng với Agent/API
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'studentId': studentId,
        'className': className,
        'gpa': gpa,
        'email': email,
        'avatarUrl': avatarUrl,
        'birthDate': birthDate?.toIso8601String(),
      };

  factory Student.fromMap(Map<String, dynamic> map) {
    DateTime? bd;
    final bdRaw = map['birthDate'];
    if (bdRaw is String && bdRaw.isNotEmpty) {
      try {
        bd = DateTime.parse(bdRaw);
      } catch (_) {
        bd = null;
      }
    }

    return Student(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      studentId: (map['studentId'] as String?) ?? '',
      className: (map['className'] as String?) ?? '',
      gpa: (map['gpa'] is num)
          ? (map['gpa'] as num).toDouble()
          : double.tryParse('${map['gpa']}') ?? 0.0,
      email: (map['email'] as String?) ?? '',
      avatarUrl: map['avatarUrl'] as String?,
      birthDate: bd,
    );
  }
}
