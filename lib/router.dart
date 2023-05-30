import 'package:f_reddit/features/community/screens/add_mods_screen.dart';
import 'package:f_reddit/features/community/screens/create_community_screen.dart';
import 'package:f_reddit/features/community/screens/mod_tools_screen.dart';
import 'package:f_reddit/features/user_profile/screens/user_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/community/screens/community_screen.dart';
import 'features/community/screens/edit_community_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/user_profile/screens/edit_profile_screen.dart';

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
  '/add-mods/:name': (route) =>
      MaterialPage(child: AddModsScreen(route.pathParameters['name']!)),
  '/u/:uid': (route) =>
      MaterialPage(child: UserProfileScreen(route.pathParameters['uid']!)),
  '/edit-user/:uid': (route) =>
      MaterialPage(child: EditProfileScreen(route.pathParameters['uid']!)),
});
