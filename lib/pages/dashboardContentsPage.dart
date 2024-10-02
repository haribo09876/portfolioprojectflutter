import 'package:flutter/material.dart';
import '../services/dashboard.dart';

class DashboardContentsPage extends StatelessWidget {
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
                  'Insta Image',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsInstaImage(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Insta Text',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsInstaText(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Tweet Image',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsTweetImage(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  'Tweet Text',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardContentsTweetText(),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardContentsInstaImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Insta Image Component'),
    );
  }
}

class DashboardContentsInstaText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Insta Text Component'),
    );
  }
}

class DashboardContentsTweetImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Tweet Image Component'),
    );
  }
}

class DashboardContentsTweetText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Tweet Text Component'),
    );
  }
}
