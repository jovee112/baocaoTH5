import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import 'package:intl/intl.dart';
import '../models/student.dart';
import 'add_student_screen.dart';

class StudentDetailScreen extends StatelessWidget {
  final Student student;

  const StudentDetailScreen({
    super.key,
    required this.student,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chi tiết sinh viên',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAvatarSection(),
              const SizedBox(height: 32),
              _buildInfoCard(
                label: 'Tên sinh viên',
                value: student.name,
                icon: Icons.person,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                label: 'Mã sinh viên (MSSV)',
                value: student.studentId,
                icon: Icons.badge,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                label: 'Lớp',
                value: student.className,
                icon: Icons.class_,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                label: 'Email',
                value: student.email,
                icon: Icons.email,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                label: 'GPA',
                value: student.gpa.toStringAsFixed(2),
                icon: Icons.grade,
              ),
              if (student.birthDate != null) ...[
                const SizedBox(height: 16),
                _buildInfoCard(
                  label: 'Ngày sinh',
                  value: DateFormat('dd/MM/yyyy').format(student.birthDate!),
                  icon: Icons.calendar_today,
                ),
              ],
              const SizedBox(height: 32),
              _buildEditButton(context),
              const SizedBox(height: 12),
              _buildDeleteButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade100,
            child: student.avatarUrl != null && student.avatarUrl!.isNotEmpty
                ? Image.network(
                    student.avatarUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.blue.shade700,
                      );
                    },
                  )
                : Icon(
                    Icons.person,
                    size: 60,
                    color: Colors.blue.shade700,
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            student.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getGpaColor(student.gpa),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'GPA: ${student.gpa.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => AddStudentScreen(editingStudent: student),
          ),
        )
            .then((_) {
          Navigator.of(context).pop();
        });
      },
      icon: const Icon(Icons.edit),
      label: Text(
        'Chỉnh sửa',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Text(
                'Xác nhận xóa',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              content: Text(
                'Bạn có chắc chắn muốn xóa sinh viên này?',
                style: const TextStyle(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Hủy'),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    final provider =
                        Provider.of<StudentProvider>(context, listen: false);
                    await provider.deleteStudent(student.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Xóa sinh viên thành công')),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Xóa',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        );
      },
      icon: const Icon(Icons.delete),
      label: Text(
        'Xóa',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: const BorderSide(color: Colors.red),
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
