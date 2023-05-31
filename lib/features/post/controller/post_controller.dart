import 'dart:io';
import 'dart:typed_data';

import 'package:f_reddit/core/enums.dart';
import 'package:f_reddit/core/providers/storage_repository_provider.dart';
import 'package:f_reddit/features/post/repository/post_repository.dart';
import 'package:f_reddit/features/user_profile/controller/user_profile_controller.dart';
import 'package:f_reddit/model/community_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:routemaster/routemaster.dart';
import 'package:uuid/uuid.dart';

import '../../../core/utils.dart';
import '../../../model/comment_model.dart';
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

final getPostByIdProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.getPostById(postId);
});

final fetchComentsOfPostProvider = StreamProvider.family((ref, String postId) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchCommentsOfPost(postId);
});

final guestPostsProvider = StreamProvider((ref) {
  final postController = ref.watch(postControllerProvider.notifier);
  return postController.fetchGuestPosts();
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
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.textPost);
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
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.linkPost);
    state = false;
    res.fold((l) => showSnackBar(context, l.message), (r) {
      showSnackBar(context, 'Post successfully');
      Routemaster.of(context).pop();
    });
  }

  void shareImagePost(BuildContext context, String title,
      Community selectedCommunity, File? file, Uint8List? webFile) async {
    state = true;
    String postId = Uuid().v1();
    final user = _ref.read(userProvider)!;
    final imageRes = await _storageRepository.storeFile(
        'posts/${selectedCommunity.name}', postId, file, webFile);
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
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.imagePost);
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
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.deletePost);
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

  Stream<Post> getPostById(String postId) {
    return _postRepository.getPostById(postId);
  }

  void addComment(BuildContext context, String text, Post post) async {
    final user = _ref.read(userProvider)!;
    String commentId = const Uuid().v1();
    Comment comment = Comment(
      id: commentId,
      text: text,
      username: user.name,
      createdAt: DateTime.now(),
      postId: post.id,
      userProfilePic: user.profile,
    );
    final res = await _postRepository.addComment(comment);
    _ref
        .read(userProfileControllerProvider.notifier)
        .updateUserKarma(UserKarma.comment);
    res.fold((l) => showSnackBar(context, l.message), (r) => null);
  }

  Stream<List<Comment>> fetchCommentsOfPost(String postId) {
    return _postRepository.fetchCommentsOfPost(postId);
  }

  void awardPost(BuildContext context, Post post, String award) async {
    final user = _ref.read(userProvider)!;
    final res = await _postRepository.awardPost(post, award, user.uid);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      _ref
          .read(userProfileControllerProvider.notifier)
          .updateUserKarma(UserKarma.awardPost);
      _ref.read(userProvider.notifier).update((state) {
        state?.awards.remove(award);
        return state;
      });
      Routemaster.of(context).pop();
    });
  }

  Stream<List<Post>> fetchGuestPosts() {
    return _postRepository.fetchGuestPosts();
  }
}
