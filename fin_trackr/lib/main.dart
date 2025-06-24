import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './screens/splash_screen.dart';
import './screens/home_screen.dart';
import './screens/filter_screen.dart';
import './screens/backup_history_screen.dart';
import './screens/export_screen.dart';
import './screens/about_screen.dart'; 

import './models/transaction_model.dart';
import './blocs/transaction/transaction_bloc.dart';
import './blocs/transaction/transaction_event.dart';
import './blocs/transaction/transaction_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "Oops! An error occurred:\n\n${details.exceptionAsString()}",
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  };

  final appDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDir.path);

  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TransactionModelAdapter());
  }

  await Hive.openBox<TransactionModel>('transactions');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode') ?? 'light';
    setState(() {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
        prefs.setString('themeMode', 'dark');
      } else {
        _themeMode = ThemeMode.light;
        prefs.setString('themeMode', 'light');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TransactionBloc()..add(LoadTransactions())),
      ],
      child: MaterialApp(
        title: 'FinTrackr',
        debugShowCheckedModeBanner: false,
        themeMode: _themeMode,
        theme: ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.white,
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFFF2F3FF), // Soft lavender
            selectedItemColor: Color(0xFF4F46E5),
            unselectedItemColor: Colors.grey,
          ),
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.indigo,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.indigo,
            foregroundColor: Colors.white,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1B1C2D),
            selectedItemColor: Color(0xFF9AA9FF),
            unselectedItemColor: Colors.grey,
          ),
        ),
        home: SplashScreen(
          onThemeToggle: _toggleTheme,
          currentThemeMode: _themeMode,
        ),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  final VoidCallback? onThemeToggle;
  final ThemeMode? currentThemeMode;

  const MainScreen({super.key, this.onThemeToggle, this.currentThemeMode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  List<TransactionModel> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().stream.listen((state) {
      if (state is TransactionLoaded) {
        setState(() => _filteredTransactions = state.transactions);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        onThemeToggle: widget.onThemeToggle,
        currentThemeMode: widget.currentThemeMode,
      ),
      const FilterScreen(),
      const BackupHistoryScreen(),
      ExportScreen(filteredTransactions: _filteredTransactions),
      const AboutScreen(),
    ];

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_alt),
            label: "Filter",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "Backup"),
          BottomNavigationBarItem(icon: Icon(Icons.download), label: "Export"),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: "About",
          ),
        ],
      ),
    );
  }
}
