import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';

class FirebaseService {
  static const String _studentsCollectionName = 'students';
  final CollectionReference<Map<String, dynamic>> _studentCollection =
      FirebaseFirestore.instance.collection(_studentsCollectionName);

  // Lắng nghe dữ liệu realtime từ Firestore.
  Stream<List<Student>> getStudents() {
    return _studentCollection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => _mapDocumentToStudent(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> addStudent(Student student) async {
    final data = _mapStudentToFirestore(student)..remove('id');
    await _studentCollection.add(data);
  }

  Future<void> updateStudent(Student student) async {
    final data = _mapStudentToFirestore(student)..remove('id');
    await _studentCollection.doc(student.id).update(data);
  }

  Future<void> deleteStudent(String id) async {
    await _studentCollection.doc(id).delete();
  }

  // Kiểm tra xem MSV đã tồn tại trong cơ sở dữ liệu chưa
  Future<bool> isStudentIdExists(String studentId) async {
    try {
      final query = await _studentCollection
          .where('studentId', isEqualTo: studentId)
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Lỗi kiểm tra MSV: $e');
    }
  }

  Student _mapDocumentToStudent(String docId, Map<String, dynamic> data) {
    return Student(
      id: docId,
      name: (data['name'] as String?) ?? '',
      studentId: (data['studentId'] as String?) ?? '',
      className: (data['className'] as String?) ?? '',
      gpa: (data['gpa'] as num?)?.toDouble() ?? 0.0,
      email: (data['email'] as String?) ?? '',
      avatarUrl: data['avatarUrl'] as String?,
      birthDate: data['birthDate'] != null 
          ? DateTime.parse(data['birthDate'] as String) 
          : null,
      faculty: data['faculty'] as String?,
      major: data['major'] as String?,
      yearIn: (data['yearIn'] as num?)?.toInt(),
    );
  }

  // Ưu tiên toMap(), fallback sang toJson() để tương thích model hiện tại.
  Map<String, dynamic> _mapStudentToFirestore(Student student) {
    final dynamic dynamicStudent = student;

    try {
      final map = dynamicStudent.toMap() as Map<String, dynamic>;
      return Map<String, dynamic>.from(map);
    } catch (_) {
      final map = dynamicStudent.toJson() as Map<String, dynamic>;
      return Map<String, dynamic>.from(map);
    }
  }
}
