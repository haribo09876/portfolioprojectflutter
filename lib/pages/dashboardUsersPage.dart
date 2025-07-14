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
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
              DashboardUsersInfo(), // User summary widget (사용자 요약 위젯)
              SizedBox(height: 30),
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
                child:
                    DashboardUsersLocation(), // User location map widget (사용자 위치 지도 위젯)
              ),
              SizedBox(height: 30),
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
              DashboardUsersSearch(), // Search widget placeholder (검색 위젯 자리 표시자)
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
  late DashboardService
      _dashboardService; // Service for data fetching (데이터 페칭용 서비스)
  int _locationsCount = 0;
  int _todayLocationsCount = 0;
  bool isLoading = true;
  int maleCount = 0;
  int femaleCount = 0;

  @override
  void initState() {
    super.initState();
    _dashboardService = DashboardService();
    _loadUsers(); // Fetch user list from API (사용자 목록 API 호출)
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
        _locationsCount =
            locations.length; // Update total locations count (전체 위치 개수 갱신)
      });
    } catch (e) {
      print('Error fetching locations: $e');
    }
  }

  Future<void> _fetchTodayLocationsCount() async {
    try {
      final locations = await _dashboardService.fetchLocationsAll();
      DateTime now = DateTime.now();
      int todayCount = locations.where((location) {
        DateTime createdAt = DateTime.parse(location['createdAt']).toLocal();
        return createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day;
      }).length;
      setState(() {
        _todayLocationsCount =
            todayCount; // Update today's location count (오늘 위치 개수 갱신)
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
  }; // Age groups bucket (연령대 구간)

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
      return _AgeData(entry.key,
          entry.value); // Map age group counts to chart data (차트용 연령대 데이터 변환)
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(
            child:
                CircularProgressIndicator()) // Show loading spinner (로딩 스피너 표시)
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
                                // Location counts summary (위치 개수 요약)
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
                                // Gender distribution donut chart (성별 분포 도넛 차트)
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
                              // Age group pyramid chart visualization (연령대 피라미드 차트 시각화)
                              series: PyramidSeries<_AgeData, String>(
                                dataSource: _getAgeData(),
                                xValueMapper: (_AgeData data, _) =>
                                    data.ageGroup,
                                yValueMapper: (_AgeData data, _) => data.count,
                                pointColorMapper: (_AgeData data, _) {
                                  switch (data.ageGroup) {
                                    case '20대 미만':
                                      return Color(0xFF12AC79);
                                    case '20대':
                                      return Color(0xFFF04452);
                                    case '30대':
                                      return Color(0xFF44558C8);
                                    case '40대':
                                      return Color(0xFFFFCA28);
                                    case '50대':
                                      return Color(0xFF9C27B0);
                                    case '60세 이상':
                                      return Color(0xFFFF7043);
                                    default:
                                      return Colors.grey;
                                  }
                                },
                                dataLabelSettings: DataLabelSettings(
                                  labelPosition: ChartDataLabelPosition.outside,
                                  textStyle: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
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
                              'visit',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                              textAlign: TextAlign.center,
                            ), // Label for visits (방문 레이블)
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
                            ), // Label for gender (성별 레이블)
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
                            ), // Label for age (연령 레이블)
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
  final MapController _mapController =
      MapController(); // Controller for flutter_map (flutter_map 컨트롤러)
  List<Marker> _markers = [];
  LatLng _center =
      LatLng(37.5665, 126.9780); // Default center coordinates (기본 중심 좌표)
  double _zoom = 12.0; // Default zoom level (기본 줌 레벨)
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation(); // Initialize GPS and load map markers (GPS 초기화 및 마커 로드)
  }

  Future<void> _initializeLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled)
        throw Exception(
            'Location services are disabled.'); // Location services check (위치 서비스 활성화 여부 확인)

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator
            .requestPermission(); // Request location permission (위치 권한 요청)
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permission permanently denied.'); // Permanent denial handling (영구 권한 거부 처리)
      }
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ); // Acquire current GPS position (현재 GPS 위치 획득)
      if (!mounted) return;

      final currentLatLng = LatLng(position.latitude, position.longitude);
      setState(() {
        _center =
            currentLatLng; // Update map center with current position (현재 위치로 지도 중심 갱신)
      });
      await _loadMarkers(); // Load map markers after location fix (위치 고정 후 마커 로드)
    } catch (e) {
      print('Location error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading =
            false); // Set loading false after init (초기화 후 로딩 상태 해제)
      }
    }
  }

  Future<void> _loadMarkers() async {
    try {
      final dashboardService = DashboardService();
      // Fetch all location data (위치 데이터 모두 가져오기)
      final locations = await dashboardService.fetchLocationsAll();
      final markers = <Marker>[];

      for (var loc in locations) {
        final lat = double.tryParse(loc['latitude'].toString());
        final lng = double.tryParse(loc['longitude'].toString());

        // Validate and parse lat/lng before adding markers (위도/경도 유효성 검사 후 마커 추가)
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
      // Add center marker with distinct color for current focus (현재 중심 좌표 마커 추가)
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
        // Update state with new markers if widget is still mounted (위젯이 활성화되어 있으면 상태 업데이트)
        setState(() => _markers = markers);
      }
    } catch (e) {
      // Log marker loading errors for debugging (마커 로드 오류 로그)
      print('Marker load error: $e');
    }
  }

  void _zoomIn() {
    setState(() {
      _zoom += 1;
      // Move map camera with updated zoom level (줌 레벨 변경 후 지도 이동)
      _mapController.move(_center, _zoom);
    });
  }

  void _zoomOut() {
    setState(() {
      _zoom -= 1;
      // Move map camera with updated zoom level (줌 레벨 변경 후 지도 이동)
      _mapController.move(_center, _zoom);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child:
                CircularProgressIndicator()) // Show loading indicator while fetching (데이터 로딩 중 로딩 인디케이터 표시)
        : Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter:
                          _center, // Initial map center coordinate (초기 지도 중심 좌표)
                      initialZoom: _zoom, // Initial zoom level (초기 줌 레벨)
                      minZoom: 3,
                      maxZoom: 19,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.portfolioprojectflutter',
                      ),
                      MarkerLayer(
                          markers:
                              _markers), // Render markers on the map (맵에 마커 렌더링)
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        FloatingActionButton.small(
                          onPressed: _zoomOut,
                          backgroundColor: Color(0xFF44558C8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
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
    _loadUsers(); // Fetch user data on widget initialization (위젯 초기화 시 사용자 데이터 로드)
  }

  Future<void> _loadUsers() async {
    try {
      DashboardService dashboardService = DashboardService();
      // Fetch all users (사용자 데이터 모두 가져오기)
      List<dynamic> fetchedUsers = await dashboardService.fetchUsersAll();
      setState(() {
        users = fetchedUsers;
        filteredUsers =
            users; // Initialize filtered list with all users (필터링된 리스트 초기화)
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
      return userName
          .contains(input); // Case-insensitive substring search (대소문자 구분 없는 검색)
    }).toList();

    setState(() {
      filteredUsers =
          results; // Update filtered users based on query (검색 결과로 필터링 업데이트)
    });
  }

  void _showUserDetails(BuildContext context, dynamic user) {
    // Show user detail dialog with userId (사용자 상세 정보 다이얼로그 표시)
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
              _searchUsers(
                  query); // Update filtered user list on search input (검색 입력 시 필터링 업데이트)
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
              ? CircularProgressIndicator() // Show loading spinner while fetching users (사용자 로딩 중 스피너 표시)
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
                        3: FixedColumnWidth(200),
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
                                  // Navigate to user page on avatar tap (아바타 클릭 시 사용자 페이지 이동)
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
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: GestureDetector(
                                  // Navigate to user page on name tap (이름 클릭 시 사용자 페이지 이동)
                                  onTap: () {
                                    Navigator.pushNamed(context, AppRoutes.user,
                                        arguments: {'userId': user['userId']});
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      user['userName'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['userEmail']),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['userPassword']),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['userId']),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    user['userAge'].toString(),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    user['userGender'],
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    formatter.format(user['userMoney']),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    formatter.format(user['userSpend']),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['createdAt'].toString()),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
                              ),
                              TableCell(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(user['modifiedAt'].toString()),
                                ),
                                verticalAlignment:
                                    TableCellVerticalAlignment.middle,
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
