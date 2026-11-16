import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/api_service.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final apiService = ApiService();
  runApp(ShawafAiApp(apiService: apiService));
}

class ShawafAiApp extends StatelessWidget {
  final ApiService apiService;

  const ShawafAiApp({Key? key, required this.apiService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shawaf AI — Industrial Safety Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: HomeScreen(apiService: apiService),
    );
  }
}
