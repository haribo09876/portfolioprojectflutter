import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:geolocator/geolocator.dart';
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
                height: 300,
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
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text('Name: ${user['userName']}'),
                subtitle: Text('Age: ${user['userAge']}'),
              );
            },
          );
  }
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
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        isLoading = false;
      });
      print("Location services are disabled.");
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        setState(() {
          isLoading = false;
        });
        print("Location permission denied.");
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
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
                      icon: Icon(
                        Icons.location_on_outlined,
                        color: Colors.green,
                        size: 48,
                      ),
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
                top: 20,
                right: 10,
                child: Column(
                  children: [
                    FloatingActionButton(
                      onPressed: _zoomIn,
                      child: Icon(Icons.add),
                    ),
                    SizedBox(height: 10),
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
                    subtitle: Text('Age: ${user['userAge']}'),
                  );
                },
              ),
      ],
    );
  }
}
