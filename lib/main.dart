import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:focus/screens/onboarding_screen.dart';
import 'package:focus/screens/home_screen.dart';
import 'package:focus/services/storage_service.dart';
import 'package:focus/utils/theme.dart';
import 'package:focus/blocs/tasks_goals/tasks_goals_cubit.dart';

// Global callback for theme toggle
void Function()? themeToggleCallback;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatefulWidget {
  const FocusFlowApp({super.key});

  @override
  State<FocusFlowApp> createState() => _FocusFlowAppState();
}

class _FocusFlowAppState extends State<FocusFlowApp> {
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    // Set the global callback
    themeToggleCallback = toggleTheme;
  }

  @override
  void dispose() {
    themeToggleCallback = null;
    super.dispose();
  }

  void _loadThemeMode() {
    final isDarkMode = StorageService.getBool('is_dark_mode');
    if (isDarkMode != null) {
      setState(() {
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
      });
    }
  }

  void toggleTheme() {
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        StorageService.setBool('is_dark_mode', true);
      } else {
        _themeMode = ThemeMode.light;
        StorageService.setBool('is_dark_mode', false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FocusFlow',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      home: MultiBlocProvider(
        providers: [
          BlocProvider<TasksGoalsCubit>(
            create: (_) => TasksGoalsCubit(),
          ),
        ],
        child: const SplashScreen(),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 2));
    final isFirstTime = StorageService.getBool('first_time') ?? true;
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isFirstTime 
            ? const OnboardingScreen() 
            : const HomeScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.psychology,
              size: 80,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'FocusFlow',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Stay Focused, Stay Productive',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
