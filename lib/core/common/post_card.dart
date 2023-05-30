import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/controller/auth_controller.dart';
import '../../features/post/controller/post_controller.dart';
import '../../model/post.dart';
import '../../theme/palette.dart';
import '../constants/constants.dart';

class PostCard extends ConsumerWidget {
  const PostCard(this.post, {super.key});
  final Post post;

  void deletePost(BuildContext context, WidgetRef ref) {
    ref.read(postControllerProvider.notifier).deletePost(context, post);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isTypeImage = post.type == 'image';
    final isTypeText = post.type == 'text';
    final isTypeLink = post.type == 'link';
    final currentTheme = ref.watch(themeNotifierProvider);
    final user = ref.watch(userProvider)!;
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
                                  CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(post.communityProfilePic),
                                    radius: 16,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Column(children: [
                                      Text('r/${post.communityName}',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          )),
                                      Text('u/${post.username}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                          )),
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
                            children: [
                              Row(
                                children: [
                                  IconButton(
                                      onPressed: () {},
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
                                      onPressed: () {},
                                      icon: Icon(
                                        Icons.thumb_down,
                                        size: 30,
                                        color: post.upvotes.contains(user.uid)
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
                                          onPressed: () {},
                                          icon: Icon(
                                            Icons.comment,
                                            size: 30,
                                            color:
                                                post.upvotes.contains(user.uid)
                                                    ? Palette.redColor
                                                    : Colors.grey,
                                          )),
                                      Text(
                                        '${post.commentCount == 0 ? 'Comment' : post.commentCount}',
                                        style: const TextStyle(fontSize: 17),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ]),
                  ),
                ],
              ),
            )
          ]),
        ),
      ],
    );
  }
}
