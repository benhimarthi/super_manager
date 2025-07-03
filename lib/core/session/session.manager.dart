import 'package:hive_flutter/hive_flutter.dart';
import '../../features/authentication/data/models/user.model.dart';
import '../../features/authentication/domain/entities/user.dart';

class SessionManager {
  static final Box _sessionBox = Hive.box('authenticationBox');

  static void saveUserSession(User user) {
    _sessionBox.put('currentUser', (user as UserModel).toMap());
  }

  static User? getUserSession() {
    final userData = _sessionBox.get('currentUser');
    return userData != null
        ? UserModel.fromMap(Map<String, dynamic>.from(userData))
        : null;
  }

  static void clearUserSession() {
    _sessionBox.delete('currentUser');
  }
}
