import 'package:flutter/material.dart';
import 'dart:async';

import '../models/student.dart';
import '../services/firebase_service.dart';

class StudentProvider extends ChangeNotifier {
  StudentProvider({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService();

  final FirebaseService _firebaseService;
  StreamSubscription<List<Student>>? _studentsSubscription;

  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Student> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Tương thích ngược với code cũ trong main.dart.
  void fetchStudents() => loadStudents();

  void loadStudents() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _studentsSubscription?.cancel();
    _studentsSubscription = _firebaseService.getStudents().listen(
      (studentList) {
        _students = studentList;
        _applyFilter(_searchQuery);
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _isLoading = false;
        _errorMessage = 'Không thể tải danh sách sinh viên';
        debugPrint('Lỗi khi load students: $error');
        notifyListeners();
      },
    );
  }

  Future<void> addStudent(Student student) async {
    try {
      await _firebaseService.addStudent(student);
    } catch (e) {
      _errorMessage = 'Không thể thêm sinh viên';
      debugPrint('Lỗi khi thêm sinh viên: $e');
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    try {
      await _firebaseService.updateStudent(student);
      // Cập nhật local cache để UI phản ánh ngay thay đổi
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
        _applyFilter(_searchQuery);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Không thể cập nhật sinh viên';
      debugPrint('Lỗi khi cập nhật sinh viên: $e');
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    // Optimistic remove from local cache so UI cập nhật ngay.
    final index = _students.indexWhere((s) => s.id == id);
    Student? removed;
    if (index != -1) {
      removed = _students.removeAt(index);
      _applyFilter(_searchQuery);
      notifyListeners();
    }

    try {
      await _firebaseService.deleteStudent(id);
    } catch (e) {
      // Nếu xóa trên server thất bại, phục hồi local cache và báo lỗi.
      if (removed != null) {
        _students.insert(index, removed);
        _applyFilter(_searchQuery);
        notifyListeners();
      }
      _errorMessage = 'Không thể xóa sinh viên';
      debugPrint('Lỗi khi xóa sinh viên: $e');
    }
  }

  void searchStudent(String query) {
    _searchQuery = query.trim();
    _applyFilter(_searchQuery);
    notifyListeners();
  }

  void _applyFilter(String query) {
    if (query.isEmpty) {
      _filteredStudents = List<Student>.from(_students);
      return;
    }

    final normalizedQuery = query.toLowerCase();
    _filteredStudents = _students.where((student) {
      final byName = student.name.toLowerCase().contains(normalizedQuery);
      final byMssv = student.studentId.toLowerCase().contains(normalizedQuery);
      return byName || byMssv;
    }).toList();
  }

  // Kiểm tra xem MSV đã tồn tại trong cơ sở dữ liệu chưa
  Future<bool> isStudentIdExists(String studentId) async {
    try {
      return await _firebaseService.isStudentIdExists(studentId);
    } catch (e) {
      debugPrint('Lỗi kiểm tra MSV: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _studentsSubscription?.cancel();
    super.dispose();
  }
}
