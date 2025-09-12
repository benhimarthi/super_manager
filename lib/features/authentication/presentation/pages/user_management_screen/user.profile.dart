import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:super_manager/features/authentication/presentation/cubit/authentication.cubit.dart';
import 'package:super_manager/features/image_manager/presentation/widgets/profile.image.dart';
import '../../../../../core/session/session.manager.dart';
import '../../../domain/entities/user.dart';
import '../../cubit/authentication.state.dart';
import '../../widgets/edit.user.dialog.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late User currentUser;
  @override
  void initState() {
    super.initState();
    currentUser = SessionManager.getUserSession()!;
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
              context.read<AuthenticationCubit>().logout().whenComplete(() {
                GoRouter.of(context).go("/login");
              });
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
            ProfileImage(
              itemId: currentUser.id,
              entityType: "profile",
              name: currentUser.name,
              radius: 54,
              fontSize: 32,
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
