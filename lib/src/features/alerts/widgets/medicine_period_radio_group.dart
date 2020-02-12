import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../../core/resources/labels.dart';
import './../../../core/providers/language_provider.dart';

class MedicinePeriodRadioGroup extends StatefulWidget {
  final int chosenPeriod;
  final int cuurentPeriod;
  final Function() onDialogDismissed;
  final Function(int, int) onDialogDone;

  MedicinePeriodRadioGroup({
    this.chosenPeriod,
    this.cuurentPeriod,
    this.onDialogDismissed,
    this.onDialogDone,
  });

  @override
  _MedicinePeriodRadioGroupState createState() =>
      _MedicinePeriodRadioGroupState();
}

class _MedicinePeriodRadioGroupState extends State<MedicinePeriodRadioGroup> {
  int _currentRadioValue;
  int _days = 0;
  var labelsProvider;

  void _initializeLabelsProvider() {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  void initState() {
    _currentRadioValue = widget.chosenPeriod ?? 1;
    _days = widget.cuurentPeriod ?? 2;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

    return Container(
      height: MediaQuery.of(context).size.height * 0.32,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Divider(
                height: 10.0,
                color: Colors.grey[700],
              ),
            ),
            _buildPeriodOption(
              title: labelsProvider.daily,
              radioValue: 1,
              context: context,
            ),
            _buildPeriodOption(
              title: labelsProvider.perSpecificPeriod,
              radioValue: 2,
              context: context,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new IconButton(
                  onPressed: _currentRadioValue == 2 ? _incrementDays : null,
                  icon: new Icon(
                    Icons.add,
                    color: _currentRadioValue == 2 ? Colors.black : Colors.grey,
                  ),
                ),
                new Text('$_days', style: Theme.of(context).textTheme.display2),
                new IconButton(
                  onPressed: _currentRadioValue == 2 ? _decrementDays : null,
                  icon: new Icon(
                    const IconData(0xe15b, fontFamily: 'MaterialIcons'),
                    color: _currentRadioValue == 2 ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                InkWell(
                  onTap: widget.onDialogDismissed,
                  child: Container(
                    margin: EdgeInsets.only(
                      left: 10.0,
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      labelsProvider.cancel,
                      style: Theme.of(context).textTheme.display1.copyWith(
                            color: Colors.red,
                          ),
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    if (_currentRadioValue == 1)
                      widget.onDialogDone(_currentRadioValue, 1);
                    else
                      widget.onDialogDone(_currentRadioValue, _days);
                  },
                  child: Container(
                    margin: EdgeInsets.only(right: 10.0),
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      labelsProvider.save,
                      style: Theme.of(context).textTheme.display1.copyWith(
                            color: Theme.of(context).accentColor,
                          ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodOption({String title, int radioValue, context}) {
    return InkWell(
      onTap: () {
        _changeCurrentSelectedValue(radioValue);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            title,
            style: Theme.of(context).textTheme.display1,
          ),
          Radio(
            value: radioValue,
            groupValue: _currentRadioValue,
            onChanged: (value) {
              setState(() {
                _currentRadioValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  void _changeCurrentSelectedValue(int newValue) {
    setState(() {
      _currentRadioValue = newValue;
    });
  }

  void _incrementDays() {
    setState(() {
      if (_days < 30) _days++;
    });
  }

  void _decrementDays() {
    setState(() {
      if (_days > 2) _days--;
    });
  }
}
