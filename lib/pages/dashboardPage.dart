import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard Page'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '일자별 매출액',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardShop(),
              SizedBox(height: 20),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Text(
                  '접속 위치',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              DashboardLocation(),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardShop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('DashboardShop Component'),
    );
  }
}

class DashboardLocation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('DashboardLocation Component'),
    );
  }
}
