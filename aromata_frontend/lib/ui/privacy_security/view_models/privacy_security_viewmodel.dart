import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';
import '../../../repositories/auth_repository.dart';
import '../../../viewmodels/base_viewmodel.dart';

class PrivacySecurityViewModel extends BaseViewModel {
  final AuthRepository _authRepository;

  String _newPassword = '';
  String _confirmPassword = '';

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late final Command0<void> changePassword;

  PrivacySecurityViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    changePassword = Command0<void>(_changePassword);
  }

  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;

  bool get obscureNewPassword => _obscureNewPassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;

  bool get isValid {
    return _newPassword.length >= 6 && _newPassword == _confirmPassword;
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

  void toggleNewPasswordVisibility() {
    _obscureNewPassword = !_obscureNewPassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  Future<Result<void>> _changePassword() async {
    if (!isValid) {
      return Result.error(Exception('New password must be at least 6 characters and match confirmation'));
    }

    final result = await _authRepository.updatePassword(_newPassword);
    switch (result) {
      case Ok():
        // Clear form on success
        _newPassword = '';
        _confirmPassword = '';
        notifyListeners();
        return Result.ok(null);
      case Error():
        return Result.error(result.error);
    }
  }

  void reset() {
    _newPassword = '';
    _confirmPassword = '';
    clearError();
    notifyListeners();
  }
}

