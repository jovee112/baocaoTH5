class Student {
  String id;
  String name;
  String studentId; // Mã sinh viên
  String className;
  double gpa;
  String email;
  String? avatarUrl;
  DateTime? birthDate; // Ngày sinh
  String? faculty; // Khoa
  String? major; // Ngành
  int? yearIn; // Khóa (năm vào)

  Student({
    required this.id,
    required this.name,
    required this.studentId,
    required this.className,
    required this.gpa,
    required this.email,
    this.avatarUrl,
    this.birthDate,
    this.faculty,
    this.major,
    this.yearIn,
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
        'faculty': faculty,
        'major': major,
        'yearIn': yearIn,
      };
}
