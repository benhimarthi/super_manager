import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/errors/custom.exception.dart';
import '../models/user.model.dart';

abstract class AuthenticationRemoteDataSource {
  Future<UserModel> loginWithEmail(String email, String password);
  Future<UserModel> loginWithGoogle();
  Future<void> logout();
  Future<void> createUser(UserModel user);
  Future<UserModel> getUserByEmail(String email);
  Future<void> updateUser(UserModel user);
  Future<void> deleteUser(String userId);
  Future<List<UserModel>> getUsers();
}

class AuthenticationRemoteDataSrcImpl
    implements AuthenticationRemoteDataSource {
  const AuthenticationRemoteDataSrcImpl(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final snapshot = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      return UserModel.fromMap(snapshot.data()!);
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<UserModel> loginWithGoogle() async {
    try {
      /*final GoogleSignInAccount? googleUser = await GoogleSignIn().authenticate();
      if (googleUser == null) {
        throw const ServerException(
          message: "Google Sign-In failed",
          statusCode: 401,
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final snapshot = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();

      return snapshot.exists
          ? UserModel.fromMap(snapshot.data()!)
          : const UserModel.empty();*/
      return const UserModel.empty();
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<void> createUser(UserModel user) async {
    try {
      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: user.email,
            password: user.password,
          );
      await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.toMap());
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<UserModel> getUserByEmail(String email) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (snapshot.docs.isEmpty) {
        throw const ServerException(message: "User not found", statusCode: 404);
      }

      return UserModel.fromMap(snapshot.docs.first.data());
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> updateUser(UserModel user) async {
    try {
      var currentUser = await _firestore
          .collection('users')
          .where("email", isEqualTo: user.email)
          .get();
      if (currentUser.docs.isNotEmpty) {
        var target = currentUser.docs.first.id;
        await _firestore.collection("users").doc(target).update(user.toMap());
      }
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }

  @override
  Future<List<UserModel>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => UserModel.fromMap(doc.data())).toList();
    } catch (e) {
      throw ServerException(message: e.toString(), statusCode: 500);
    }
  }
}
