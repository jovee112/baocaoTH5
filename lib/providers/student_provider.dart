import 'package:flutter/material.dart';
import '../models/student.dart';

class StudentProvider with ChangeNotifier {
  // Danh sách sinh viên mẫu để cả nhóm có cái hiển thị ngay
  final List<Student> _students = [
    Student(
      id: '1',
      name: 'Nguyễn Văn A',
      studentId: 'SV001',
      className: 'Mobile01',
      gpa: 3.5,
      email: 'a@gmail.com',
    ),
  ];

  List<Student> get students => _students;

  // Hàm thêm sinh viên (Thành viên làm Form sẽ gọi hàm này)
  void addStudent(Student student) {
    _students.add(student);
    notifyListeners(); // Thông báo để UI tự cập nhật (Bài 1)
  }

  // Hàm xóa sinh viên (Thành viên làm chức năng Xóa sẽ gọi)
  void deleteStudent(String id) {
    _students.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  // Hàm cập nhật sinh viên (Trần Ngọc Lương - Chức năng 4)
  void updateStudent(Student student) {
    final index = _students.indexWhere((s) => s.id == student.id);
    if (index != -1) {
      _students[index] = student;
      notifyListeners(); // Thông báo để UI tự cập nhật
    }
  }

  // Hàm tìm kiếm sinh viên theo tên hoặc MSSV (Trần Ngọc Lương - Chức năng 4)
  List<Student> searchStudents(String query) {
    if (query.isEmpty) {
      return _students;
    }
    
    final lowerQuery = query.toLowerCase();
    return _students.where((student) {
      return student.name.toLowerCase().contains(lowerQuery) ||
          student.studentId.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
