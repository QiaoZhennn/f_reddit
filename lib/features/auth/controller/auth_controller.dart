import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils.dart';
import '../../../model/user_model.dart';
import '../repository/auth_repository.dart';

// be able to change user state
final userProvider = StateProvider<UserModel?>((ref) => null);

final authControllerProvider = StateNotifierProvider<AuthController, bool>(
    (ref) => AuthController(ref.watch(authRepositoryProvider), ref));

final authStateChangeProvider = StreamProvider((ref) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.authStateChange;
});

final getUserDataProvider = StreamProvider.family((ref, String uid) {
  final authController = ref.watch(authControllerProvider.notifier);
  return authController.getUserData(uid);
});

// similar to ChangeNotifierProvider
class AuthController extends StateNotifier<bool> {
  final AuthRepository _authRepository;
  final Ref _ref;

  AuthController(this._authRepository, this._ref) : super(false);

  Stream<User?> get authStateChange => _authRepository.authStateChanges;

  void signInWithGoogle(BuildContext context) async {
    state =
        true; // this state is the thing we are listening to, initial value is false
    final user = await _authRepository.signInWithGoogle();
    // l is error, r is success
    state = false;
    user.fold(
        (l) => showSnackBar(context, l.message),
        (r) => _ref
            .read(userProvider.notifier)
            .update((state) => r)); // r is userModel
  }

  Stream<UserModel> getUserData(String uid) {
    return _authRepository.getUserData(uid);
  }
}
