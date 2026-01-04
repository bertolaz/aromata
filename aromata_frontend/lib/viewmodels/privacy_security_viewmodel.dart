import '../repositories/auth_repository.dart';
import 'base_viewmodel.dart';

class PrivacySecurityViewModel extends BaseViewModel {
  final IAuthRepository _authRepository;

  PrivacySecurityViewModel({required IAuthRepository authRepository})
      : _authRepository = authRepository;

  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;

  bool get obscureCurrentPassword => _obscureCurrentPassword;
  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool get isValid {
    return _newPassword.length >= 6 && _newPassword == _confirmPassword;
  }

  void setCurrentPassword(String value) {
    if (_currentPassword != value) {
      _currentPassword = value;
      notifyListeners();
    }
  }

  void setNewPassword(String value) {
    if (_newPassword != value) {
      _newPassword = value;
      notifyListeners();
    }
  }

  void setConfirmPassword(String value) {
    if (_confirmPassword != value) {
      _confirmPassword = value;
      notifyListeners();
    }
  }

  void toggleCurrentPasswordVisibility() {
    _obscureCurrentPassword = !_obscureCurrentPassword;
    notifyListeners();
  }

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  /// Change password
  Future<bool> changePassword() async {
    if (!isValid) {
      setError('New password must be at least 6 characters and match confirmation');
      return false;
    }

    final result = await execute(() async {
      await _authRepository.updatePassword(_newPassword);
      return true;
    });

    if (result == true) {
      // Clear form on success
      _currentPassword = '';
      _newPassword = '';
      _confirmPassword = '';
      notifyListeners();
    }

    return result ?? false;
  }

  void reset() {
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    clearError();
    notifyListeners();
  }
}

