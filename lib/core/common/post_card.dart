import 'package:any_link_preview/any_link_preview.dart';
import 'package:f_reddit/features/community/controller/community_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/post/controller/post_controller.dart';
import '../../model/post.dart';
import '../../theme/palette.dart';
import '../constants/constants.dart';
import 'error_text.dart';
import 'loader.dart';

class PostCard extends ConsumerWidget {
  const PostCard(this.post, {super.key});
  final Post post;

  void deletePost(BuildContext context, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(context, post);
  }

  void upvotePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).upvote(post);
  }

  void downvotePost(WidgetRef ref) {
    ref.read(postControllerProvider.notifier).downvote(post);
  }

  void awardPost(BuildContext context, WidgetRef ref, String award) {
    ref.read(postControllerProvider.notifier).awardPost(context, post, award);
  }

  void navigateToUser(BuildContext context) {
    Routemaster.of(context).push('/u/${post.uid}');
  }

  void navigateToCommunity(BuildContext context) {
    Routemaster.of(context).push('/r/${post.communityName}');
  }

  void navigateToComments(BuildContext context) {
    Routemaster.of(context).push('/post/${post.id}/comments');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
    final isGuest = !user.isAuthenticated;
    return Column(
      children: [
        Container(
          decoration:
              BoxDecoration(color: currentTheme.drawerTheme.backgroundColor),
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(children: [
            Expanded(
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
                            .copyWith(right: 0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: () => navigateToCommunity(context),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          post.communityProfilePic),
                                      radius: 16,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(children: [
                                      Text('r/${post.communityName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      GestureDetector(
                                        onTap: () => navigateToUser(context),
                                        child: Text('u/${post.username}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                            )),
                                      ),
                                    ]),
                                  ),
                                ],
                              ),
                              if (post.uid == user.uid)
                                IconButton(
                                    onPressed: () => deletePost(context, ref),
                                    icon:
                                        Icon(Icons.delete, color: Colors.red)),
                            ],
                          ),
                          if (post.awards.isNotEmpty) ...[
                            const SizedBox(
                              height: 5,
                            ),
                            SizedBox(
                                height: 25,
                                child: ListView.builder(
                                  itemBuilder: (context, index) {
                                    final award = post.awards[index];
                                    return Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child:
                                          Image.asset(Constants.awards[award]!),
                                    );
                                  },
                                  scrollDirection: Axis.horizontal,
                                  itemCount: post.awards.length,
                                )),
                          ],
                          Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              post.title,
                              style: const TextStyle(
                                  fontSize: 19, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isTypeImage)
                            Container(
                              height: MediaQuery.of(context).size.height * 0.35,
                              width: double.infinity,
                              child: Image.network(
                                post.link!,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (isTypeLink)
                            Container(
                              height: 150,
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: AnyLinkPreview(
                                displayDirection:
                                    UIDirection.uiDirectionHorizontal,
                                link: post.link!,
                              ),
                            )
                          else if (isTypeText)
                            Container(
                              alignment: Alignment.bottomLeft,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                post.description!,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () => upvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_up,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid)
                                            ? Palette.redColor
                                            : Colors.grey,
                                      )),
                                  Text(
                                    '${post.upvotes.length - post.downvotes.length == 0 ? 'Vote' : post.upvotes.length - post.downvotes.length}',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                  IconButton(
                                      onPressed: isGuest
                                          ? () {}
                                          : () => downvotePost(ref),
                                      icon: Icon(
                                        Icons.thumb_down,
                                        size: 30,
                                        color: post.downvotes.contains(user.uid)
                                            ? Palette.blueColor
                                            : Colors.grey,
                                      )),
                                ],
                              ),
                              Row(
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                          onPressed: () =>
                                              navigateToComments(context),
                                          icon: const Icon(
                                            Icons.comment,
                                            size: 30,
                                            color: Colors.grey,
                                          )),
                                      Text(
                                        '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              ref
                                  .watch(getCommunityByNameProvider(
                                      post.communityName))
                                  .when(
                                      data: (data) {
                                        if (data.mods.contains(user.uid)) {
                                          return IconButton(
                                              onPressed: isGuest
                                                  ? () {}
                                                  : () =>
                                                      deletePost(context, ref),
                                              icon: const Icon(
                                                Icons.admin_panel_settings,
                                                size: 30,
                                                color: Colors.grey,
                                              ));
                                        } else {
                                          return SizedBox();
                                        }
                                      },
                                      error: (error, stackTrace) =>
                                          ErrorText(error: error.toString()),
                                      loading: () => const Loader()),
                              IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) => Dialog(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(20),
                                                  child: GridView.builder(
                                                      shrinkWrap: true,
                                                      gridDelegate:
                                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                                              crossAxisCount:
                                                                  4),
                                                      itemCount:
                                                          user.awards.length,
                                                      itemBuilder:
                                                          (context, index) {
                                                        final award =
                                                            user.awards[index];
                                                        return isGuest
                                                            ? null
                                                            : GestureDetector(
                                                                onTap: () =>
                                                                    awardPost(
                                                                        context,
                                                                        ref,
                                                                        award),
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Image.asset(
                                                                      Constants
                                                                              .awards[
                                                                          award]!),
                                                                ),
                                                              );
                                                      })),
                                            ));
                                  },
                                  icon:
                                      const Icon(Icons.card_giftcard_outlined)),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
            )
          ]),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}
