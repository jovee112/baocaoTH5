import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/firebase_service.dart'; // Đảm bảo bạn đã tạo file này

class StudentProvider with ChangeNotifier {
  // Khởi tạo service để giao tiếp với Firebase
  final FirebaseService _firebaseService = FirebaseService();

  // Danh sách sinh viên bây giờ sẽ lấy từ Firebase thay vì hardcode
  List<Student> _students = [];

  List<Student> get students => _students;

  // 1. Hàm lấy dữ liệu (Hàm này giúp hết lỗi ở main.dart)
  void fetchStudents() {
    _firebaseService.getStudents().listen((studentList) {
      _students = studentList;
      notifyListeners(); // Cập nhật UI khi dữ liệu trên Firebase thay đổi
    });
  }

  // 2. Hàm thêm sinh viên lên Firebase
  Future<void> addStudent(Student student) async {
    try {
      await _firebaseService.addStudent(student);
      // Lưu ý: Không cần notifyListeners() ở đây vì hàm fetchStudents
      // đang lắng nghe Stream từ Firebase, nó sẽ tự cập nhật khi có data mới.
    } catch (e) {
      debugPrint("Lỗi khi thêm sinh viên: $e");
    }
  }

  // 3. Hàm xóa sinh viên khỏi Firebase
  Future<void> deleteStudent(String id) async {
    try {
      await _firebaseService.deleteStudent(id);
    } catch (e) {
      debugPrint("Lỗi khi xóa sinh viên: $e");
    }
  }
}
