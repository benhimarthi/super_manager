import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:super_manager/core/errors/custom.exception.dart';
import 'package:super_manager/features/authentication/data/models/user.model.dart';

abstract class AuthenticationRemoteDataSource {
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String id);

  Future<UserModel> getUserById(String id);
  Future<List<UserModel>> getUsers(String creatorId);
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> loginWithGoogle();
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<void> updateMailAddress(String email);
}

class AuthenticationRemoteDataSourceImpl
    implements AuthenticationRemoteDataSource {
  final auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  AuthenticationRemoteDataSourceImpl(
    this._auth,
    this._firestore,
    this._googleSignIn,
  );

  @override
  Future<void> createUser(UserModel user) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: user.email,
        password: user.password,
      );
      final createdUser = user.copyWith(id: credential.user!.uid);
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(createdUser.toMap());
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toMap());
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection('users').doc(id).delete();
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<UserModel> getUserById(String id) async {
    try {
      final snapshot = await _firestore.collection('users').doc(id).get();
      return UserModel.fromMap(snapshot.data()!);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<UserModel>> getUsers(String creatorId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('createdBy', isEqualTo: creatorId)
          .get();
      return snapshot.docs.map((e) => UserModel.fromMap(e.data())).toList();
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await getUserById(credential.user!.uid);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      final googleUser = null; //await _googleSignIn.signIn();
      if (googleUser == null) {
        throw const ServerException(
          message: 'Google sign-in was cancelled',
          statusCode: 400,
        );
      }
      final googleAuth = await googleUser.authentication;
      final credential = auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      return await getUserById(userCredential.user!.uid);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> updateMailAddress(String email) async {
    try {
      await _auth.currentUser!.verifyBeforeUpdateEmail(email);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
