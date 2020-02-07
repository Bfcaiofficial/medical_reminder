import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:medical_reminder/src/features/vaccinations/models/child_data.dart';
import 'package:medical_reminder/src/features/vaccinations/providers/vaccinations_provider.dart';
import 'package:provider/provider.dart';

import './../../../core/resources/labels.dart';
import './../../../core/providers/language_provider.dart';

class AddChildPage extends StatefulWidget {
  final String id;

  AddChildPage({this.id});

  @override
  _AddChildPageState createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  LanguageProvider langProvider;
  var labelsProvider;
  VaccinationsProvider childrenDataProvider;
  int _selectedGenderOption = 0;
  final birthDateFieldController = TextEditingController();
  final nameFieldController = TextEditingController();
  DateTime _chosenBirthdate;

  void _initializeLabelsProvider(context) {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);
    childrenDataProvider =
        Provider.of<VaccinationsProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider(context);

    if (widget.id != null) {
      final childData = childrenDataProvider.childrenList
          .firstWhere((child) => child.id == widget.id);
      nameFieldController.text = childData.name;
      birthDateFieldController.text =
          intl.DateFormat.yMd().format(childData.birthdate);
      _selectedGenderOption = childData.gender.toLowerCase() == 'male' ? 0 : 1;
      _chosenBirthdate = childData.birthdate;
    }

    return Directionality(
      textDirection:
          langProvider.langCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelsProvider.theName,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.black,
                    ),
              ),
              _buildNameField(context),
              SizedBox(
                height: 20.0,
              ),
              Text(
                labelsProvider.gender,
                style: Theme.of(context).textTheme.display2.copyWith(
                      color: Colors.black,
                    ),
              ),
              Row(
                children: <Widget>[
                  _buildGenderOption(
                    title: labelsProvider.male,
                    radioValue: 0,
                  ),
                  _buildGenderOption(
                    title: labelsProvider.female,
                    radioValue: 1,
                  ),
                ],
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                labelsProvider.birthDate,
                style: Theme.of(context)
                    .textTheme
                    .display2
                    .copyWith(color: Colors.black),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  _openDatePicker(context).then((chosenDate) {
                    if (chosenDate == null) {
                      birthDateFieldController.text = '';
                      return null;
                    }
                    birthDateFieldController.text =
                        intl.DateFormat.yMd().format(chosenDate);
                    setState(() {
                      _chosenBirthdate = chosenDate;
                    });
                  });
                },
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 40.0,
                  margin: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 5.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4.0,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: birthDateFieldController,
                    textAlign: TextAlign.center,
                    enabled: false,
                    style: Theme.of(context)
                        .textTheme
                        .display2
                        .copyWith(color: Colors.black),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'MM/DD/YYYY',
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 30.0,
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: RaisedButton(
                  onPressed: _saveNewChild,
                  color: Color(0xFF001737),
                  child: Text(
                    labelsProvider.save,
                    style: Theme.of(context)
                        .textTheme
                        .title
                        .copyWith(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _saveNewChild() {
    if (nameFieldController.text.isEmpty ||
        birthDateFieldController.text.isEmpty) {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          labelsProvider.fieldsMustBeFilled,
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
      return;
    }

    final newChildData = ChildData(
      id: DateTime.now().toString(),
      name: nameFieldController.text.trim(),
      gender: _selectedGenderOption == 0 ? 'Male' : 'Female',
      birthdate: _chosenBirthdate,
      progress: 0,
    );

    if (widget.id == null) {
      childrenDataProvider.addChild(
        newChildData,
      );
    } else {
      final oldChildData = childrenDataProvider.childrenList
          .firstWhere((child) => child.id == widget.id);
      childrenDataProvider.updateChildData(
          oldChildData.idOnServer, newChildData);
    }

    Navigator.of(context).pop();
  }

  Widget _buildGenderOption({String title, radioValue}) {
    return Expanded(
        child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGenderOption = radioValue;
          });
        },
        child: Row(
          children: <Widget>[
            Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .display2
                  .copyWith(color: Colors.black),
            ),
            Radio(
              value: radioValue,
              groupValue: _selectedGenderOption,
              onChanged: (newValue) {
                setState(() {
                  _selectedGenderOption = newValue;
                });
              },
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildNameField(context) {
    return Container(
      height: 35.0,
      margin: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 5.0,
      ),
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
        controller: nameFieldController,
        style: Theme.of(context).textTheme.display2,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: labelsProvider.enterChildName,
          hintStyle: Theme.of(context).textTheme.display1.copyWith(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
        ),
      ),
    );
  }

  Future<DateTime> _openDatePicker(context) {
    return showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(Duration(days: 7 * 30)),
      initialDate: DateTime.now(),
      lastDate: DateTime.now(),
      builder: (BuildContext context, Widget child) {
        return Theme(
          data: ThemeData.light().copyWith(),
          child: child,
        );
      },
    );
  }
}
