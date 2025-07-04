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
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          title: Text(
            'Dashboard Page',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(48),
            child: Center(
              child: SizedBox(
                width: 340,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromARGB(242, 242, 242, 242),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Color.fromRGBO(52, 52, 52, 52),
                    indicator: BoxDecoration(
                      color: Color(0xff333333),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelPadding: EdgeInsets.symmetric(horizontal: 15),
                    tabs: [
                      Tab(text: 'Users'),
                      Tab(text: 'Contents'),
                      Tab(text: 'Sales'),
                    ],
                  ),
                ),
              ),
            ),
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
