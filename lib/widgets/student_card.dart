import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        // Đây là phần thành viên yếu sẽ dùng Agent để trang trí thêm
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(student.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("MSSV: ${student.studentId}"),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
