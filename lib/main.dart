import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/lead_provider.dart';
import 'screens/home_screen.dart';
import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() {
  runApp(const LeadManagementApp());
}

class LeadManagementApp extends StatelessWidget {
  const LeadManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LeadProvider()),
      ],
      child: Consumer<LeadProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            title: 'Lead Management',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const HomeScreen(), // TEMP: Skip WelcomeScreen to test iOS
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
