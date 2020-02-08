import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './../../../core/resources/labels.dart';
import './../../../core/providers/language_provider.dart';

class CustomRadioGroup extends StatefulWidget {
  final chosenType;
  final Function() onDialogDismissed;
  final Function(int) onDialogDone;

  CustomRadioGroup({
    this.chosenType,
    this.onDialogDismissed,
    this.onDialogDone,
  });

  @override
  _CustomRadioGroupState createState() => _CustomRadioGroupState();
}

class _CustomRadioGroupState extends State<CustomRadioGroup> {
  int _currentRadioValue;
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
    _currentRadioValue = widget.chosenType ?? 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

    return Container(
      height: MediaQuery.of(context).size.height * 0.31,
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
          _buildBookingTypeOption(
            title: labelsProvider.examine,
            radioValue: 1,
            context: context,
          ),
          _buildBookingTypeOption(
            title: labelsProvider.consultation,
            radioValue: 2,
            context: context,
          ),
          _buildBookingTypeOption(
            title: labelsProvider.followUp,
            radioValue: 3,
            context: context,
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
                  widget.onDialogDone(_currentRadioValue);
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
    );
  }

  Widget _buildBookingTypeOption({String title, int radioValue, context}) {
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
}
