import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
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
              DashboardUsersLocation(),
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

class DashboardUsersInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Info Component'),
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

  @override
  void initState() {
    super.initState();

    mapController = MapController(
      initPosition: GeoPoint(
        latitude: 37.422,
        longitude: -122.084,
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
      });
    } catch (e) {
      print('Error loading locations: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: OSMFlutter(
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
              mapController.addMarker(point);
            }
          }
        },
      ),
    );
  }
}

class DashboardUsersSearch extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Search Component'),
    );
  }
}
