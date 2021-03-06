import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../providers/language_provider.dart';
import './../providers/notifications_provider.dart';
import './../resources/labels.dart';
import './../widgets/notifications_item.dart';

class NotificationsScreen extends StatelessWidget {
  var langProvider;
  var labelsProvider;
  NotificationProvider notificationsProvider;

  void _initializeLabelsProvider(context) {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider(context);

    notificationsProvider = Provider.of<NotificationProvider>(context);

    return Directionality(
      textDirection:
          langProvider.langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            labelsProvider.notificationsPageLabel,
            style: Theme.of(context).textTheme.title,
          ),
        ),
        body: FutureBuilder<bool>(
          future: notificationsProvider.refreshNotificationList(),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              return _displayNotificationsList();
            } else {
              return Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _displayNotificationsList() {
    final notifications = notificationsProvider.getTodayNotifications();
    return notifications.isNotEmpty
        ? ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (ctx, index) {
              return NotificationItem(
                id: notifications[index].id,
                idOnServer: notifications[index].idOnServer,
                title: notifications[index].title,
                description: notifications[index].description,
                date: notifications[index].date,
                eventType: notifications[index].eventType,
              );
            },
          )
        : Center(
            child: Icon(
              Icons.notifications_paused,
              size: 50.0,
            ),
          );
  }
}
