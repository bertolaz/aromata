import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_screen.dart';
import 'main_navigation_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final SupabaseClient _supabase = Supabase.instance.client;
  User? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuth();
    _supabase.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedIn || event == AuthChangeEvent.tokenRefreshed) {
        setState(() {
          _user = data.session?.user;
        });
      } else if (event == AuthChangeEvent.signedOut) {
        setState(() {
          _user = null;
        });
      }
    });
  }

  Future<void> _checkAuth() async {
    try {
      final session = _supabase.auth.currentSession;
      setState(() {
        _user = session?.user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (_user == null) {
      return const AuthScreen();
    }

    return const MainNavigationScreen();
  }
}

