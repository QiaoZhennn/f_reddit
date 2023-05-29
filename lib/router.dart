import 'package:f_reddit/features/community/screens/create_community_screen.dart';
import 'package:f_reddit/features/community/screens/mod_tools_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/community/screens/community_screen.dart';
import 'features/community/screens/edit_community_screen.dart';
import 'features/home/screens/home_screen.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (_) => MaterialPage(child: HomeScreen()),
  '/create-community': (_) => MaterialPage(child: CreateCommunityScreen()),
  '/r/:name': (route) =>
      MaterialPage(child: CommunityScreen(route.pathParameters['name']!)),
  '/mod-tools/:name': (route) =>
      MaterialPage(child: ModToolsScreen(name: route.pathParameters['name']!)),
  '/edit-community/:name': (route) =>
      MaterialPage(child: EditCommunityScreen(route.pathParameters['name']!)),
});
