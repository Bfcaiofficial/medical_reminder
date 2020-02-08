import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:medical_reminder/src/features/hospitals/screens/hospital_details_screen.dart';
import 'package:medical_reminder/src/reminder_app.dart';
import 'package:url_launcher/url_launcher.dart';

class HospitalItem extends StatelessWidget {
  final String id;
  final String name;
  final String phoneNumber;
  final String address;
  final bool hasRays;
  final bool hasSurgeries;
  final Position location;
  final List<String> departments;
  final List<String> surgeries;
  final List<String> rays;

  HospitalItem({
    this.id,
    this.name,
    this.phoneNumber,
    this.address,
    this.hasRays,
    this.hasSurgeries,
    this.location,
    this.departments,
    this.rays,
    this.surgeries,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            blurRadius: 10.0,
            color: Colors.grey[200],
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Routes.sailor.navigate(HospitalDetailsScreen.routeName, params: {
                'title': name,
                'data': {
                  'name': name,
                  'address': address,
                  'phoneNumber': phoneNumber,
                  'hasRays': hasRays,
                  'hasSurgeries': hasSurgeries,
                  'location': location,
                  'departments': departments,
                  'rays': rays,
                  'surgeries': surgeries,
                },
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: LayoutBuilder(
                builder: (ctx, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        name,
                        style: Theme.of(context).textTheme.display2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        address,
                        style: Theme.of(context)
                            .textTheme
                            .display2
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Flexible(
                              child: Text(
                            phoneNumber,
                            textDirection: TextDirection.ltr,
                            style:
                                Theme.of(context).textTheme.display2.copyWith(
                                      color: Colors.grey[600],
                                    ),
                          )),
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: InkWell(
                              splashColor: Colors.grey,
                              onTap: () {
                                print('calling number: $phoneNumber');
                                _callHospitalNumber(context);
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.call,
                                  color: Theme.of(context).accentColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _callHospitalNumber(context) async {
    if (await canLaunch('tel://$phoneNumber')) {
      launch('tel://$phoneNumber');
    } else {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          'Could not call $phoneNumber',
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }
}
