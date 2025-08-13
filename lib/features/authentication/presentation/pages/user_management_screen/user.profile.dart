import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_manager/core/util/change.screen.manager.dart';
import 'package:super_manager/features/authentication/data/models/user.model.dart';
import 'package:super_manager/features/authentication/presentation/cubit/authentication.cubit.dart';
import 'package:super_manager/features/authentication/presentation/pages/login_screen/login.screen.dart';
import 'package:uuid/uuid.dart';
import '../../../../../core/session/session.manager.dart';
import '../../../../image_manager/data/models/app.image.model.dart';
import '../../../../image_manager/presentation/cubit/app.image.cubit.dart';
import '../../../../image_manager/presentation/cubit/app.image.state.dart';
import '../../../domain/entities/user.dart';
import '../../cubit/authentication.state.dart';
import '../../widgets/edit.user.dialog.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late User currentUser;
  late AppImageModel avatar;
  final _uuid = const Uuid();
  File? image;

  @override
  void initState() {
    super.initState();
    currentUser = SessionManager.getUserSession()!;
    avatar = AppImageModel.empty();
    if (currentUser.avatar.isNotEmpty && currentUser.avatar != "empty") {
      context.read<AppImageManagerCubit>().loadImages(currentUser.id);
    } else {
      avatar = AppImageModel(
        id: _uuid.v4(),
        url: "",
        entityId: currentUser.id,
        entityType: "profile",
        position: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        uploadedBy: currentUser.id,
      );
      context.read<AppImageManagerCubit>().createImage(avatar);
    }
  }

  void _onEditUser(User user) {
    showDialog(
      context: context,
      builder: (context) => EditUserDialog(user: user),
    );
  }

  updateProfileImge(String url) {
    final newAvatar = AppImageModel(
      id: _uuid.v4(),
      url: url,
      entityId: currentUser.id,
      entityType: "profile",
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      position: (avatar.position ?? 0) + 1,
      uploadedBy: currentUser.id,
    );
    context.read<AppImageManagerCubit>().createImage(newAvatar).whenComplete(
      () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Colors based on the screenshot

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text("Edit Profile"),
        actions: [
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text("${currentUser.role.name} account"),
          ),
        ],
      ),
      floatingActionButton: CircleAvatar(
        child: IconButton(
          onPressed: () {
            setState(() {
              context.read<AuthenticationCubit>().logout();
              nextScreenReplace(context, LoginScreen());
            });
          },
          icon: Icon(Icons.logout),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 1),
        child: ListView(
          children: [
            const SizedBox(height: 50),
            Center(
              child: Stack(
                children: [
                  BlocConsumer<AppImageManagerCubit, AppImageState>(
                    listener: (context, state) {
                      if (state is OpenImageFromGalerySuccessfully) {
                        setState(() {
                          image = state.imageLink;
                          updateProfileImge(image!.path);
                        });
                      }
                      if (state is GetAppImageByIdSuccessfully) {
                        if (state.image.url.isNotEmpty) {
                          image = File(state.image.url);
                        }
                      }
                      if (state is AppImageManagerLoaded) {
                        if (currentUser.avatar == "empty") {
                          final updatedUser = (currentUser as UserModel)
                              .copyWith(avatar: avatar.id);
                          context
                              .read<AuthenticationCubit>()
                              .updateUser(updatedUser)
                              .whenComplete(() {
                                setState(() {
                                  final currentUserUp =
                                      (currentUser as UserModel).copyWith(
                                        avatar: avatar.id,
                                      );
                                  SessionManager.saveUserSession(currentUserUp);
                                });
                              });
                        } else {
                          if (state.images.isNotEmpty) {
                            final toDisplay = state.images
                                .where((x) => x.url.isNotEmpty)
                                .lastOrNull;
                            if (toDisplay != null) {
                              avatar = toDisplay as AppImageModel;
                              image = File(toDisplay.url);
                            } else {
                              avatar = AppImageModel.empty();
                            }
                          }
                        }
                      }
                    },
                    builder: (context, state) {
                      return image != null
                          ? CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.white,
                              backgroundImage: FileImage(image!),
                            )
                          : const CircleAvatar(
                              radius: 54,
                              backgroundColor: Colors.white,
                            );
                    },
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          context
                              .read<AppImageManagerCubit>()
                              .openImageFromGalery('profile')
                              .whenComplete(() {
                                setState(() {});
                              });
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(width: 3),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PROFILE INFOS",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                BlocConsumer<AuthenticationCubit, AuthenticationState>(
                  listener: (context, state) {
                    if (state is UsersLoaded) {
                      setState(() {
                        //This actions is trigger right after the update of the.
                        //name or the mail adress of the current user.
                        currentUser = SessionManager.getUserSession()!;
                      });
                    }
                  },
                  builder: (context, state) {
                    return Container();
                  },
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return EditUserDialog(user: currentUser);
                      },
                    );
                  },
                  icon: Icon(Icons.edit),
                ),
              ],
            ),
            //const SizedBox(height: 50),
            listTileCustom(
              Icons.person,
              "NAME",
              currentUser.name,
              Icons.arrow_forward_ios_sharp,
              () {},
            ),
            listTileCustom(
              Icons.email,
              "EMAIL",
              currentUser.email,
              Icons.arrow_forward_ios_sharp,
              () {},
            ),
            /*listTileCustom(
              Icons.accessibility,
              "ROLE",
              currentUser.role.name,
              Icons.arrow_forward_ios_sharp,
            ),*/
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "SECURITY",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(onPressed: () {}, icon: Icon(Icons.edit)),
              ],
            ),
            listTileCustom(
              Icons.password_sharp,
              "PASSWORD",
              "change your password",
              Icons.arrow_forward_ios,
              () {},
            ),
            listTileCustom(
              Icons.lock,
              "ACTIVATE MFA",
              "Activate the mfa",
              Icons.arrow_forward_ios,
              () {},
            ),
          ],
        ),
      ),
    );
  }

  listTileCustom(leadingIcon, title, subtitle, trailingIcon, Function onTap) {
    return GestureDetector(
      onTap: () {
        onTap;
      },
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white)),
        leading: Icon(
          leadingIcon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
        trailing: Icon(
          trailingIcon,
          size: 16,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
