import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/golf_tracker_provider.dart';
import 'screens/home_dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SwitchSportsGolfTrackerApp());
}

class SwitchSportsGolfTrackerApp extends StatelessWidget {
  const SwitchSportsGolfTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GolfTrackerProvider()),
      ],
      child: MaterialApp(
        title: 'Switch Sports Golf Tracker',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2E7D32),
            primary: const Color(0xFF2E7D32),
            secondary: const Color(0xFF00ACC1),
          ),
          useMaterial3: true,
          cardTheme: CardTheme(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            scrolledUnderElevation: 2,
          ),
        ),
        home: const HomeDashboardScreen(),
      ),
    );
  }
}
