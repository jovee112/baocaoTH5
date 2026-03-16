import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../widgets/student_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Chú ý: Cú pháp định danh theo yêu cầu các bài thực hành trước
        title: const Text("Quản lý Sinh viên - Nhóm [Số nhóm]"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        centerTitle: true,
      ),
      body: Consumer<StudentProvider>(
        builder: (context, studentProvider, child) {
          final students = studentProvider.students;

          if (students.isEmpty) {
            return const Center(child: Text("Danh sách trống"));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              return StudentCard(student: students[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Thành viên làm màn hình Add sẽ điều hướng ở đây
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chức năng Thêm đang phát triển")),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
