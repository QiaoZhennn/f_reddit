import 'dart:io';

import 'package:f_reddit/core/constants/constants.dart';
import 'package:f_reddit/core/providers/firebase_providers.dart';
import 'package:f_reddit/core/providers/storage_repository_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/failures.dart';
import '../../../core/utils.dart';
import '../../../model/community_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../repository/community_repository.dart';

final userCommunitiesProvider = StreamProvider((ref) {
  final communityController = ref.watch(communityControllerProvider.notifier);
  return communityController.getUserCommunities();
});

final communityControllerProvider =
    StateNotifierProvider<CommunityController, bool>((ref) {
  final communityReposity = ref.watch(communityRepositoryProvider);
  final storageReposity = ref.watch(storageRepositoryProvider);
  return CommunityController(communityReposity, ref, storageReposity);
});

final getCommunityByNameProvider = StreamProvider.family((ref, String name) {
  return ref.watch(communityControllerProvider.notifier).getCommunity(name);
});

final searchCommunityProvider = StreamProvider.family((ref, String query) {
  return ref.watch(communityControllerProvider.notifier).searchCommunity(query);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityReposity _communityReposity;
  final Ref _ref;
  final StorageRepository _storageRepository;

  CommunityController(
      this._communityReposity, this._ref, this._storageRepository)
      : super(false);

  void createCommunity(String name, BuildContext context) async {
    state = true;
    final uid = _ref.read(userProvider)?.uid ?? '';
    Community community = Community(
      id: name,
      name: name,
      banner: Constants.bannerDefault,
      avatar: Constants.avatarDefault,
      members: [uid],
      mods: [uid],
    );
    final res = await _communityReposity.createCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Community created");
      Routemaster.of(context).pop();
    });
  }

  void joinCommunity(Community community, BuildContext context) async {
    final uid = _ref.read(userProvider)!.uid;
    Either<Failure, void> res;
    if (community.members.contains(uid)) {
      res = await _communityReposity.leaveCommunity(community.name, uid);
      return;
    } else {
      res = await _communityReposity.joinCommunity(community.name, uid);
    }
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (community.members.contains(uid)) {
        showSnackBar(context, 'Left ${community.name}');
      } else {
        showSnackBar(context, 'Joined ${community.name}');
      }
    });
  }

  Stream<List<Community>> getUserCommunities() {
    final String uid = _ref.read(userProvider)!.uid;
    return _communityReposity.getUserCommunities(uid);
  }

  Stream<Community> getCommunity(String name) {
    return _communityReposity.getCommunity(name);
  }

  void editCommunity(File? profileFile, File? bannerFile, BuildContext context,
      Community community) async {
    state = true;
    if (profileFile != null) {
      final res = await _storageRepository.storeFile(
          'communities/profile', community.name, profileFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => community = community.copyWith(avatar: r));
    }
    if (bannerFile != null) {
      final res = await _storageRepository.storeFile(
          'communities/banner', community.name, bannerFile);
      res.fold((l) => showSnackBar(context, l.message),
          (r) => community = community.copyWith(banner: r));
    }

    final res = await _communityReposity.editCommunity(community);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, "Community edited successfully");
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Community>> searchCommunity(String query) {
    return _communityReposity.searchCommunity(query);
  }

  void addMods(
      String communityName, List<String> uids, BuildContext context) async {
    final res = await _communityReposity.addMods(communityName, uids);
    res.fold((l) => showSnackBar(context, l.message),
        (r) => Routemaster.of(context).pop());
  }
}
