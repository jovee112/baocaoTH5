import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirebaseService {
  // Tham chiếu đến bảng 'students' trên Firestore
  final CollectionReference _studentCollection =
      FirebaseFirestore.instance.collection('students');

  // 1. Lấy danh sách sinh viên (Stream để cập nhật realtime)
  Stream<List<Student>> getStudents() {
    return _studentCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        // Gán lại id từ document của Firebase
        data['id'] = doc.id;
        return Student(
          id: data['id'],
          name: data['name'] ?? '',
          studentId: data['studentId'] ?? '',
          className: data['className'] ?? '',
          gpa: (data['gpa'] ?? 0.0).toDouble(),
          email: data['email'] ?? '',
          avatarUrl: data['avatarUrl'],
        );
      }).toList();
    });
  }

  // 2. Thêm sinh viên mới
  Future<void> addStudent(Student student) {
    return _studentCollection.add(student.toJson());
  }

  // 3. Xóa sinh viên
  Future<void> deleteStudent(String id) {
    return _studentCollection.doc(id).delete();
  }
}
