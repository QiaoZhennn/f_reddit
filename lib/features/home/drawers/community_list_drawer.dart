import 'package:f_reddit/core/common/loader.dart';
import 'package:f_reddit/core/common/sign_in_button.dart';
import 'package:f_reddit/features/community/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../../core/common/error_text.dart';
import '../../../model/community_model.dart';
import '../../auth/controller/auth_controller.dart';

class CommunityListDrawer extends ConsumerWidget {
  const CommunityListDrawer({super.key});

  void navigateToCreateCommunity(BuildContext context) {
    Routemaster.of(context).push('/create-community');
  }

  void navigateToCommunity(BuildContext context, Community community) {
    Routemaster.of(context).push('/r/${community.name}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;

    return Drawer(
      child: SafeArea(
          child: Column(
        children: [
          isGuest
              ? const SignInButton()
              : ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Create a community'),
                  onTap: () => navigateToCreateCommunity(context),
                ),
          if (!isGuest)
            ref.watch(userCommunitiesProvider).when(
                data: (data) => Expanded(
                      child: ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, index) {
                          final community = data[index];
                          return ListTile(
                              leading: CircleAvatar(
                                backgroundImage: NetworkImage(community.avatar),
                              ),
                              title: Text(community.name),
                              onTap: () =>
                                  navigateToCommunity(context, community));
                        },
                      ),
                    ),
                error: (error, stackTrace) => ErrorText(
                      error: error.toString(),
                    ),
                loading: () => Loader())
        ],
      )),
    );
  }
}
