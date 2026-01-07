import 'package:aromata_frontend/utils/result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'auth_repository.dart';

/// Supabase implementation of IAuthRepository
class SupabaseAuthRepository extends AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  String? getCurrentUserId() {
    return _supabase.auth.currentUser?.id;
  }

  @override
  String? getCurrentUserEmail() {
    return _supabase.auth.currentUser?.email;
  }

  @override
  String? getCurrentUserName() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return user.userMetadata?['name'] as String? ??
        user.email?.split('@').first;
  }

  @override
  Future<bool> isAuthenticated() async {
    return await Future.value(_supabase.auth.currentUser != null);
  }

  @override
  Future<Result<void>> signIn(String email, String password) async {
    try{
      var response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      if(response.user?.isAnonymous ?? false){
        return Result.error(Exception('User is anonymous'));
      }
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try{
          await _supabase.auth.signOut();
          return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
    
  }

  @override
  Future<Result<void>> updatePassword(String newPassword) async {
    try{
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      return Result.ok(null);
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  
}

