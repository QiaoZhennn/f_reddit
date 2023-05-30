import 'dart:io';

import 'package:f_reddit/core/providers/storage_repository_provider.dart';
import 'package:f_reddit/features/user_profile/repository/user_profile_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/enums.dart';
import '../../../core/utils.dart';
import '../../../model/post.dart';
import '../../../model/user_model.dart';
import '../../auth/controller/auth_controller.dart';

final userProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  final userProfileRepository = ref.watch(userProfileRepositoryProvider);
  final storageReposity = ref.watch(storageRepositoryProvider);
  return UserProfileController(userProfileRepository, ref, storageReposity);
});

final getUserPostsProvider = StreamProvider.family((ref, String uid) {
  return ref.read(userProfileControllerProvider.notifier).getUserPosts(uid);
});

class UserProfileController extends StateNotifier<bool> {
  final UserProfileRepository _userProfileRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  UserProfileController(
      this._userProfileRepository, this._ref, this._storageRepository)
      : super(false);

  void editUserProfile(File? profileFile, File? bannerFile,
      BuildContext context, String name) async {
    state = true;
    UserModel user = _ref.read(userProvider)!;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          'users/profile', user.uid, profileFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => user = user.copyWith(profile: r));
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          'users/banner', user.uid, bannerFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => user = user.copyWith(banner: r));
    }

    user = user.copyWith(name: name);
    final res = await _userProfileRepository.editProfile(user);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref.read(userProvider.notifier).update((state) => user);
      showSnackBar(context, "User Profile edited successfully");
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> getUserPosts(String uid) {
    return _userProfileRepository.getUserPosts(uid);
  }

  void updateUserKarma(UserKarma karma) async {
    UserModel user = _ref.read(userProvider)!;
    user = user.copyWith(karma: user.karma + karma.karma);
    final res = await _userProfileRepository.updateUserKarma(user);
    res.fold((l) => null,
        (r) => _ref.read(userProvider.notifier).update((state) => user));
  }
}
