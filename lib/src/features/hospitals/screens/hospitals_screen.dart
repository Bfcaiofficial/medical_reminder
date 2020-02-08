import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import './../models/hospital.dart';
import './../providers/hospitals_provider.dart';
import './../widgets/hospital_item.dart';
import './../widgets/search_location_dialog_content.dart';
import './../../../core/providers/language_provider.dart';
import './../../../core/resources/labels.dart';

class HospitalsScreen extends StatefulWidget {
  static const String routeName = 'hospitals-screen';

  @override
  _HospitalsScreenState createState() => _HospitalsScreenState();
}

class _HospitalsScreenState extends State<HospitalsScreen> {
  int _selectedCategoryIndex = 0;
  int _currentSearchLocationOption = 0;
  bool _isLoading = false;
  bool _isResultRequestedAndNotFound = false;
  Map<String, dynamic> _chosenLocation;
  final TextEditingController _searchFieldController = TextEditingController();
  final TextEditingController _locationFieldController =
      TextEditingController();
  List<Hospital> hospitalList = [];
  List<Hospital> searchedHospitals = [];
  String _searchFieldHint;
  var labelsProvider;
  var langProvider;

  void _initializeLabelsProvider() {
    langProvider = Provider.of<LanguageProvider>(context, listen: false);

    if (langProvider.langCode == 'en')
      labelsProvider = langProvider.labelsProvider as EnglishLabels;
    else
      labelsProvider = langProvider.labelsProvider as ArabicLabels;

    if (_selectedCategoryIndex == 0)
      _searchFieldHint = labelsProvider.writeHospitalName;
  }

