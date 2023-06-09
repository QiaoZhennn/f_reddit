import 'package:f_reddit/core/constants/constants.dart';
import 'package:f_reddit/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/controller/auth_controller.dart';

class SignInButton extends ConsumerWidget {
  final bool isFromLogin;
  const SignInButton({this.isFromLogin = true, super.key});

  void signInWithGoogle(BuildContext context, WidgetRef ref) {
    ref
        .read(authControllerProvider.notifier)
        .signInWithGoogle(context, isFromLogin);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: ElevatedButton.icon(
        onPressed: () => signInWithGoogle(context, ref),
        icon: Image.asset(Constants.googlePath, width: 35),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(fontSize: 18),
        ),
        style: ElevatedButton.styleFrom(
            backgroundColor: Palette.greyColor,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            )),
      ),
    );
  }
}
