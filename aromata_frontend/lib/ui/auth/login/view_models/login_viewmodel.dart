import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';

import '../../../../repositories/auth_repository.dart';
class LoginViewModel {
  final AuthRepository _authRepository;
  late Command1 login;


  LoginViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository {
    login = Command1<void, (String email, String password)>(_login);
  }


  /// Sign in with email and password
  Future<Result<void>> _login((String, String) credentials) async {
    final (email, password) = credentials;
    var response = await _authRepository.signIn(email, password);
    switch (response) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(response.error);
    }
  }
}
