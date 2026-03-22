import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/student.dart';
import '../services/firebase_service.dart';

class StudentProvider extends ChangeNotifier {
  StudentProvider({FirebaseService? firebaseService})
      : _firebaseService = firebaseService ?? FirebaseService() {
    _initConnectivity();
  }

  final FirebaseService _firebaseService;
  StreamSubscription<List<Student>>? _studentsSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  List<Student> _students = [];
  List<Student> _filteredStudents = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isOffline = false;

  List<Student> get students => _filteredStudents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isOffline => _isOffline;
  String? get offlineNotice => _isOffline
      ? 'Bạn đang offline, các thay đổi sẽ được tự động cập nhật khi kết nối sẵn sàng'
      : null;

  // Tương thích ngược với code cũ trong main.dart.
  Future<void> fetchStudents() async {
    await _loadCache();
    loadStudents();
  }

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
        _saveCache();
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
    if (_isOffline) {
      _enqueuePending({'type': 'add', 'student': student.toJson()});
      _errorMessage = offlineNotice;
      notifyListeners();
      return;
    }

    try {
      await _firebaseService.addStudent(student);
      _saveCache();
    } catch (e) {
      _enqueuePending({'type': 'add', 'student': student.toJson()});
      _errorMessage = 'Thao tác sẽ được lưu offline và đồng bộ khi có mạng';
      debugPrint('Lỗi khi thêm sinh viên: $e');
      notifyListeners();
    }
  }

  Future<void> updateStudent(Student student) async {
    if (_isOffline) {
      _enqueuePending({'type': 'update', 'student': student.toJson()});
      _errorMessage = offlineNotice;
      // apply locally
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
        _applyFilter(_searchQuery);
        notifyListeners();
        _saveCache();
      }
      return;
    }

    try {
      await _firebaseService.updateStudent(student);
      // Cập nhật local cache để UI phản ánh ngay thay đổi
      final index = _students.indexWhere((s) => s.id == student.id);
      if (index != -1) {
        _students[index] = student;
        _applyFilter(_searchQuery);
        notifyListeners();
        _saveCache();
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
      _saveCache();
    }

    if (_isOffline) {
      _enqueuePending({'type': 'delete', 'id': id});
      _errorMessage = offlineNotice;
      notifyListeners();
      return;
    }

    try {
      await _firebaseService.deleteStudent(id);
    } catch (e) {
      // Nếu xóa trên server thất bại, phục hồi local cache và báo lỗi.
      if (removed != null) {
        _students.insert(index, removed);
        _applyFilter(_searchQuery);
        notifyListeners();
        _saveCache();
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

  @override
  void dispose() {
    _studentsSubscription?.cancel();
    _connectivitySub?.cancel();
    super.dispose();
  }

  // -------------------- Local cache (SharedPreferences) --------------------
  static const String _kCachedStudentsKey = 'cached_students';

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _students.map((s) => s.toJson()).toList();
      await prefs.setString(_kCachedStudentsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Failed to save students cache: $e');
    }
  }

  Future<void> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCachedStudentsKey);
      if (raw == null || raw.isEmpty) return;
      final data = jsonDecode(raw) as List<dynamic>;
      _students = data
          .map((e) => Student.fromMap(Map<String, dynamic>.from(e)))
          .toList();
      _applyFilter(_searchQuery);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load students cache: $e');
    }
  }

  // -------------------- Pending queue for offline writes --------------------
  static const String _kPendingOpsKey = 'pending_student_ops';

  Future<void> _enqueuePending(Map<String, dynamic> op) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPendingOpsKey);
      final list = raw == null || raw.isEmpty
          ? <dynamic>[]
          : jsonDecode(raw) as List<dynamic>;
      list.add(op);
      await prefs.setString(_kPendingOpsKey, jsonEncode(list));
    } catch (e) {
      debugPrint('Failed to enqueue pending op: $e');
    }
  }

  Future<void> _processPendingQueue() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kPendingOpsKey);
      if (raw == null || raw.isEmpty) return;
      final list = jsonDecode(raw) as List<dynamic>;
      if (list.isEmpty) return;

      final remaining = <dynamic>[];

      for (final item in list) {
        final op = Map<String, dynamic>.from(item as Map);
        try {
          final type = op['type'] as String?;
          if (type == 'add') {
            final studentMap = Map<String, dynamic>.from(op['student'] as Map);
            final student = Student.fromMap(studentMap);
            await _firebaseService.addStudent(student);
          } else if (type == 'update') {
            final studentMap = Map<String, dynamic>.from(op['student'] as Map);
            final student = Student.fromMap(studentMap);
            if (student.id.isNotEmpty) {
              await _firebaseService.updateStudent(student);
            } else {
              remaining.add(op);
            }
          } else if (type == 'delete') {
            final id = op['id'] as String?;
            if (id != null && id.isNotEmpty) {
              await _firebaseService.deleteStudent(id);
            } else {
              remaining.add(op);
            }
          } else {
            remaining.add(op);
          }
        } catch (e) {
          debugPrint('Failed to process pending op: $e');
          remaining.add(op);
        }
      }

      await prefs.setString(_kPendingOpsKey, jsonEncode(remaining));
      if (remaining.isEmpty) {
        _errorMessage = null;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error processing pending queue: $e');
    }
  }

  Future<void> _initConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _updateConnectivity(result);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
    }

    _connectivitySub =
        Connectivity().onConnectivityChanged.listen(_updateConnectivity);
  }

  void _updateConnectivity(ConnectivityResult result) {
    final nowOffline = result == ConnectivityResult.none;
    if (nowOffline != _isOffline) {
      _isOffline = nowOffline;
      if (!_isOffline) {
        _processPendingQueue();
      }
      notifyListeners();
    }
  }
}
