import 'package:flutter/material.dart';
import 'dashboardUsersPage.dart';
import 'dashboardContentsPage.dart';
import 'dashboardSalesPage.dart';

class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // Number of tabs (탭 개수 설정)
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
          // Remove shadow (앱바 그림자 제거)
          elevation: 0,
          bottom: PreferredSize(
            // Custom height for TabBar container (탭바 높이 지정)
            preferredSize: Size.fromHeight(48),
            child: Center(
              child: SizedBox(
                width: 340,
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    // Tab container background (탭 배경색)
                    color: Color.fromARGB(242, 242, 242, 242),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  // Enforce border radius clipping (클리핑 적용)
                  clipBehavior: Clip.hardEdge,
                  child: TabBar(
                    // Selected tab text color (선택된 탭 텍스트 색상)
                    labelColor: Colors.white,
                    // Unselected tab text color (비선택 텍스트 색상)
                    unselectedLabelColor: Color.fromRGBO(52, 52, 52, 52),
                    indicator: BoxDecoration(
                      // Active tab background (활성 탭 배경색)
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
