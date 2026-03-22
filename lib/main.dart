import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/student_provider.dart';
// ignore: unused_import
import 'views/dashboard_screen.dart';
import 'views/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          backgroundColor:
              ColorScheme.fromSeed(seedColor: Colors.blue).primaryContainer,
          foregroundColor:
              ColorScheme.fromSeed(seedColor: Colors.blue).onPrimaryContainer,
          elevation: 0,
          centerTitle: false,
          surfaceTintColor: Colors.transparent,
        ),
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      builder: (context, child) {
        final prov = Provider.of<StudentProvider>(context);
        return Column(
          children: [
            OfflineBanner(
                isOffline: prov.isOffline, message: prov.offlineNotice),
            Expanded(child: child ?? const SizedBox()),
          ],
        );
      },
      home: const WelcomeScreen(),
    );
  }
}

class OfflineBanner extends StatefulWidget {
  final bool isOffline;
  final String? message;
  const OfflineBanner({super.key, required this.isOffline, this.message});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> {
  bool _visible = false;
  Timer? _timer;

  @override
  void didUpdateWidget(covariant OfflineBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isOffline && !_visible) {
      setState(() => _visible = true);
      _timer?.cancel();
      _timer = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _visible = false);
      });
    }

    if (!widget.isOffline && _visible) {
      _timer?.cancel();
      setState(() => _visible = false);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isOffline || !_visible) return const SizedBox.shrink();

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Card(
              color: Colors.orange.shade700,
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.message ??
                            'Bạn đang offline, các thay đổi sẽ được tự động cập nhật khi kết nối sẵn sàng',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        _timer?.cancel();
                        setState(() => _visible = false);
                      },
                      child: const Text(
                        'Close',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
