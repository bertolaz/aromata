import 'package:aromata_frontend/routing/router.dart';
import 'package:aromata_frontend/ui/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  try {
    await dotenv.load(fileName: '.env');
    final supabaseUrl = dotenv.get('SUPABASE_URL');
    final supabaseAnonKey = dotenv.get('SUPABASE_ANON_KEY');
    
    if (supabaseAnonKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
      );
      debugPrint('Supabase initialized: $supabaseUrl');
    } else {
      debugPrint('Warning: SUPABASE_ANON_KEY not set. Please set it to use Supabase.');
    }
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: createDependencies,
      child: Builder(
        builder: (context) {
          return MaterialApp.router(
            title: 'Aromata',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: router(
              context.read(),
            ),
          );
        },
      ),
    );
  }
}
