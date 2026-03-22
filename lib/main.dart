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
        // compute once
        // (we assign here by creating a local variable inside the ThemeData builder below)
        // AppBar theo Material 3
        appBarTheme: AppBarTheme(
          backgroundColor:
              ColorScheme.fromSeed(seedColor: Colors.blue).primaryContainer,
          foregroundColor:
              ColorScheme.fromSeed(seedColor: Colors.blue).onPrimaryContainer,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
        // Elevated button theo MD3
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                ColorScheme.fromSeed(seedColor: Colors.blue).primary,
            foregroundColor:
                ColorScheme.fromSeed(seedColor: Colors.blue).onPrimary,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          ),
        ),
        // Input fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: ColorScheme.fromSeed(seedColor: Colors.blue)
              .surfaceContainerHighest,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: ColorScheme.fromSeed(seedColor: Colors.blue).primary,
                width: 2),
          ),
        ),
        // Card / surface
        cardTheme: CardTheme(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor:
              ColorScheme.fromSeed(seedColor: Colors.blue).secondary,
          foregroundColor:
              ColorScheme.fromSeed(seedColor: Colors.blue).onSecondary,
        ),
        // General visual density and typography
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const DashboardScreen(),
    );
  }
}
