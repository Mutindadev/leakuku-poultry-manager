import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:leakuku/core/error/failures.dart';
import 'package:leakuku/core/utils/typedef.dart';
import 'package:leakuku/features/user/data/data_sources/remote.dart';
import 'package:leakuku/features/user/data/models/user.dart';

class UserRemoteDataSourseImlementation implements UserRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final userCollection = 'users';

  @override
  ResultFuture<void> createUser(UserModel userModel) async {
    try {
      await _firestore
          .collection(userCollection)
          .doc(userModel.uid)
          .set(userModel.toMap());
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Unknown error occurred',
          statusCode: e.hashCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> deleteUser(String userId) async {
    try {
      await _firestore.collection(userCollection).doc(userId).delete();
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Unknown error occurred',
          statusCode: e.hashCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<List<UserModel>> readAllUsers() async {
    try {
      final querySnapshot = await _firestore.collection(userCollection).get();

      final users = querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      return Right(users);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Unknown error occurred',
          statusCode: e.hashCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<UserModel> readUser(String userId) async {
    try {
      final docSnapshot =
          await _firestore.collection(userCollection).doc(userId).get();

      if (!docSnapshot.exists) {
        return Left(ServerFailure(message: 'User not found', statusCode: 404));
      }

      final user = UserModel.fromMap(docSnapshot.data()!);
      return Right(user);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Unknown error occurred',
          statusCode: e.hashCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }

  @override
  ResultFuture<void> updateUser(DataMap updateData) async {
    try {
      // Extract userId from updateData
      final userId = updateData['id'] as String?;

      if (userId == null) {
        return Left(
          ServerFailure(
            message: 'User ID is required for update',
            statusCode: 400,
          ),
        );
      }

      // Remove id from updateData to avoid updating the document ID
      final dataToUpdate = Map<String, dynamic>.from(updateData);
      dataToUpdate.remove('id');

      // Add timestamp for when the update occurred
      dataToUpdate['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(userCollection)
          .doc(userId)
          .update(dataToUpdate);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
        ServerFailure(
          message: e.message ?? 'Unknown error occurred',
          statusCode: e.hashCode,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString(), statusCode: 500));
    }
  }
}
