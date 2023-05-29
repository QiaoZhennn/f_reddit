import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_reddit/core/constants/firebase_constants.dart';
import 'package:f_reddit/core/providers/firebase_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../../core/failures.dart';
import '../../../core/type_defs.dart';
import '../../../model/community_model.dart';

final communityRepositoryProvider = Provider<CommunityReposity>((ref) {
  return CommunityReposity(ref.watch(firestoreProvider));
});

class CommunityReposity {
  final FirebaseFirestore _firestore;

  CommunityReposity(this._firestore);

  FutureVoid createCommunity(Community community) async {
    try {
      var communityDoc = await _communities.doc(community.name).get();
      if (communityDoc.exists) {
        throw Exception("Community already exists");
      }
      return right(_communities.doc(community.name).set(community.toMap()));
    } on FirebaseException catch (e) {
      throw e.message!;
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  CollectionReference get _communities =>
      _firestore.collection(FirebaseConstants.commentsCollection);
}
