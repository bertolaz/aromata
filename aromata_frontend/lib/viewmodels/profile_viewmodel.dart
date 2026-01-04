import '../repositories/auth_repository.dart';
import 'base_viewmodel.dart';

class ProfileViewModel extends BaseViewModel {
  final int bookCount;
  final int recipeCount;
  final IAuthRepository _authRepository;

  ProfileViewModel({
    required this.bookCount,
    required this.recipeCount,
    required IAuthRepository authRepository,
  }) : _authRepository = authRepository;

  String getUserName() {
    return _authRepository.getCurrentUserName() ?? 'User';
  }

  String getUserEmail() {
    return _authRepository.getCurrentUserEmail() ?? 'user@example.com';
  }

  /// Sign out
  Future<bool> signOut() async {
    final result = await execute(() async {
      await _authRepository.signOut();
      return true;
    });
    return result ?? false;
  }
}

