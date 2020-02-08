import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import './../../../core/resources/labels.dart';
import './../../../core/providers/language_provider.dart';
import './../models/city.dart';

class SearchLocationDialogContent extends StatefulWidget {
  SearchLocationDialogContent({
    @required this.screenSize,
    @required this.locationFieldController,
    @required this.context,
  });

  final Size screenSize;
  final TextEditingController locationFieldController;
  final BuildContext context;

  @override
  _SearchLocationDialogContentState createState() =>
      _SearchLocationDialogContentState();
}

class _SearchLocationDialogContentState
    extends State<SearchLocationDialogContent> {
  List<City> searchedLocationList = [];
  bool _isSearchingForLocation = false;
  int _selectedIndex = -1;

  Map<String, dynamic> _chosenLocation;
  var labelsProvider;
  var langProvider;
  int count = 0;

  void _initializeLabelsProvider() {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (count == 0) {
      searchedLocationList = getEgyptCities(langProvider.langCode);
      count++;
    }

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;
  }

  @override
  Widget build(BuildContext context) {
    _initializeLabelsProvider();

    return Directionality(
      textDirection:
          langProvider.langCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        child: SizedBox(
          height: widget.screenSize.height * 0.6,
          width: widget.screenSize.width * 0.8,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Divider(
                height: 20.0,
              ),
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 5.0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        height: 40.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 8.0,
                              color: Colors.grey[200],
                            ),
                          ],
                        ),
                        child: TextField(
                          //onSubmitted: _searchForLocation,
                          controller: widget.locationFieldController,
                          style: Theme.of(context).textTheme.body1,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: labelsProvider.enterYourLocation,
                            hintStyle: Theme.of(context).textTheme.body1,
                          ),
                          onChanged: (searchValue) {
                            _searchForLocation(searchValue.trim());
                          },
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _searchForLocation(
                          widget.locationFieldController.text.trim(),
                        );
                      },
                      child: Container(
                        width: 40.0,
                        height: 40.0,
                        child: Icon(
                          Icons.search,
                          color: Colors.white,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.only(
                            topLeft: langProvider.langCode == 'ar'
                                ? Radius.circular(10.0)
                                : Radius.zero,
                            bottomLeft: langProvider.langCode == 'ar'
                                ? Radius.circular(10.0)
                                : Radius.zero,
                            topRight: langProvider.langCode == 'ar'
                                ? Radius.zero
                                : Radius.circular(10.0),
                            bottomRight: langProvider.langCode == 'ar'
                                ? Radius.zero
                                : Radius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _isSearchingForLocation
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : searchedLocationList.isEmpty
                        ? Center(
                            child: Text(
                              labelsProvider.noResultFound,
                              style: Theme.of(context).textTheme.display2,
                            ),
                          )
                        : ListView.builder(
                            itemCount: searchedLocationList.length,
                            itemBuilder: (ctx, index) {
                              return _buildLocationNameItem(
                                location: {
                                  'name': searchedLocationList[index].name,
                                  'position': Position(
                                    latitude:
                                        searchedLocationList[index].latitude,
                                    longitude:
                                        searchedLocationList[index].longitude,
                                  ),
                                },
                                index: index,
                              );
                            },
                          ),
              ),
              SizedBox(
                width: widget.screenSize.width * 0.8,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
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
                    Expanded(
                      child: Container(),
                    ),
                    InkWell(
                      onTap: () {
                        if (_chosenLocation != null) {
                          print(_chosenLocation);
                          Navigator.of(context).pop(_chosenLocation);
                        } else {
                          Flushbar(
                            icon: Icon(
                              Icons.error,
                              color: Colors.red,
                            ),
                            messageText: Text(
                              labelsProvider.cityLocationIsRequired,
                              style: Theme.of(context)
                                  .textTheme
                                  .display1
                                  .copyWith(color: Colors.white),
                            ),
                            duration: Duration(seconds: 2),
                          )..show(context);
                        }
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
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _searchForLocation(String locationName) async {
    // locationName = locationName
    //     .replaceAll('ي ', 'ى ')
    //     .replaceAll('أ', 'ا')
    //     .replaceAll('إ', 'ا')
    //     .replaceAll(RegExp(r'\s\s+'), ' ');

    final egyptCities = getEgyptCities(langProvider.langCode);
    searchedLocationList = egyptCities.where((location) {
      return location.name.toLowerCase().contains(locationName.toLowerCase()) ||
          locationName.toLowerCase().contains(location.name.toLowerCase());
    }).toList();
    setState(() {});
    /*
    final permissionStatus =
        await Geolocator().checkGeolocationPermissionStatus();
    setState(() {
      _isSearchingForLocation = true;
    });

    if (permissionStatus == GeolocationStatus.granted) {
      
      Geolocator().getCurrentPosition();

      try {
        Geolocator().placemarkFromAddress(locationName).then((placemarks) {
          if (placemarks != null && placemarks.isNotEmpty) {
            locationList.clear();
            for (Placemark placemark in placemarks) {
              if (placemark != null) {
                locationList.add({
                  'name': placemark.name,
                  'position': placemark.position,
                });
              }
            }
            print('locations loaded');
          }

          setState(() {
            _isSearchingForLocation = false;
          });
        });
      } finally {
        setState(() {
          _isSearchingForLocation = false;
          locationList.clear();
        });
      }
      
    }
    */
  }

  Widget _buildLocationNameItem({Map<String, dynamic> location, index}) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _chosenLocation = location;
        });
      },
      child: Container(
        color: _selectedIndex == index ? Colors.blueAccent : Colors.white,
        width: widget.screenSize.width * 0.5,
        padding: const EdgeInsets.symmetric(
          horizontal: 20.0,
          vertical: 10.0,
        ),
        child: Text(
          location['name'],
          style: Theme.of(context).textTheme.title.copyWith(
                color: _selectedIndex == index ? Colors.white : Colors.black,
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.locationFieldController.clear();
    super.dispose();
  }
}
