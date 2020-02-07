import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';
import './persons_list_screen.dart';
import './vaccinations_list_screen.dart';

class VaccinationsScreen extends StatelessWidget {
  static const String routeName = '/vaccinations-screen';
  LanguageProvider langProvider;
  var labelsProvider;

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

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              labelsProvider.vaccinations,
              style: Theme.of(context).textTheme.title,
            ),
            bottom: TabBar(
              unselectedLabelColor: Colors.grey[300],
              labelColor: Theme.of(context).accentColor,
              unselectedLabelStyle: Theme.of(context).textTheme.display1,
              labelStyle: Theme.of(context).textTheme.display1,
              tabs: [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    labelsProvider.persons,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    labelsProvider.vaccinationsMenu,
                  ),
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              PersonsListScreen(),
              VaccinationsListScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
