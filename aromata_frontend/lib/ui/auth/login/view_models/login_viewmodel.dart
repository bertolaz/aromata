import 'package:aromata_frontend/services/authState.dart';
import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';

class LoginViewModel {
  final AuthState _authState;
  late Command1 login;


  LoginViewModel({required AuthState authState})
      : _authState = authState {
    login = Command1<void, (String email, String password)>(_login);
  }


  /// Sign in with email and password
  Future<Result<void>> _login((String, String) credentials) async {
    final (email, password) = credentials;
    var response = await _authState.signIn(email, password);
    switch (response) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(response.error);
    }
  }
}
