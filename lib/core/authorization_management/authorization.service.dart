import 'package:super_manager/features/authentication/domain/entities/user.dart';

import 'role.permissions.dart';

class AuthorizationService {
  static bool hasPermission(UserRole role, String permission) {
    final allowedPermissions = RolePermissions.roleMap[role] ?? [];
    return allowedPermissions.contains(permission);
  }
}
