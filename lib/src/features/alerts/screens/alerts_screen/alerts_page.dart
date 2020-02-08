import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../../../core/mixins/internet_connection_status_mixin.dart';
import './../../../../core/resources/labels.dart';
import './activities_page.dart';
import './agenda_page.dart';
import './../../../../core/providers/language_provider.dart';

class AlertsPage extends StatelessWidget with InternetConnectionStatusMixin {
  static const String routeName = '/alerts_screen';
  var labelsProvider;
  var langProvider;

  @override
  Widget build(BuildContext context) {
    final appBar = _buildAppBar(context);
    checkInternetConnection().then((isConnected) {
      if (!isConnected) {
        Flushbar(
          icon: Icon(
            Icons.error,
            color: Colors.red,
          ),
          messageText: Text(
            labelsProvider.internetConnectionFailed,
            style: Theme.of(context)
                .textTheme
                .display1
                .copyWith(color: Colors.white),
          ),
          duration: Duration(seconds: 2),
        )..show(context);
      }
    });

    return Directionality(
      textDirection:
          langProvider.langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: appBar,
          body: TabBarView(
            children: <Widget>[
              AgendaPageContent(appBarHeight: appBar.preferredSize.height),
              ActivitiesPageContent(),
            ],
          ),
        ),
      ),
    );
  }

  void _initializeLabelsProvider(context) {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  PreferredSizeWidget _buildAppBar(context) {
    _initializeLabelsProvider(context);

    return AppBar(
      title: Text(
        labelsProvider.alerts,
        style: Theme.of(context).textTheme.title,
      ),
      bottom: TabBar(
        unselectedLabelColor: Colors.grey[300],
        labelColor: Theme.of(context).accentColor,
        unselectedLabelStyle: Theme.of(context).textTheme.display1,
        labelStyle: Theme.of(context).textTheme.display1,
        tabs: <Widget>[
          Tab(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                labelsProvider.agenda,
              ),
            ),
          ),
          Tab(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                labelsProvider.activities,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
