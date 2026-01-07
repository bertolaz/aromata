
import 'package:aromata_frontend/repositories/auth_repository.dart';
import 'package:aromata_frontend/utils/result.dart';
import 'package:flutter/material.dart';

final class AuthState extends ChangeNotifier{
  final AuthRepository _authRepository;

  AuthState({required AuthRepository authRepository}) : _authRepository = authRepository;

  Future<Result<void>> signIn(String email, String password) async {
    var result =  _authRepository.signIn(email, password);
    notifyListeners();
    return result;
  }
  
  Future<Result<void>> signOut() async {
    var result = await _authRepository.signOut();
    notifyListeners();
    return result;
  }

  Future<bool> isAuthenticated() async {
    return await _authRepository.isAuthenticated();
  }

  String? getCurrentUserId() {
    return _authRepository.getCurrentUserId();
  }
  
  String? getCurrentUserEmail() {
    return _authRepository.getCurrentUserEmail();
  }

  String? getCurrentUserName() {
    return _authRepository.getCurrentUserName();
  }
}