import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../auth/controller/auth_controller.dart';

class UserProfileScreen extends ConsumerWidget {
  final String uid;
  const UserProfileScreen(this.uid, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ref.watch(getUserDataProvider(uid)).when(
          data: (data) => NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                      expandedHeight: 250,
                      flexibleSpace: Stack(
                        children: [
                          Positioned.fill(
                              child: Image.network(
                            data.banner,
                            fit: BoxFit.cover,
                          )),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding:
                                const EdgeInsets.all(20).copyWith(bottom: 70),
                            child: CircleAvatar(
                              backgroundImage: NetworkImage(data.profile),
                              radius: 45,
                            ),
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            padding: const EdgeInsets.all(20),
                            child: OutlinedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 25,
                                ),
                              ),
                              child: const Text('Edit Profile'),
                            ),
                          ),
                        ],
                      )),
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                        delegate: SliverChildListDelegate([
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'r/${data.name}',
                            style: const TextStyle(
                                fontSize: 19, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text('${data.karma} karmas'),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(
                        thickness: 2,
                      ),
                    ])),
                  ),
                ];
              },
              body: const Text('Displaying posts')),
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => Loader()),
    );
  }
}
