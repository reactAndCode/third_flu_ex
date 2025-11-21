import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/auth_provider.dart';
import 'providers/workout_provider.dart';
import 'screens/home_screen.dart';
import 'screens/new_home_screen.dart';
import 'screens/login_screen.dart';

const String supabaseUrl = String.fromEnvironment(
  'NEXT_PUBLIC_SUPABASE_URL',
  defaultValue: 'https://uizoxtnvqisiicvcxgty.supabase.co',
);

const String supabaseAnonKey = String.fromEnvironment(
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVpem94dG52cWlzaWljdmN4Z3R5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjIxMzYzNDAsImV4cCI6MjA3NzcxMjM0MH0.DAfvBKVwXkdv7UX0G25gNJG8shkdopHFuRkcvTTuGtM',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
      ],
      child: MaterialApp(
        title: 'My Awesome',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isAuthenticated) {
          // 로그인 상태면 운동 데이터 로드 후 홈 화면 표시
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<WorkoutProvider>().loadWorkouts();
          });
          return const NewHomeScreen();
        } else {
          return const LoginScreen();
        }
      },
    );
  }
}
