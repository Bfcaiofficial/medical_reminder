import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import './../../../core/resources/labels.dart';
import './../../../core/providers/language_provider.dart';

class HospitalDetailsScreen extends StatefulWidget {
  static final String routeName = '/hospital-details';
  final String title;
  final Map<String, dynamic> hospitalData;

  HospitalDetailsScreen({@required this.title, @required this.hospitalData});

  @override
  _HospitalDetailsScreenState createState() => _HospitalDetailsScreenState();
}

class _HospitalDetailsScreenState extends State<HospitalDetailsScreen> {
  List<String> _searchedDepartments = [];
  List<String> _searchedRays = [];
  List<String> _searchedSurgeries = [];
  var labelsProvider;
  var langProvider;

  @override
  void initState() {
    _searchedDepartments = widget.hospitalData['departments'];
    _searchedRays = widget.hospitalData['rays'];
    _searchedSurgeries = widget.hospitalData['surgeries'];
    super.initState();
  }

  void _initializeLabelsProvider() {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

    final mediaQuery = MediaQuery.of(context);
    final appBar = AppBar(
      title: Text(
        widget.title,
        style: Theme.of(context).textTheme.title,
      ),
    );

    return Directionality(
      textDirection:
          langProvider.langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: appBar,
        body: SingleChildScrollView(
          child: Container(
            width: mediaQuery.size.width,
            // height: mediaQuery.size.height -
            //     mediaQuery.padding.top -
            //     appBar.preferredSize.height,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    top: 20.0,
                    left: 20.0,
                  ),
                  child: Text(
                    labelsProvider.phoneNumber,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                InkWell(
                  onTap: () {
                    _callHospitalNumber(context);
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(
                      right: 20.0,
                      top: 20.0,
                      left: 20.0,
                    ),
                    child: Text(
                      widget.hospitalData['phoneNumber'],
                      style: Theme.of(context).textTheme.display2,
                      textDirection: TextDirection.ltr,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    top: 20.0,
                    left: 20.0,
                  ),
                  child: Text(
                    labelsProvider.address,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    top: 20.0,
                    left: 20.0,
                  ),
                  child: Text(
                    widget.hospitalData['address'],
                    style: Theme.of(context).textTheme.display2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    top: 20.0,
                    left: 20.0,
                  ),
                  child: Text(
                    labelsProvider.location,
                    style: Theme.of(context).textTheme.title,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 10.0,
                    ),
                    child: MaterialButton(
                      onPressed: () {
                        _openLocationOnMaps(context);
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0)),
                      elevation: 5.0,
                      color: Colors.blueAccent,
                      child: Text(
                        labelsProvider.openOnMap,
                        style: Theme.of(context).textTheme.display2.copyWith(
                              color: Colors.white,
                            ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    top: 20.0,
                    left: 20.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        labelsProvider.departments,
                        style: Theme.of(context).textTheme.title,
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20.0),
                          height: 30.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5.0),
                            border: Border.all(
                              width: 1.0,
                              color: Colors.grey[200],
                            ),
                            color: Colors.white,
                          ),
                          child: TextField(
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.body1,
                            decoration: InputDecoration(
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              hintText: labelsProvider.search,
                              hintStyle: Theme.of(context).textTheme.body1,
                            ),
                            onChanged: (searchValue) {
                              if (searchValue == '') {
                                _searchedDepartments =
                                    widget.hospitalData['departments'];
                                setState(() {});
                                return;
                              }
                              _searchForDepartment(searchValue);
                            },
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  height: 200.0,
                  width: mediaQuery.size.width,
                  padding: const EdgeInsets.all(15.0),
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                  child: _searchedDepartments.isEmpty
                      ? Center(
                          child: Text(labelsProvider.noResultFound),
                        )
                      : ListView.builder(
                          itemCount: _searchedDepartments.length,
                          itemBuilder: (ctx, index) {
                            return Container(
                              margin: const EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).accentColor,
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    _searchedDepartments[index],
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .display2
                                        .copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    top: 20.0,
                    left: 20.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        labelsProvider.raysAndAnalysis,
                        style: Theme.of(context).textTheme.title,
                      ),
                      widget.hospitalData['hasRays']
                          ? Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                height: 30.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.body1,
                                  decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    hintText: labelsProvider.search,
                                    hintStyle:
                                        Theme.of(context).textTheme.body1,
                                  ),
                                  onChanged: (searchValue) {
                                    if (searchValue == '') {
                                      _searchedRays =
                                          widget.hospitalData['rays'];
                                      setState(() {});
                                      return;
                                    }
                                    _searchForRays(searchValue);
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Container(
                  width: mediaQuery.size.width,
                  height: 200.0,
                  padding: const EdgeInsets.all(15.0),
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                  child: widget.hospitalData['hasRays']
                      ? _searchedRays.isEmpty
                          ? Center(
                              child: Text(labelsProvider.noResultFound),
                            )
                          : ListView.builder(
                              itemCount: _searchedRays.length,
                              itemBuilder: (ctx, index) {
                                return Container(
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _searchedRays[index],
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .display2
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                      : Center(
                          child: Text(labelsProvider.hospitalHasNoRaysCenters),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    right: 20.0,
                    top: 20.0,
                    left: 20.0,
                  ),
                  child: Row(
                    children: <Widget>[
                      Text(
                        labelsProvider.surgeries,
                        style: Theme.of(context).textTheme.title,
                      ),
                      widget.hospitalData['hasSurgeries']
                          ? Expanded(
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20.0),
                                height: 30.0,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  border: Border.all(
                                    width: 1.0,
                                    color: Colors.grey[200],
                                  ),
                                  color: Colors.white,
                                ),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.body1,
                                  decoration: InputDecoration(
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    hintText: labelsProvider.search,
                                    hintStyle:
                                        Theme.of(context).textTheme.body1,
                                  ),
                                  onChanged: (searchValue) {
                                    if (searchValue == '') {
                                      _searchedSurgeries =
                                          widget.hospitalData['surgeries'];
                                      setState(() {});
                                      return;
                                    }
                                    _searchForSurgeries(searchValue);
                                  },
                                ),
                              ),
                            )
                          : Container(),
                    ],
                  ),
                ),
                Container(
                  width: mediaQuery.size.width,
                  height: 200.0,
                  padding: const EdgeInsets.all(15.0),
                  margin: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 10.0,
                        color: Colors.grey[200],
                      ),
                    ],
                  ),
                  child: widget.hospitalData['hasSurgeries']
                      ? _searchedSurgeries.isEmpty
                          ? Center(
                              child: Text(labelsProvider.noResultFound),
                            )
                          : ListView.builder(
                              itemCount: _searchedSurgeries.length,
                              itemBuilder: (ctx, index) {
                                return Container(
                                  margin: const EdgeInsets.all(5.0),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).accentColor,
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                        _searchedSurgeries[index],
                                        textAlign: TextAlign.center,
                                        style: Theme.of(context)
                                            .textTheme
                                            .display2
                                            .copyWith(
                                              color: Colors.white,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            )
                      : Center(
                          child: Text(
                              labelsProvider.hospitalHasNoSurgeriesCenters),
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _searchForDepartment(String searchValue) {
    _searchedDepartments =
        widget.hospitalData['departments'].where((String deptName) {
      return deptName.contains(searchValue) || searchValue.contains(deptName);
    }).toList();

    print(_searchedDepartments);

    setState(() {});
  }

  void _searchForRays(String searchValue) {
    _searchedRays = widget.hospitalData['rays'].where((String raysType) {
      return raysType.contains(searchValue) || searchValue.contains(raysType);
    }).toList();

    print(_searchedRays);

    setState(() {});
  }

  void _searchForSurgeries(String searchValue) {
    _searchedSurgeries =
        widget.hospitalData['surgeries'].where((String surgeryType) {
      return surgeryType.contains(searchValue) ||
          searchValue.contains(surgeryType);
    }).toList();

    print(_searchedSurgeries);

    setState(() {});
  }

  void _openLocationOnMaps(context) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=${widget.hospitalData['location'].latitude},${widget.hospitalData['location'].longitude}';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          'Could not launch $url',
          style: Theme.of(context)
              .textTheme
              .display1
              .copyWith(color: Colors.white),
        ),
        duration: Duration(seconds: 2),
      )..show(context);
    }
  }

  void _callHospitalNumber(context) async {
    if (await canLaunch('tel://${widget.hospitalData['phoneNumber']}')) {
      launch('tel://${widget.hospitalData['phoneNumber']}');
    } else {
      Flushbar(
        icon: Icon(
          Icons.error,
          color: Colors.red,
        ),
        messageText: Text(
          'Could not call ${widget.hospitalData['phoneNumber']}',
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
