import 'package:flutter/material.dart';

class VaccinationRadioRow extends StatefulWidget {
  VaccinationRadioRow({
    @required this.title,
    @required this.radioValue,
    @required this.onValueChanged,
    this.isClicked,
  });

  final String title;
  final int radioValue;
  final Function(int) onValueChanged;
  bool isClicked = false;

  @override
  _VaccinationRadioRowState createState() => _VaccinationRadioRowState();
}

class _VaccinationRadioRowState extends State<VaccinationRadioRow> {
  int _groupValue;

  @override
  Widget build(BuildContext context) {
    if (widget.isClicked) {
      _groupValue = widget.radioValue;
    }

    return InkWell(
      onTap: widget.isClicked
          ? null
          : () {
              if (widget.onValueChanged(widget.radioValue)) {
                setState(() {
                  widget.isClicked = true;
                  _groupValue = widget.radioValue;
                });
              }
            },
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                blurRadius: 4.0,
                color: Colors.grey[300],
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          margin: const EdgeInsets.symmetric(
            vertical: 4.0,
            horizontal: 10.0,
          ),
          child: Row(
            children: <Widget>[
              Radio(
                activeColor: Colors.blueAccent,
                value: widget.radioValue,
                groupValue: _groupValue,
                onChanged: widget.isClicked
                    ? null
                    : (_) {
                        if (widget.onValueChanged(widget.radioValue)) {
                          setState(() {
                            widget.isClicked = true;
                            _groupValue = widget.radioValue;
                          });
                        }
                      },
              ),
              Text(
                widget.title,
                textAlign: TextAlign.end,
                style: Theme.of(context).textTheme.display2,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
