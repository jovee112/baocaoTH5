import 'package:flutter/material.dart';
import '../models/student.dart';
import '../views/student_detail_screen.dart';

class StudentCard extends StatelessWidget {
  final Student student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => StudentDetailScreen(student: student),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: _buildStudentAvatar(),
          title: Text(
            student.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text("MSSV: ${student.studentId}", style: const TextStyle(fontSize: 12)),
              Text("Lớp: ${student.className}", style: const TextStyle(fontSize: 12)),
              if (student.faculty != null)
                Text("Khoa: ${student.faculty}", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          trailing: Chip(
            label: Text(
              "GPA: ${student.gpa.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            backgroundColor: _getGpaColor(student.gpa),
          ),
        ),
      ),
    );
  }

  Widget _buildStudentAvatar() {
    if (student.avatarUrl != null && student.avatarUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: NetworkImage(student.avatarUrl!),
        onBackgroundImageError: (exception, stackTrace) {
          // Nếu ảnh không load được, hiển thị icon mặc định
          debugPrint('Lỗi load ảnh: $exception');
        },
        child: Align(
          alignment: Alignment.bottomRight,
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1),
            ),
          ),
        ),
      );
    }
    return CircleAvatar(
      radius: 28,
      backgroundColor: Colors.blue.shade100,
      child: const Icon(Icons.person, color: Colors.blue),
    );
  }

  Color _getGpaColor(double gpa) {
    if (gpa >= 3.6) return Colors.green;
    if (gpa >= 3.2) return Colors.blue;
    if (gpa >= 2.5) return Colors.orange;
    return Colors.red;
  }
}
