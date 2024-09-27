import 'package:flutter/material.dart';
import 'dashboardUsersPage.dart';
import 'dashboardContentsPage.dart';
import 'dashboardSalesPage.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('            Dashboard'),
          automaticallyImplyLeading: true,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Users'),
              Tab(text: 'Contents'),
              Tab(text: 'Sales'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            DashboardUsersPage(),
            DashboardContentsPage(),
            DashboardSalesPage(),
          ],
        ),
      ),
    );
  }
}
