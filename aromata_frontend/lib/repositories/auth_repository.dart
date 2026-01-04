import 'package:aromata_frontend/utils/result.dart';
import 'package:flutter/foundation.dart';

/// Repository interface for authentication operations
abstract class IAuthRepository extends Listenable {
  /// Get the current authenticated user
  String? getCurrentUserId();

  /// Get the current user's email
  String? getCurrentUserEmail();

  /// Get the current user's display name
  String? getCurrentUserName();

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Sign in with email and password
  Future<Result<void>> signIn(String email, String password);

  /// Sign out the current user
  Future<Result<void>> signOut();

  /// Update user password
  Future<Result<void>> updatePassword(String newPassword);


}


