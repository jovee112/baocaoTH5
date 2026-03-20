import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Thêm dòng này
import 'firebase_options.dart'; // File do FlutterFire CLI tạo ra
import 'providers/student_provider.dart';
import 'views/dashboard_screen.dart';

void main() async {
  // 1. Đảm bảo các dịch vụ của Flutter đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase từ file cấu hình DefaultFirebaseOptions
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        // 3. Khởi tạo Provider và gọi ngay hàm fetch để tải dữ liệu từ Firebase
        ChangeNotifierProvider(
          create: (_) => StudentProvider()..fetchStudents(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Manager',
      debugShowCheckedModeBanner: false, // Tắt biểu tượng Debug cho đẹp
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}
