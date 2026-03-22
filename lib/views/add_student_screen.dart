import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../utils/string_utils.dart';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';
import '../services/firebase_service.dart';

class AddStudentScreen extends StatefulWidget {
  final Student? editingStudent;

  const AddStudentScreen({super.key, this.editingStudent});

  @override
  State<AddStudentScreen> createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  late final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _studentIdController;
  late TextEditingController _classNameController;
  late TextEditingController _emailController;
  late TextEditingController _gpaController;
  late TextEditingController _avatarUrlController;
  DateTime? _selectedBirthDate;
  Uint8List? _pickedImageBytes;
  String? _pickedImageName;
  VoidCallback? _classNameListener;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editingStudent?.name ?? '',
    );
    _studentIdController = TextEditingController(
      text: widget.editingStudent?.studentId ?? '',
    );
    _classNameController = TextEditingController(
      text: widget.editingStudent?.className ?? '',
    );
    _emailController = TextEditingController(
      text: widget.editingStudent?.email ?? '',
    );
    _gpaController = TextEditingController(
      text: widget.editingStudent?.gpa.toString() ?? '',
    );
    _avatarUrlController = TextEditingController(
      text: widget.editingStudent?.avatarUrl ?? '',
    );

    // Tự động chuyển chữ trong trường lớp sang IN HOA khi gõ
    _classNameListener = () {
      final text = _classNameController.text;
      final up = text.toUpperCase();
      if (text != up) {
        final sel = _classNameController.selection;
        _classNameController.value = TextEditingValue(text: up, selection: sel);
      }
    };
    _classNameController.addListener(_classNameListener!);

    // If editing and existing avatar exists, we keep the URL in controller.
    if (widget.editingStudent?.birthDate != null) {
      _selectedBirthDate = widget.editingStudent!.birthDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
    if (_classNameListener != null) {
      _classNameController.removeListener(_classNameListener!);
    }
    _classNameController.dispose();
    _emailController.dispose();
    _gpaController.dispose();
    _avatarUrlController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Tên sinh viên không được để trống';
    }
    if (value.length < 3) {
      return 'Tên sinh viên phải ít nhất 3 ký tự';
    }
    final nameRegex = RegExp(r'^[\p{L}\s]+$', unicode: true);
    if (!nameRegex.hasMatch(value)) {
      return 'Tên chỉ được chứa chữ và khoảng trắng';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String? _validateGpa(String? value) {
    if (value == null || value.isEmpty) {
      return 'GPA không được để trống';
    }
    final gpaStr = value.trim();
    // Cho phép số nguyên hoặc số thập phân với tối đa 2 chữ số sau dấu phẩy
    final gpaFormat = RegExp(
      r'^\d+(?:\.\d{1,2})?$',
    );
    if (!gpaFormat.hasMatch(gpaStr)) {
      return 'GPA chỉ được tối đa 2 chữ số phần thập phân';
    }
    final gpa = double.tryParse(gpaStr);
    if (gpa == null) {
      return 'GPA phải là một số';
    }
    if (gpa < 0 || gpa > 4.0) {
      return 'GPA phải từ 0 đến 4.0';
    }
    return null;
  }

  String? _validateStudentId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mã sinh viên không được để trống';
    }
    final onlyDigits = RegExp(r'^\d{10}$');
    if (!onlyDigits.hasMatch(value)) {
      return 'Mã sinh viên phải là 10 chữ số';
    }
    return null;
  }

  String? _validateClassName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Lớp không được để trống';
    }
    return null;
  }

  Future<void> _pickBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _saveStudent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    String? avatarUrl = _avatarUrlController.text.trim().isEmpty
        ? null
        : _avatarUrlController.text.trim();

    // If user picked a new image, upload it to Supabase and get URL
    // Note: upload is synchronous here for simplicity; we perform upload before creating the Student object.
    // In case of upload failure we proceed without avatar.
    if (_pickedImageBytes != null && _pickedImageName != null) {
      final supa = SupabaseService();
      final filename =
          '${DateTime.now().millisecondsSinceEpoch}_$_pickedImageName';
      final url = await supa.uploadAvatar(_pickedImageBytes!, filename);
      if (url != null) avatarUrl = url;
    }

    // Kiểm tra email trùng (nếu thêm mới hoặc đổi email khi chỉnh sửa)
    final firebaseService = FirebaseService();
    final emailTrim = _emailController.text.trim();
    final existingDocId =
        await firebaseService.findStudentDocIdByEmail(emailTrim);
    if (existingDocId != null &&
        (widget.editingStudent == null ||
            widget.editingStudent!.id != existingDocId)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Email đã tồn tại trong hệ thống')),
      );
      return;
    }

    // Kiểm tra MSSV trùng
    final studentIdTrim = _studentIdController.text.trim();
    final existingMssvDocId =
        await firebaseService.findStudentDocIdByStudentId(studentIdTrim);
    if (existingMssvDocId != null &&
        (widget.editingStudent == null ||
            widget.editingStudent!.id != existingMssvDocId)) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Mã sinh viên (MSSV) đã tồn tại')),
      );
      return;
    }

    final newStudent = Student(
      id: widget.editingStudent?.id ?? const Uuid().v4(),
      name: capitalizeName(_nameController.text.trim()),
      studentId: _studentIdController.text.trim(),
      className: _classNameController.text.trim(),
      gpa: double.parse(_gpaController.text.trim()),
      email: emailTrim,
      avatarUrl: avatarUrl,
      birthDate: _selectedBirthDate,
    );

    if (widget.editingStudent != null) {
      studentProvider.updateStudent(newStudent);
      messenger.showSnackBar(
        const SnackBar(content: Text('Cập nhật sinh viên thành công')),
      );
    } else {
      studentProvider.addStudent(newStudent);
      messenger.showSnackBar(
        const SnackBar(content: Text('Thêm sinh viên thành công')),
      );
    }

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.editingStudent != null
              ? 'Chỉnh sửa sinh viên'
              : 'Thêm sinh viên mới',
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTextFormField(
                controller: _nameController,
                label: 'Tên sinh viên',
                hint: 'Nhập tên sinh viên',
                prefixIcon: Icons.person,
                validator: _validateName,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _studentIdController,
                label: 'Mã sinh viên (MSSV)',
                hint: 'Nhập MSSV (10 chữ số)',
                prefixIcon: Icons.badge,
                validator: _validateStudentId,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _classNameController,
                label: 'Lớp',
                hint: 'Nhập tên lớp (vd: Mobile01)',
                prefixIcon: Icons.class_,
                validator: _validateClassName,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _emailController,
                label: 'Email',
                hint: 'Nhập email',
                prefixIcon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              _buildTextFormField(
                controller: _gpaController,
                label: 'GPA',
                hint: 'Nhập GPA (0-4.0)',
                prefixIcon: Icons.grade,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                validator: _validateGpa,
              ),
              const SizedBox(height: 16),
              _buildImagePicker(),
              const SizedBox(height: 16),
              _buildBirthDatePicker(),
              const SizedBox(height: 32),
              _buildSaveButton(),
              const SizedBox(height: 12),
              _buildCancelButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBirthDatePicker() {
    return FormField<DateTime>(
      initialValue: _selectedBirthDate,
      validator: (val) {
        return _selectedBirthDate == null ? 'Ngày sinh là bắt buộc' : null;
      },
      builder: (state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () async {
                await _pickBirthDate();
                state.didChange(_selectedBirthDate);
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Ngày sinh',
                  hintText: 'Chọn ngày sinh',
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  errorText: state.errorText,
                ),
                child: Text(
                  _selectedBirthDate != null
                      ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
                      : 'Chưa chọn',
                  style: TextStyle(
                    color:
                        _selectedBirthDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            if (state.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  state.errorText ?? '',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.error, fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildImagePicker() {
    final hasExisting = _avatarUrlController.text.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ảnh đại diện',
            style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        const SizedBox(height: 8),
        Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _pickedImageBytes != null
                    ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover)
                    : hasExisting
                        ? Image.network(_avatarUrlController.text,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.person))
                        : const Icon(Icons.photo_camera_outlined),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Chọn ảnh'),
                  ),
                  if (_pickedImageName != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(_pickedImageName!,
                          style: const TextStyle(fontSize: 12)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);
    if (result == null) return;
    final file = result.files.first;
    if (file.bytes == null) return;
    setState(() {
      _pickedImageBytes = file.bytes;
      _pickedImageName = file.name;
    });
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData prefixIcon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.blue,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      style: const TextStyle(),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      onPressed: () => _saveStudent(),
      icon: const Icon(Icons.save),
      label: Text(
        widget.editingStudent != null ? 'Cập nhật' : 'Lưu',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return OutlinedButton.icon(
      onPressed: () => Navigator.of(context).pop(),
      icon: const Icon(Icons.close),
      label: const Text(
        'Hủy',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.grey[700],
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
