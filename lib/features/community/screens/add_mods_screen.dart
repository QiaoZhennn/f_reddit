import 'package:f_reddit/core/common/error_text.dart';
import 'package:f_reddit/features/auth/controller/auth_controller.dart';
import 'package:f_reddit/features/community/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/loader.dart';

class AddModsScreen extends ConsumerStatefulWidget {
  const AddModsScreen(this.name, {super.key});
  final String name;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddModsScreenState();
}

class _AddModsScreenState extends ConsumerState<AddModsScreen> {
  Set<String> uids = {};
  int ctr = 0;

  void addUids(String uid) {
    setState(() {
      uids.add(uid);
    });
  }

  void removeUids(String uid) {
    setState(() {
      uids.remove(uid);
    });
  }

  void saveMods() {
    ref
        .read(communityControllerProvider.notifier)
        .addMods(widget.name, uids.toList(), context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Moderators'),
        actions: [
          IconButton(
            onPressed: saveMods,
            icon: const Icon(Icons.done),
          )
        ],
      ),
      body: ref.watch(getCommunityByNameProvider(widget.name)).when(
          data: (data) => ListView.builder(
                itemCount: data.members.length,
                itemBuilder: (context, index) {
                  final member = data.members[index];
                  return ref.watch(getUserDataProvider(member)).when(
                      data: (userData) {
                        if (data.mods.contains(member) && ctr == 0) {
                          uids.add(member);
                        }
                        ctr++;
                        return CheckboxListTile(
                          value: uids.contains(userData.uid),
                          onChanged: (val) {
                            if (val!) {
                              addUids(userData.uid);
                            } else {
                              removeUids(userData.uid);
                            }
                          },
                          title: Text(userData.name),
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () => const Loader());
                },
              ),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
