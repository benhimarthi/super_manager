import '../../features/authentication/domain/entities/user.dart';
import 'permissions.dart';

class RolePermissions {
  static const Map<UserRole, List<String>> roleMap = {
    UserRole.admin: [
      Permissions.productRead,
      Permissions.productWrite,
      Permissions.salesRead,
      Permissions.salesWrite,
      Permissions.usersRead,
      Permissions.usersWrite,
    ],
    UserRole.regular: [
      Permissions.productRead,
      Permissions.salesRead,
      Permissions.salesWrite,
    ],
  };
}
