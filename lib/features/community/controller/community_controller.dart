import 'package:f_reddit/core/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

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
  return CommunityController(communityReposity, ref);
});

class CommunityController extends StateNotifier<bool> {
  final CommunityReposity _communityReposity;
  final Ref _ref;

  CommunityController(this._communityReposity, this._ref) : super(false);

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

  Stream<List<Community>> getUserCommunities() {
    final String uid = _ref.read(userProvider)!.uid;
    return _communityReposity.getUserCommunities(uid);
  }
}
