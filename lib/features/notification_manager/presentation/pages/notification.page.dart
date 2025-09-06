import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:super_manager/core/notification_service/notification.params.dart';
import 'package:super_manager/features/notification_manager/presentation/cubit/notification.cubit.dart';
import '../../../../core/notification_service/flutter.local.notifications.plugin.dart';
import '../../domain/entities/notification.dart';
import '../cubit/notification.state.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  late List<Notifications> myNotifications;
  @override
  void initState() {
    super.initState();
    myNotifications = [];
    context.read<NotificationCubit>().loadNotifications();
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'default_channel', // Use the actual channel ID you created
          '', // Leave the channel name empty here, as it cannot be changed here
          importance: Importance.high,
          priority: Priority.high,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'Notification Payload',
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NotificationCubit, NotificationState>(
      listener: (context, state) {
        if (state is NotificationManagerLoaded) {
          setState(() {
            myNotifications = state.notifications;
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Notifications')),
          body: SingleChildScrollView(
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: ListView(
                children: List.generate(myNotifications.length, (index) {
                  return notificationItem(myNotifications[index]);
                }),
              ),
            ),
          ),
        );
      },
    );
  }

  notificationItem(Notifications notif) {
    String time = "${notif.sentAt.hour} : ${notif.sentAt.minute}";
    return ListTile(
      title: Text(
        notif.title,
        style: TextStyle(
          color: notif.status == NotificationStatus.read.name
              ? Colors.grey
              : Theme.of(context).primaryColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(notif.body),
      trailing: SizedBox(
        width: 50,
        height: 20,
        //color: Colors.amber,
        child: Center(
          child: Text(
            time,
            style: TextStyle(
              color: notif.status == NotificationStatus.read.name
                  ? Colors.grey
                  : Colors.amber,
            ),
          ),
        ),
      ),
      leading: CircleAvatar(),
    );
  }
}
