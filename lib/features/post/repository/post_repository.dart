import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_reddit/core/constants/firebase_constants.dart';
import 'package:f_reddit/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/failures.dart';
import '../../../core/type_defs.dart';
import '../../../model/community_model.dart';
import '../../../model/post.dart';

final postRepositoryProvider = Provider<PostRepository>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return PostRepository(firestore);
});

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository(this._firestore);

  CollectionReference get _posts =>
      _firestore.collection(FirebaseConstants.postsCollection);

  FutureVoid addPost(Post post) async {
    try {
      return right(_posts.doc(post.id).set(post.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  Stream<List<Post>> fetchUserPosts(List<Community> communities) {
    return _posts
        .where('communityName',
            whereIn: communities.map((e) => e.name).toList())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((event) => event.docs
            .map((e) => Post.fromMap(e.data() as Map<String, dynamic>))
            .toList());
  }

  FutureVoid deletePost(Post post) async {
    try {
      return right(_posts.doc(post.id).delete());
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
