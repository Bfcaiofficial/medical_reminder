import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../providers/vaccinations_provider.dart';
import './../widgets/vaccinations_item.dart';
import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';
import './../models/vaccination.dart';

class VaccinationsListScreen extends StatefulWidget {
  @override
  _VaccinationsListScreenState createState() => _VaccinationsListScreenState();
}

class _VaccinationsListScreenState extends State<VaccinationsListScreen> {
  VaccinationsProvider vaccinationsProvider;

  List<Vaccination> _searchedVaccinations = [];

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

    vaccinationsProvider =
        Provider.of<VaccinationsProvider>(context, listen: false);

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: vaccinationsProvider.isVaccinationsDataLoaded
          ? _displayListOfVaccinations(context)
          : FutureBuilder<bool>(
              future: vaccinationsProvider.refreshVaccinationsList(),
              builder: (ctx, AsyncSnapshot<bool> snapshot) {
                if (snapshot.hasData) {
                  _searchedVaccinations = vaccinationsProvider.vaccinationList;
                  return _displayListOfVaccinations(context);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
    );
  }

  Widget _displayListOfVaccinations(context) {
    if (!isSearching) {
      _searchedVaccinations = vaccinationsProvider.vaccinationList;
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
                    return VaccinationsItem(
                      name: _searchedVaccinations[index].name,
                      describtion: _searchedVaccinations[index].describtion,
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
            hintText: labelsProvider.enterVaccinationName,
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
      _searchedVaccinations = vaccinationsProvider.vaccinationList;
      setState(() {});
      return;
    }

    print('Searching For: $vaccinationName');

    vaccinationName = vaccinationName.trim().toLowerCase();

    _searchedVaccinations =
        vaccinationsProvider.vaccinationList.where((vaccination) {
      return vaccination.name.toLowerCase().contains(vaccinationName) ||
          vaccinationName.contains(vaccination.name.toLowerCase()) ||
          vaccination.describtion.toLowerCase().contains(vaccinationName) ||
          vaccinationName.contains(vaccination.describtion.toLowerCase());
    }).toList();
    print(_searchedVaccinations);
    setState(() {
      isSearching = true;
    });
  }
}
