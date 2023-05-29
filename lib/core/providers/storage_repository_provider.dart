import 'dart:io';

import 'package:f_reddit/core/failures.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../type_defs.dart';
import 'firebase_providers.dart';

final storageRepositoryProvider =
    Provider((ref) => StorageRepository(ref.watch(storageProvider)));

class StorageRepository {
  final FirebaseStorage _firebaseStorage;

  StorageRepository(this._firebaseStorage);
  FutureEither<String> storeFile(String path, String id, File? file) async {
    try {
      final ref = _firebaseStorage.ref().child(path).child(id);
      UploadTask uploadTask = ref.putFile(file!);
      final snapshot = await uploadTask;
      return right(await snapshot.ref.getDownloadURL());
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
