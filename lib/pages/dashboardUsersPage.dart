import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../services/dashboard.dart';
import '../routes.dart';

class DashboardUsersPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(52, 52, 52, 52),
                  ),
                ),
              ),
              DashboardUsersInfo(),
              SizedBox(height: 20),
              Container(
                child: Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(52, 52, 52, 52),
                  ),
                ),
              ),
              Container(
                height: 250,
                child: DashboardUsersLocation(),
              ),
              SizedBox(height: 20),
              Container(
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    color: Color.fromRGBO(52, 52, 52, 52),
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
  late DashboardService _dashboardService;
  int _locationsCount = 0;
  int _todayLocationsCount = 0;
  bool isLoading = true;
  int maleCount = 0;
  int femaleCount = 0;

  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardService();
    _loadUsers();
    _fetchLocationsCount();
    _fetchTodayLocationsCount();
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

  Future<void> _fetchLocationsCount() async {
    try {
      final locations = await _dashboardService.fetchLocationsAll();
      setState(() {
        _locationsCount = locations.length;
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  Future<void> _fetchTodayLocationsCount() async {
    try {
      final locations = await _dashboardService.fetchLocationsAll();
      DateTime today = DateTime.now();
      int todayCount = locations.where((location) {
        DateTime createdAt = DateTime.parse(location['createdAt']);
        return createdAt.year == today.year &&
            createdAt.month == today.month &&
            createdAt.day == today.day;
      }).length;

      setState(() {
        _todayLocationsCount = todayCount;
      });
    } catch (e) {
      print('Error fetching today locations: $e');
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

  Map<String, int> ageGroupCounts = {
    '20대 미만': 0,
    '20대': 0,
    '30대': 0,
    '40대': 0,
    '50대': 0,
    '60세 이상': 0,
  };

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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text(
                              'visit',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'gender',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'age',
                              style: TextStyle(
                                fontSize: 15,
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
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Total',
                                  style: TextStyle(fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  '$_locationsCount',
                                  style: TextStyle(
                                    fontSize: 35,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Today $_todayLocationsCount',
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 150,
                            child: SfCircularChart(
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: <CircularSeries>[
                                DoughnutSeries<_GenderData, String>(
                                  dataSource: [
                                    _GenderData('Female', femaleCount),
                                    _GenderData('Male', maleCount),
                                  ],
                                  xValueMapper: (_GenderData data, _) =>
                                      data.gender,
                                  yValueMapper: (_GenderData data, _) =>
                                      data.count,
                                  dataLabelMapper: (_GenderData data, _) {
                                    switch (data.gender) {
                                      case 'Male':
                                        return 'M';
                                      case 'Female':
                                        return 'F';
                                      default:
                                        return '';
                                    }
                                  },
                                  pointColorMapper: (_GenderData data, _) {
                                    switch (data.gender) {
                                      case 'Male':
                                        return Color(0xFF44558C8);
                                      case 'Female':
                                        return Color(0xFFF04452);
                                    }
                                  },
                                  dataLabelSettings: DataLabelSettings(
                                    isVisible: true,
                                    textStyle: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                    ),
                                  ),
                                  enableTooltip: true,
                                  radius: '100%',
                                  innerRadius: '30%',
                                ),
                              ],
                            ),
                          ),
                        ),
                        Expanded(
                          child: SizedBox(
                            height: 100,
                            child: SfPyramidChart(
                              tooltipBehavior: TooltipBehavior(enable: true),
                              series: PyramidSeries<_AgeData, String>(
                                dataSource: _getAgeData(),
                                xValueMapper: (_AgeData data, _) =>
                                    data.ageGroup,
                                yValueMapper: (_AgeData data, _) => data.count,
                                dataLabelSettings: DataLabelSettings(
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
  }
}

class _GenderData {
  final String gender;
  final int count;
  _GenderData(this.gender, this.count);
}

class _AgeData {
  final String ageGroup;
  final int count;
  _AgeData(this.ageGroup, this.count);
}

class DashboardUsersLocation extends StatefulWidget {
  @override
  State<DashboardUsersLocation> createState() => _DashboardUsersLocationState();
}

class _DashboardUsersLocationState extends State<DashboardUsersLocation> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  LatLng _center = LatLng(37.5665, 126.9780);
  double _zoom = 12.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) throw Exception('Location services are disabled.');

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied.');
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (!mounted) return;

      final currentLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _center = currentLatLng;
      });
      await _loadMarkers();
    } catch (e) {
      print('Location error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadMarkers() async {
    try {
      final dashboardService = DashboardService();
      final locations = await dashboardService.fetchLocationsAll();
      final markers = <Marker>[];

      for (var loc in locations) {
        final lat = double.tryParse(loc['latitude'].toString());
        final lng = double.tryParse(loc['longitude'].toString());

        if (lat != null && lng != null) {
          markers.add(
            Marker(
              point: LatLng(lat, lng),
              child: const Icon(
                Icons.location_on,
                color: Color(0xFFF04452),
                size: 30,
              ),
            ),
          );
        }
      }
      markers.add(
        Marker(
          point: _center,
          child: const Icon(
            Icons.location_on,
            color: Color(0xFF12AC79),
            size: 30,
          ),
        ),
      );
      if (mounted) {
        setState(() => _markers = markers);
      }
    } catch (e) {
      print('Marker load error: $e');
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
      _mapController.move(_center, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 1;
      _mapController.move(_center, _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: _zoom,
                      minZoom: 3,
                      maxZoom: 19,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
                  Positioned(
                    right: 10,
                    bottom: 10,
                    child: Column(
                      children: [
                        FloatingActionButton.small(
                          onPressed: _zoomIn,
                          backgroundColor: Color(0xFF44558C8),
                          child: Icon(Icons.add, color: Colors.white),
                        ),
                        FloatingActionButton.small(
                          onPressed: _zoomOut,
                          backgroundColor: Color(0xFF44558C8),
                          child: Icon(Icons.remove, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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

  final formatter = NumberFormat('#,###');

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

  void _showUserDetails(BuildContext context, dynamic user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('To User Page'),
          content: Text('userId : ${user['userId']}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        children: [
          TextField(
            onChanged: (query) {
              _searchUsers(query);
            },
            decoration: InputDecoration(
              hintText: 'Search by name',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Colors.grey,
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide(
                  color: Color(0xFF44558C8),
                  width: 1.5,
                ),
              ),
              prefixIcon: Icon(Icons.search_rounded),
            ),
            maxLines: 1,
            keyboardType: TextInputType.multiline,
          ),
          SizedBox(height: 10),
          isLoading
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 2,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Table(
                      columnWidths: {
                        0: FixedColumnWidth(60),
                        1: FixedColumnWidth(100),
                        2: FixedColumnWidth(200),
                        3: FixedColumnWidth(150),
                        4: FixedColumnWidth(300),
                        5: FixedColumnWidth(50),
                        6: FixedColumnWidth(70),
                        7: FixedColumnWidth(100),
                        8: FixedColumnWidth(100),
                        9: FixedColumnWidth(200),
                        10: FixedColumnWidth(200),
                      },
                      border: TableBorder.all(
                        color: Colors.grey,
                      ),
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Color(0xFF44558C8),
                          ),
                          children: [
                            _tableHeader('Profile'),
                            _tableHeader('Name'),
                            _tableHeader('Email'),
                            _tableHeader('Password'),
                            _tableHeader('ID'),
                            _tableHeader('Age'),
                            _tableHeader('Gender'),
                            _tableHeader('Money'),
                            _tableHeader('Spend'),
                            _tableHeader('Created At'),
                            _tableHeader('Modified At'),
                          ],
                        ),
                        for (var user in filteredUsers)
                          TableRow(
                            children: [
                              TableCell(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.user,
                                        arguments: {'userId': user['userId']});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: CircleAvatar(
                                      radius: 17,
                                      backgroundImage:
                                          NetworkImage(user['userImgURL']),
                                      onBackgroundImageError: (_, __) =>
                                          Icon(Icons.person),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.user,
                                        arguments: {'userId': user['userId']});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      user['userName'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['userEmail']),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['userPassword']),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['userId']),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    user['userAge'].toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    user['userGender'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    formatter.format(user['userMoney']),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    formatter.format(user['userSpend']),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['createdAt'].toString()),
                                ),
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['modifiedAt'].toString()),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  Widget _tableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
