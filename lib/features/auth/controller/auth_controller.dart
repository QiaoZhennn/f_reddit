import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repository/auth_repository.dart';

final authControllerProvider = Provider<AuthController>(
    (ref) => AuthController(ref.read(authRepositoryProvider)));

class AuthController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  void signInWithGoogle() {
    _authRepository.signInWithGoogle();
  }
}