  @override
  Widget build(BuildContext context) {
    final hospitalsProvider =
        Provider.of<HospitalsProvider>(context, listen: false);

    _initializeLabelsProvider();

    if (!hospitalsProvider.isDataLoaded) {
      hospitalsProvider.refreshHospitalList().then((isConnected) {
        if (!isConnected) {
          Flushbar(
            icon: Icon(
              Icons.error,
              color: Colors.red,
            ),
            messageText: Text(
              labelsProvider.internetConnectionFailed,
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
          )..show(context);
        }
      });
    }

    hospitalList = hospitalsProvider.hospitalList;

    return WillPopScope(
      onWillPop: () {
        _searchFieldController.clear();
        if (searchedHospitals.isNotEmpty) {
          searchedHospitals.clear();
          setState(() {
            _isResultRequestedAndNotFound = false;
          });
          return Future.value(false);
        } else {
          if (_isResultRequestedAndNotFound) {
            searchedHospitals.clear();
            setState(() {
              _isResultRequestedAndNotFound = false;
            });
            return Future.value(false);
          }
          return Future.value(true);
        }
      },
      child: Directionality(
        textDirection: langProvider.langCode == 'ar'
            ? TextDirection.rtl
            : TextDirection.ltr,
        child: Scaffold(
          appBar: AppBar(
            elevation: 1.0,
            title: Text(
              labelsProvider.hospitals,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSearchField(),
              Expanded(
                child:
                    searchedHospitals.isEmpty && !_isResultRequestedAndNotFound
                        ? _buildSearchFilters(context)
                        : _isLoading
                            ? Center(
                                child: CircularProgressIndicator(),
                              )
                            : _buildSearchedHospitalList(),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchFilters(context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
              top: 20.0,
              left: 20.0,
              bottom: 15.0,
            ),
            child: Text(
              labelsProvider.whatYouSearchFor,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Wrap(
              runSpacing: 15.0,
              spacing: 30.0,
              children: <Widget>[
                _buildSearchCategory(
                    title: labelsProvider.hospitalName, index: 0),
                _buildSearchCategory(
                    title: labelsProvider.raysAndAnalysis, index: 1),
                _buildSearchCategory(title: labelsProvider.surgeries, index: 2),
                _buildSearchCategory(
                    title: labelsProvider.departments, index: 3),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Divider(
              height: 20.0,
              color: Colors.black54,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
              right: 20.0,
              top: 20.0,
              bottom: 15.0,
              left: 20.0,
            ),
            child: Text(
              labelsProvider.whereDoYouWantToSearch,
              style: Theme.of(context).textTheme.title,
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Expanded(
                child: _buildSearchByLocationOption(
                  title: labelsProvider.withYourCurrentLocation,
                  radioValue: 0,
                  context: context,
                ),
              ),
              Expanded(
                child: _buildSearchByLocationOption(
                  title: labelsProvider.chooseLocation,
                  radioValue: 1,
                  context: context,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: LayoutBuilder(
              builder: (ctx, constraints) {
                return MaterialButton(
                  disabledColor: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  onPressed: _currentSearchLocationOption == 0
                      ? null
                      : _showLocationDialog,
                  color: Colors.white,
                  elevation: 5.0,
                  height: 40,
                  minWidth: constraints.maxWidth,
                  child: _chosenLocation != null
                      ? Text(
                          _chosenLocation['name'],
                          style: Theme.of(context).textTheme.display2,
                        )
                      : Container(),
                );
              },
            ),
          ),
          SizedBox(
            height: 40.0,
          )
        ],
      ),
    );
  }

  Widget _buildSearchByLocationOption({String title, int radioValue, context}) {
    return InkWell(
      onTap: () async {
        if (_currentSearchLocationOption != radioValue) {
          _changeCurrentSelectedValue(radioValue);
          _chosenLocation = null;
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Radio(
            value: radioValue,
            groupValue: _currentSearchLocationOption,
            onChanged: (value) {
              setState(() {
                _currentSearchLocationOption = value;
              });
            },
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.display1,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCategory({String title, int index}) {
    return InkWell(
      onTap: () {
        switch (index) {
          case 0:
            _searchFieldHint = labelsProvider.writeHospitalName;
            break;
          case 1:
            _searchFieldHint = labelsProvider.enterRayOrAnalysisType;
            break;
          case 2:
            _searchFieldHint = labelsProvider.enterSurgeryType;
            break;
          case 3:
            _searchFieldHint = labelsProvider.writeDepartmentName;
        }
        _onSearchCategorySelected(index);
      },
      child: Container(
        height: 120,
        width: 100.0,
        decoration: BoxDecoration(
          color: _selectedCategoryIndex == index
              ? Theme.of(context).accentColor
              : Colors.white,
          borderRadius: BorderRadius.circular(10.0),
          boxShadow: [
            BoxShadow(
              blurRadius: 15.0,
              color: Colors.grey[200],
            ),
          ],
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.display2.copyWith(
                  color: _selectedCategoryIndex == index
                      ? Colors.white
                      : Colors.black,
                ),
          ),
        ),
      ),
    );
  }

  void _searchForHospital() async {
    print(_searchFieldController.text);
    _isLoading = true;

    print('Current Search Category: $_selectedCategoryIndex');

    final searchText = _searchFieldController.text
        .replaceAll('ي ', 'ى ')
        .replaceAll('أ', 'ا')
        .replaceAll('إ', 'ا')
        .replaceAll(RegExp(r'\s\s+'), ' ')
        .toLowerCase()
        .trim();

    print(searchText);
    searchedHospitals.clear();

    if (_chosenLocation == null) {
      if (_currentSearchLocationOption == 0) {
        _chosenLocation = {
          'position': await Geolocator().getCurrentPosition(),
          'name': '',
        };
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
        return;
      }
    }

    switch (_selectedCategoryIndex) {
      case 0:
        {
          searchedHospitals = hospitalList.where((hospital) {
            final Distance distanceObj = new Distance();
            double distance = distanceObj.as(
              LengthUnit.Kilometer,
              LatLng(_chosenLocation['position'].latitude,
                  _chosenLocation['position'].longitude),
              LatLng(
                hospital.location.latitude,
                hospital.location.longitude,
              ),
            );
            print('distance to ${hospital.name}: $distance');
            return (hospital.name.toLowerCase().contains(searchText) &&
                    distance < 50) ||
                (searchText.contains(hospital.name.toLowerCase()) &&
                    distance < 50);
          }).toList();
          break;
        }
      case 1:
        {
          searchedHospitals = hospitalList.where(
            (hospital) {
              final Distance distanceObj = new Distance();
              double distance = distanceObj.as(
                LengthUnit.Kilometer,
                LatLng(_chosenLocation['position'].latitude,
                    _chosenLocation['position'].longitude),
                LatLng(
                  hospital.location.latitude,
                  hospital.location.longitude,
                ),
              );
              print('${hospital.id}: ${hospital.hasRaysCenter}');
              print('distance to ${hospital.name}: $distance');

              if (hospital.hasRaysCenter) {
                final listOfDepts = hospital.raysAndAnalysis.where(
                  (raysType) => (raysType.toLowerCase().contains(searchText) ||
                      searchText.contains(raysType.toLowerCase())),
                );
                return listOfDepts.isNotEmpty && distance < 50;
              }

              return false;
            },
          ).toList();
          break;
        }
      case 2:
        {
          searchedHospitals = hospitalList.where(
            (hospital) {
              final Distance distanceObj = new Distance();
              double distance = distanceObj.as(
                LengthUnit.Kilometer,
                LatLng(_chosenLocation['position'].latitude,
                    _chosenLocation['position'].longitude),
                LatLng(
                  hospital.location.latitude,
                  hospital.location.longitude,
                ),
              );
              print('${hospital.id}: ${hospital.hasSurgeryCenter}');
              print('distance to ${hospital.name}: $distance');

              if (hospital.hasSurgeryCenter) {
                final listOfDepts = hospital.surgeries.where(
                  (surgeryType) =>
                      (surgeryType.toLowerCase().contains(searchText) ||
                          searchText.contains(surgeryType.toLowerCase())),
                );
                return listOfDepts.isNotEmpty && distance < 50;
              }
              return false;
            },
          ).toList();
          break;
        }
      case 3:
        {
          searchedHospitals = hospitalList.where((hospital) {
            final Distance distanceObj = new Distance();
            double distance = distanceObj.as(
              LengthUnit.Kilometer,
              LatLng(_chosenLocation['position'].latitude,
                  _chosenLocation['position'].longitude),
              LatLng(
                hospital.location.latitude,
                hospital.location.longitude,
              ),
            );
            print('distance to ${hospital.name}: $distance');
            final listOfDepts = hospital.departments.where((deptName) =>
                (deptName.toLowerCase().contains(searchText) ||
                    searchText.contains(deptName.toLowerCase())));
            return listOfDepts.isNotEmpty && distance < 50;
          }).toList();
          break;
        }
    }
    setState(() {
      _isLoading = false;
    });
    if (searchedHospitals.isEmpty) _isResultRequestedAndNotFound = true;
  }

  void _onSearchCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
  }

  void _changeCurrentSelectedValue(int value) {
    setState(() {
      _currentSearchLocationOption = value;
    });
  }

  void _showLocationDialog() {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0.0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          title: Align(
            alignment: Alignment.topCenter,
            child: Text(
              labelsProvider.chooseLocation,
              style: Theme.of(context)
                  .textTheme
                  .display1
                  .copyWith(color: Colors.grey[400]),
            ),
          ),
          content: SearchLocationDialogContent(
            screenSize: screenSize,
            locationFieldController: _locationFieldController,
            context: context,
          ),
        );
      },
    ).then((chosenLocation) {
      if (chosenLocation != null) {
        setState(() {
          _chosenLocation = chosenLocation;
        });
      }
    });
  }

  Widget _buildSearchedHospitalList() {
    if (searchedHospitals.isEmpty) {
      return Center(
        child: Text(
          labelsProvider.noResultFound,
          style: Theme.of(context).textTheme.title,
        ),
      );
    }

    return ListView.builder(
      itemCount: searchedHospitals.length,
      itemBuilder: (ctx, index) {
        return HospitalItem(
          name: searchedHospitals[index].name,
          address: searchedHospitals[index].address,
          phoneNumber: searchedHospitals[index].phoneNumber,
          id: searchedHospitals[index].id,
          hasRays: searchedHospitals[index].hasRaysCenter,
          hasSurgeries: searchedHospitals[index].hasSurgeryCenter,
          location: searchedHospitals[index].location,
          departments: searchedHospitals[index].departments,
          rays: searchedHospitals[index].raysAndAnalysis,
          surgeries: searchedHospitals[index].surgeries,
        );
      },
    );
  }

  Widget _buildSearchField() {
    return Container(
      height: 80.0,
      child: Material(
        elevation: 5.0,
        color: Colors.white,
        child: Center(
          child: Container(
            height: 40.0,
            margin: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 5.0,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(
                width: 1.0,
                color: Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: TextField(
                      // onSubmitted: (_) {
                      //   _searchForHospital();
                      // },
                      controller: _searchFieldController,
                      style: Theme.of(context).textTheme.body1,
                      decoration: InputDecoration(
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintText: _searchFieldHint,
                        hintStyle: Theme.of(context).textTheme.body1,
                      ),
                      onChanged: (_) {
                        if (_.isEmpty) {
                          searchedHospitals.clear();
                          _isResultRequestedAndNotFound = false;
                          setState(() {});
                          return;
                        }
                        _searchForHospital();
                      },
                    ),
                  ),
                ),
                InkWell(
                  onTap: _searchForHospital,
                  child: Container(
                    width: 50.0,
                    height: 48.0,
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
        ),
      ),
    );
  }

  @override
  void dispose() {
    hospitalList.clear();
    _searchFieldController.dispose();
    super.dispose();
  }
}
