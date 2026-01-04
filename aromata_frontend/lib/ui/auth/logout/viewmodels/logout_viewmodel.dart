import 'package:aromata_frontend/repositories/auth_repository.dart';
import 'package:aromata_frontend/utils/command.dart';
import 'package:aromata_frontend/utils/result.dart';

class LogoutViewModel{
  LogoutViewModel({
    required AuthRepository authRepository,
  }): _authRepository = authRepository {
    logout = Command0(_logout);
  }

  final AuthRepository _authRepository;
  late Command0 logout;

  Future<Result> _logout() async {
    final result = await _authRepository.signOut();

    switch (result) {
      case Ok():
        return Result.ok(null);
      case Error():
        return Result.error(result.error);
    }
  }
}