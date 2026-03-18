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
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue.shade100,
            child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                ? Image.network(
                    student.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person);
                    },
                  )
                : const Icon(Icons.person),
          ),
          title: Text(
            student.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text("MSSV: ${student.studentId}"),
              Text("Lớp: ${student.className}"),
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

  Color _getGpaColor(double gpa) {
    if (gpa >= 3.6) return Colors.green;
    if (gpa >= 3.2) return Colors.blue;
    if (gpa >= 2.5) return Colors.orange;
    return Colors.red;
  }
}
