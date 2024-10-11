import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:geolocator/geolocator.dart' as geolocator_position;
import '../services/dashboard.dart';

class DashboardUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Info',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardUsersInfo(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Container(
                height: 250,
                child: DashboardUsersLocation(),
              ),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardUsersSearch(),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardUsersInfo extends StatefulWidget {
  @override
  _DashboardUsersInfoState createState() => _DashboardUsersInfoState();
}

class _DashboardUsersInfoState extends State<DashboardUsersInfo> {
  List<dynamic> users = [];
  bool isLoading = true;
  int maleCount = 0;
  int femaleCount = 0;

  Map<String, int> ageGroupCounts = {
    '20대 미만': 0,
    '20대': 0,
    '30대': 0,
    '40대': 0,
    '50대': 0,
    '60세 이상': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      DashboardService dashboardService = DashboardService();
      List<dynamic> fetchedUsers = await dashboardService.fetchUsersAll();
      setState(() {
        users = fetchedUsers;
        isLoading = false;
        _countGender();
        _countAgeGroups();
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  void _countGender() {
    maleCount = 0;
    femaleCount = 0;

    for (var user in users) {
      if (user['userGender'] == 'Male') {
        maleCount++;
      } else if (user['userGender'] == 'Female') {
        femaleCount++;
      }
    }
  }

  void _countAgeGroups() {
    for (var user in users) {
      int age = user['userAge'];

      if (age < 20) {
        ageGroupCounts['20대 미만'] = ageGroupCounts['20대 미만']! + 1;
      } else if (age >= 20 && age <= 29) {
        ageGroupCounts['20대'] = ageGroupCounts['20대']! + 1;
      } else if (age >= 30 && age <= 39) {
        ageGroupCounts['30대'] = ageGroupCounts['30대']! + 1;
      } else if (age >= 40 && age <= 49) {
        ageGroupCounts['40대'] = ageGroupCounts['40대']! + 1;
      } else if (age >= 50 && age <= 59) {
        ageGroupCounts['50대'] = ageGroupCounts['50대']! + 1;
      } else {
        ageGroupCounts['60세 이상'] = ageGroupCounts['60세 이상']! + 1;
      }
    }
  }

  List<_AgeData> _getAgeData() {
    return ageGroupCounts.entries.map((entry) {
      return _AgeData(entry.key, entry.value);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        '방문',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '연령',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        '성별',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'User Info',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 150,
                      child: SfCircularChart(
                        series: <CircularSeries>[
                          PieSeries<_AgeData, String>(
                            dataSource: _getAgeData(),
                            xValueMapper: (_AgeData data, _) => data.ageGroup,
                            yValueMapper: (_AgeData data, _) => data.count,
                            dataLabelMapper: (_AgeData data, _) =>
                                data.ageGroup,
                            dataLabelSettings: DataLabelSettings(
                                isVisible: true,
                                textStyle: TextStyle(
                                  color: Colors.white,
                                )),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 150,
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        primaryYAxis: NumericAxis(
                          isVisible: false,
                          majorGridLines: MajorGridLines(width: 0),
                        ),
                        series: <CartesianSeries>[
                          ColumnSeries<_GenderData, String>(
                            dataSource: [
                              _GenderData('Male', maleCount),
                              _GenderData('Female', femaleCount),
                            ],
                            xValueMapper: (_GenderData data, _) => data.gender,
                            yValueMapper: (_GenderData data, _) => data.count,
                            dataLabelSettings: DataLabelSettings(
                              isVisible: true,
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
  }
}

class _AgeData {
  _AgeData(this.ageGroup, this.count);

  final String ageGroup;
  final int count;
}

class _GenderData {
  _GenderData(this.gender, this.count);

  final String gender;
  final int count;
}

class DashboardUsersLocation extends StatefulWidget {
  @override
  _DashboardUsersLocationState createState() => _DashboardUsersLocationState();
}

class _DashboardUsersLocationState extends State<DashboardUsersLocation> {
  late MapController mapController;
  List<GeoPoint> geoPoints = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    bool serviceEnabled;
    geolocator_position.LocationPermission permission;

    serviceEnabled =
        await geolocator_position.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
      });
      print("Location services are disabled.");
      return;
    }

    permission = await geolocator_position.Geolocator.checkPermission();
    if (permission == geolocator_position.LocationPermission.denied) {
      permission = await geolocator_position.Geolocator.requestPermission();
      if (permission != geolocator_position.LocationPermission.whileInUse &&
          permission != geolocator_position.LocationPermission.always) {
        setState(() {
          isLoading = false;
        });
        print("Location permission denied.");
        return;
      }
    }

    geolocator_position.Position position =
        await geolocator_position.Geolocator.getCurrentPosition(
      desiredAccuracy: geolocator_position.LocationAccuracy.high,
    );

    mapController = MapController(
      initPosition: GeoPoint(
        latitude: position.latitude,
        longitude: position.longitude,
      ),
    );

    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      DashboardService dashboardService = DashboardService();
      List<dynamic> locations = await dashboardService.fetchLocationsLatLong();

      List<GeoPoint> points = locations.map((location) {
        return GeoPoint(
          latitude: double.parse(location['latitude']),
          longitude: double.parse(location['longitude']),
        );
      }).toList();

      setState(() {
        geoPoints = points;
        isLoading = false;
      });

      for (var point in geoPoints) {
        mapController.addMarker(point);
      }
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  void _zoomIn() {
    mapController.zoomIn();
  }

  void _zoomOut() {
    mapController.zoomOut();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : Stack(
            children: [
              OSMFlutter(
                controller: mapController,
                osmOption: OSMOption(
                  userTrackingOption: UserTrackingOption(
                    enableTracking: true,
                    unFollowUser: false,
                  ),
                  zoomOption: ZoomOption(
                    initZoom: 12,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                  userLocationMarker: UserLocationMaker(
                    personMarker: MarkerIcon(
                      icon: Icon(Icons.location_history_rounded,
                          color: Colors.blue, size: 80),
                    ),
                    directionArrowMarker: MarkerIcon(
                      icon: Icon(
                        Icons.double_arrow,
                        size: 48,
                      ),
                    ),
                  ),
                ),
                onMapIsReady: (isReady) async {
                  if (isReady) {
                    for (var point in geoPoints) {
                      await mapController.addMarker(point);
                    }
                  }
                },
              ),
              Positioned(
                right: 10,
                bottom: 10,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _zoomIn,
                      child: Icon(Icons.add),
                    ),
                    SizedBox(height: 5),
                    FloatingActionButton(
                      onPressed: _zoomOut,
                      child: Icon(Icons.remove),
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class DashboardUsersSearch extends StatefulWidget {
  @override
  _DashboardUsersSearchState createState() => _DashboardUsersSearchState();
}

class _DashboardUsersSearchState extends State<DashboardUsersSearch> {
  List<dynamic> users = [];
  List<dynamic> filteredUsers = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      DashboardService dashboardService = DashboardService();
      List<dynamic> fetchedUsers = await dashboardService.fetchUsersAll();
      setState(() {
        users = fetchedUsers;
        filteredUsers = users;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  void _searchUsers(String query) {
    final results = users.where((user) {
      final userName = user['userName'].toLowerCase();
      final input = query.toLowerCase();
      return userName.contains(input);
    }).toList();

    setState(() {
      filteredUsers = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (query) {
            _searchUsers(query);
          },
          decoration: InputDecoration(
            hintText: 'Search by name...',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.search),
          ),
        ),
        SizedBox(height: 10),
        isLoading
            ? CircularProgressIndicator()
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return ListTile(
                    title: Text(user['userName']),
                    subtitle: Text(
                        'Age: ${user['userAge']}      Gender: ${user['userGender']}'),
                  );
                },
              ),
      ],
    );
  }
}
