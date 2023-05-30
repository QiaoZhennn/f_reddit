import 'dart:io';

import 'package:f_reddit/core/providers/storage_repository_provider.dart';
import 'package:f_reddit/features/post/repository/post_repository.dart';
import 'package:f_reddit/model/community_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils.dart';
import '../../../model/post.dart';
import '../../auth/controller/auth_controller.dart';

final postControllerProvider =
    StateNotifierProvider<PostController, bool>((ref) {
  final postRepository = ref.watch(postRepositoryProvider);
  final storageRepository = ref.watch(storageRepositoryProvider);
  return PostController(postRepository, ref, storageRepository);
});

final userPostsProvider =
    StreamProvider.family((ref, List<Community> communities) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchUserPosts(communities);
});

class PostController extends StateNotifier<bool> {
  final PostRepository _postRepository;
  final Ref _ref;
  final StorageRepository _storageRepository;

  PostController(this._postRepository, this._ref, this._storageRepository)
      : super(false);

  void shareTextPost(BuildContext context, String title,
      Community selectedCommunity, String description) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      description: description,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      uid: user.uid,
      username: user.name,
      type: 'text',
      createdAt: DateTime.now(),
      upvotes: [],
      downvotes: [],
      awards: [],
      commentCount: 0,
    );
    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareLinkPost(BuildContext context, String title,
      Community selectedCommunity, String link) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;
    final Post post = Post(
      id: postId,
      title: title,
      link: link,
      communityName: selectedCommunity.name,
      communityProfilePic: selectedCommunity.avatar,
      uid: user.uid,
      username: user.name,
      type: 'link',
      createdAt: DateTime.now(),
      upvotes: [],
      downvotes: [],
      awards: [],
      commentCount: 0,
    );
    final res = await _postRepository.addPost(post);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost(BuildContext context, String title,
      Community selectedCommunity, File? file) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
        'posts/${selectedCommunity.name}', postId, file);
    imageRes.fold((l) => showSnackBar(context, l.message), (r) async {
      final Post post = Post(
        id: postId,
        title: title,
        link: r,
        communityName: selectedCommunity.name,
        communityProfilePic: selectedCommunity.avatar,
        uid: user.uid,
        username: user.name,
        type: 'image',
        createdAt: DateTime.now(),
        upvotes: [],
        downvotes: [],
        awards: [],
        commentCount: 0,
      );
      final res = await _postRepository.addPost(post);
      state = false;
      res.fold((l) => showSnackBar(context, l.message), (r) {
        showSnackBar(context, 'Post successfully');
        Routemaster.of(context).pop();
      });
    });
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    if (communities.isNotEmpty) {
      return _postRepository.fetchUserPosts(communities);
    }
    return Stream.value([]);
  }

  void deletePost(BuildContext context, Post post) async {
    final res = await _postRepository.deletePost(post);
    res.fold((l) => null, (r) => showSnackBar(context, 'Post deleted'));
  }

  void upvote(Post post) {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.upvote(post, uid);
  }

  void downvote(Post post) {
    final uid = _ref.read(userProvider)!.uid;
    _postRepository.downvote(post, uid);
  }
}
