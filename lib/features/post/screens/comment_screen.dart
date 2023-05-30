import 'package:f_reddit/features/post/controller/post_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/common/error_text.dart';
import '../../../core/common/loader.dart';
import '../../../core/common/post_card.dart';
import '../../../model/post.dart';
import '../widgets/comment_card.dart';

class CommentScreen extends ConsumerStatefulWidget {
  final String postId;
  const CommentScreen(this.postId, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CommentScreenState();
}

class _CommentScreenState extends ConsumerState<CommentScreen> {
  final commentController = TextEditingController();

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  void addComment(Post post) {
    ref
        .read(postControllerProvider.notifier)
        .addComment(context, commentController.text.trim(), post);
    setState(() {
      commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: ref.watch(getPostByIdProvider(widget.postId)).when(
          data: (data) {
            return Column(
              children: [
                PostCard(data),
                TextField(
                  onSubmitted: (value) => addComment(data),
                  controller: commentController,
                  decoration: const InputDecoration(
                      hintText: 'What are your thoughts',
                      filled: true,
                      border: InputBorder.none),
                ),
                ref.watch(fetchComentsOfPostProvider(widget.postId)).when(
                    data: (data) => Expanded(
                          child: ListView.builder(
                              itemCount: data.length,
                              itemBuilder: (context, index) {
                                return CommentCard(data[index]);
                              }),
                        ),
                    error: (error, stackTrace) {
                      if (kDebugMode) print(error.toString());
                      return ErrorText(error: error.toString());
                    },
                    loading: () => const Loader())
              ],
            );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader()),
    );
  }
}
