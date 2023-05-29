import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';
import '../repository/auth_repository.dart';

final authControllerProvider = Provider<AuthController>(
    (ref) => AuthController(ref.read(authRepositoryProvider)));

class AuthController {
  final AuthRepository _authRepository;

  AuthController(this._authRepository);

  void signInWithGoogle(BuildContext context) async {
    final user = await _authRepository.signInWithGoogle();
    // l is error, r is success
    user.fold((l) => showSnackBar(context, l.message), (r) => null);
  }
}
