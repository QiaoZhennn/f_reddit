import 'package:f_reddit/features/auth/screens/login_screen.dart';
import 'package:f_reddit/router.dart';
import 'package:f_reddit/theme/palette.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'F_Reddit',
        theme: Palette.darkModeAppTheme,
        routerDelegate: RoutemasterDelegate(
          routesBuilder: (context) => loggedOutRoute,
        ),
        routeInformationParser: const RoutemasterParser());
  }
}
