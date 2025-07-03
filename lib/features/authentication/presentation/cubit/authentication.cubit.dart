import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/session/session.manager.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/create.user.dart';
import '../../domain/usecases/delete.user.dart';
import '../../domain/usecases/get.current.user.dart';
import '../../domain/usecases/get.users.dart';
import '../../domain/usecases/login.user.dart';
import '../../domain/usecases/login.with.google.dart';
import '../../domain/usecases/logout.user.dart';
import '../../domain/usecases/update.user.dart';
import 'authentication.state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required LoginWithGoogle loginWithGoogle,
    required LoginUser loginUser,
    required CreateUser createUser,
    required GetUsers getUsers,
    required UpdateUser updateUser,
    required LogoutUser logoutUser,
    required DeleteUser deleteUser,
    required GetCurrentUser getCurrentUser,
  }) : _loginWithGoogle = loginWithGoogle,
       _loginUser = loginUser,
       _createUser = createUser,
       _getUsers = getUsers,
       _updateUser = updateUser,
       _logoutUser = logoutUser,
       _deleteUser = deleteUser,
       _getCurrentUser = getCurrentUser,
       super(const AuthenticationInitial());

  final LoginWithGoogle _loginWithGoogle;
  final CreateUser _createUser;
  final GetUsers _getUsers;
  final LoginUser _loginUser;
  final UpdateUser _updateUser;
  final LogoutUser _logoutUser;
  final DeleteUser _deleteUser;
  final GetCurrentUser _getCurrentUser;

  Future<void> loginWithEmail(String email, String password) async {
    emit(const AuthenticationLoading());

    final result = await _loginUser(
      LoginUserParams(email: email, password: password),
    );

    result.fold((failure) => _handleFailure(failure), (user) {
      SessionManager.saveUserSession(user);
      emit(UserAuthenticated(user));
    });
  }

  Future<void> loginWithGoogle() async {
    emit(const AuthenticationLoading());

    final result = await _loginWithGoogle();

    result.fold(
      (failure) => _handleFailure(failure),
      (user) => emit(UserAuthenticated(user)),
    );
  }

  Future<void> createUser({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    emit(const AuthenticationLoading());

    final connectivityResult = await Connectivity().checkConnectivity();
    final result = await _createUser(
      CreateUserParams(
        name: name,
        email: email,
        password: password,
        role: role,
      ),
    );

    result.fold((failure) => emit(AuthenticationError(failure.errorMessage)), (
      _,
    ) {
      if (connectivityResult == ConnectivityResult.none) {
        emit(const AuthenticationOfflinePending());
      } else {
        emit(const UserCreated());
        fetchUsers();
      }
    });
  }

  /*Future<void> loginUser({
    required String email,
    required String password,
  }) async {
    emit(const AuthenticationLoading());

    final connectivityResult = await Connectivity().checkConnectivity();
    final result =
        await _loginUser(LoginUserParams(email: email, password: ''));

    result.fold(
      (failure) => emit(AuthenticationError(failure.errorMessage)),
      (user) {
        if (connectivityResult == ConnectivityResult.none) {
          emit(const AuthenticationOfflinePending());
        } else {
          emit(UserAuthenticated(user));
        }
      },
    );
  }*/

  Future<void> updateUser(User user) async {
    emit(const AuthenticationLoading());

    final connectivityResult = await Connectivity().checkConnectivity();
    final result = await _updateUser(user);

    result.fold((failure) => emit(AuthenticationError(failure.errorMessage)), (
      _,
    ) {
      if (connectivityResult == ConnectivityResult.none) {
        emit(const AuthenticationOfflinePending());
      } else {
        emit(const UserUpdated());
        fetchUsers();
      }
    });
  }

  Future<void> deleteUser(String userId) async {
    emit(const AuthenticationLoading());

    final connectivityResult = await Connectivity().checkConnectivity();
    final result = await _deleteUser(userId);

    result.fold((failure) => _handleFailure(failure), (_) {
      if (connectivityResult == ConnectivityResult.none) {
        emit(const AuthenticationOfflinePending());
      } else {
        emit(const UserDeleted());
        fetchUsers();
      }
    });
  }

  Future<void> fetchUsers() async {
    emit(const AuthenticationLoading());

    final result = await _getUsers();

    result.fold(
      (failure) => _handleFailure(failure),
      (users) => emit(UsersLoaded(users)),
    );
  }

  Future<void> getCurrentUser() async {
    final user = SessionManager.getUserSession();
    if (user != null) {
      emit(UserAuthenticated(user));
    } else {
      final result = await _getCurrentUser();
      result.fold((failure) => _handleFailure(failure), (user) {
        SessionManager.saveUserSession(user);
        emit(UserAuthenticated(user));
      });
    }
  }

  Future<void> logout() async {
    await _logoutUser();
    SessionManager.clearUserSession();
    emit(const AuthenticationInitial());
  }

  void _handleFailure(Failure failure) {
    emit(AuthenticationError(failure.errorMessage));
  }
}
