import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Map<String, List<LatLng>> locations = {};
  List<String> labels = [];
  List<String> legend = [];
  List<List<double>> data = [];
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchLocationData();
    fetchSalesData();
  }

  Future<void> fetchLocationData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('locations').get();
      Map<String, List<LatLng>> groupedData = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> location = doc.data();
        String date = (location['createdAt'] as Timestamp)
            .toDate()
            .toString()
            .split(' ')[0];
        String city = location['city'];
        double latitude = location['latitude'];
        double longitude = location['longitude'];

        if (!groupedData.containsKey(city)) {
          groupedData[city] = [];
        }
        groupedData[city]!.add(LatLng(latitude, longitude));
      }

      setState(() {
        locations = groupedData;
      });
    } catch (e) {
      print('Error fetching location data: $e');
    }
  }

  Future<void> fetchSalesData() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('sales').get();
      Map<String, Map<String, double>> groupedData = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> sale = doc.data();
        String date =
            (sale['createdAt'] as Timestamp).toDate().toString().split(' ')[0];
        String itemTitle = sale['itemTitle'];
        double itemPrice = sale['itemPrice'];

        if (!groupedData.containsKey(date)) {
          groupedData[date] = {};
        }
        if (!groupedData[date]!.containsKey(itemTitle)) {
          groupedData[date]![itemTitle] = 0;
        }
        groupedData[date]![itemTitle] =
            (groupedData[date]![itemTitle] ?? 0) + itemPrice;
      }

      setState(() {
        labels = groupedData.keys.toList()..sort();
        legend = groupedData.values.expand((e) => e.keys).toSet().toList();
        data = labels.map((date) {
          return legend.map((title) => groupedData[date]![title] ?? 0).toList();
        }).toList();
        loading = false;
      });
    } catch (e) {
      print('Error fetching sales data: $e');
      setState(() {
        error = 'Failed to fetch data';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    if (error.isNotEmpty) {
      return Center(
          child:
              Text(error, style: TextStyle(color: Colors.red, fontSize: 18)));
    }

    return Scaffold(
      appBar: AppBar(title: Text('Dashboard')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(37.5665, 126.9780),
                  zoom: 10,
                ),
                markers: locations.values.expand((e) => e).map((location) {
                  return Marker(
                    markerId: MarkerId(location.toString()),
                    position: location,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueBlue),
                  );
                }).toSet(),
              ),
            ),
            Container(
              height: 360,
              padding: EdgeInsets.all(10),
              child: BarChart(
                BarChartData(
                  barGroups: data.asMap().entries.map((entry) {
                    int index = entry.key;
                    List<double> values = entry.value;

                    return BarChartGroupData(
                      x: index,
                      barRods: values.asMap().entries.map((e) {
                        return BarChartRodData(
                          y: e.value,
                          colors: [
                            Colors.blue,
                            Colors.orange,
                            Colors.green,
                            Colors.purple
                          ],
                          width: 20,
                        );
                      }).toList(),
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    bottomTitles: SideTitles(
                      showTitles: true,
                      getTitles: (double value) => labels[value.toInt()],
                      margin: 10,
                      rotateAngle: 90,
                    ),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTitles: (double value) => value.toString(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
