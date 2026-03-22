import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../utils/string_utils.dart';

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.editingStudent?.name ?? '',
    );
    _studentIdController = TextEditingController(
      text: widget.editingStudent?.studentId ?? generateStudentId(),
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
    if (widget.editingStudent?.birthDate != null) {
      _selectedBirthDate = widget.editingStudent!.birthDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _studentIdController.dispose();
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
    final gpa = double.tryParse(value);
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

  void _saveStudent() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final studentProvider =
        Provider.of<StudentProvider>(context, listen: false);

    final newStudent = Student(
      id: widget.editingStudent?.id ?? const Uuid().v4(),
      name: capitalizeName(_nameController.text.trim()),
      studentId: _studentIdController.text.trim(),
      className: _classNameController.text.trim(),
      gpa: double.parse(_gpaController.text.trim()),
      email: _emailController.text.trim(),
      avatarUrl: _avatarUrlController.text.trim().isEmpty
          ? null
          : _avatarUrlController.text.trim(),
      birthDate: _selectedBirthDate,
    );

    if (widget.editingStudent != null) {
      studentProvider.updateStudent(newStudent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật sinh viên thành công')),
      );
    } else {
      studentProvider.addStudent(newStudent);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm sinh viên thành công')),
      );
    }

    Navigator.of(context).pop();
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
                hint: 'Tự động sinh',
                prefixIcon: Icons.badge,
                validator: _validateStudentId,
                readOnly: true,
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
              _buildTextFormField(
                controller: _avatarUrlController,
                label: 'Ảnh đại diện (URL)',
                hint: 'Nhập URL ảnh (tùy chọn)',
                prefixIcon: Icons.image,
              ),
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
    return InkWell(
      onTap: _pickBirthDate,
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
        ),
        child: Text(
          _selectedBirthDate != null
              ? DateFormat('dd/MM/yyyy').format(_selectedBirthDate!)
              : 'Chưa chọn',
          style: TextStyle(
            color: _selectedBirthDate != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
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
      onPressed: _saveStudent,
      icon: const Icon(Icons.save),
      label: Text(
        widget.editingStudent != null ? 'Cập nhật' : 'Lưu',
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
