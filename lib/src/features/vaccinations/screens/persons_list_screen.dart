import 'package:flutter/material.dart';
import 'package:medical_reminder/src/features/vaccinations/widgets/add_child_dialog.dart';
import 'package:medical_reminder/src/features/vaccinations/widgets/child_item.dart';
import 'package:provider/provider.dart';

import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';
import './../models/child_data.dart';
import './../providers/vaccinations_provider.dart';

class PersonsListScreen extends StatefulWidget {
  @override
  _PersonsListScreenState createState() => _PersonsListScreenState();
}

class _PersonsListScreenState extends State<PersonsListScreen> {
  final int VACCINATION_NUMBER = 27;
  VaccinationsProvider vaccinationsProvider;

  List<ChildData> _searchedVaccinations = [];

  LanguageProvider langProvider;
  var labelsProvider;
  bool isSearching = false;

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

    vaccinationsProvider = Provider.of<VaccinationsProvider>(context);

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Stack(
        children: [
          vaccinationsProvider.isChildrenDataLoaded
              ? _displayListOfVaccinations(context)
              : FutureBuilder<bool>(
                  future: vaccinationsProvider.refreshChildrenList(),
                  builder: (ctx, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      _searchedVaccinations = vaccinationsProvider.childrenList;
                      return _displayListOfVaccinations(context);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
          Positioned(
            right: 20.0,
            bottom: 20.0,
            child: FloatingActionButton(
              onPressed: _showAddChildDataDialog,
              child: Icon((Icons.add)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _displayListOfVaccinations(context) {
    if (!isSearching) {
      _searchedVaccinations = vaccinationsProvider.childrenList;
    }
    return Column(
      children: <Widget>[
        _buildSearchField(context),
        Expanded(
          child: _searchedVaccinations.isEmpty
              ? Center(
                  child: Text(
                    labelsProvider.noResultFound,
                    style: Theme.of(context).textTheme.display2,
                  ),
                )
              : ListView.builder(
                  itemCount: _searchedVaccinations.length,
                  itemBuilder: (ctx, index) {
                    return ChildItem(
                      name: _searchedVaccinations[index].name,
                      progress: _searchedVaccinations[index].progress,
                      id: _searchedVaccinations[index].id,
                      totalNumberOfVaccinations: VACCINATION_NUMBER,
                    );
                  },
                ),
        ),
        SizedBox(
          height: 10.0,
        ),
      ],
    );
  }

  Widget _buildSearchField(context) {
    return Container(
      height: 35.0,
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 4.0,
            color: Colors.grey[300],
          ),
        ],
      ),
      child: TextField(
        style: Theme.of(context).textTheme.display2,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: labelsProvider.enterChildName,
            hintStyle: Theme.of(context)
                .textTheme
                .display1
                .copyWith(color: Colors.grey)),
        onChanged: _searchForVaccination,
        onSubmitted: _searchForVaccination,
      ),
    );
  }

  void _searchForVaccination(String vaccinationName) {
    if (vaccinationName.isEmpty) {
      _searchedVaccinations = vaccinationsProvider.childrenList;
      setState(() {});
      return;
    }

    print('Searching For: $vaccinationName');

    vaccinationName = vaccinationName.trim().toLowerCase();

    _searchedVaccinations = vaccinationsProvider.childrenList.where((child) {
      return child.name.toLowerCase().contains(vaccinationName) ||
          vaccinationName.contains(child.name.toLowerCase());
    }).toList();
    print(_searchedVaccinations);
    setState(() {
      isSearching = true;
    });
  }

  void _showAddChildDataDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              10.0,
            ),
          ),
          content: AddChildPage(),
        );
      },
    );
  }
}
