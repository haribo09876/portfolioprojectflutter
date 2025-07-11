import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../routes.dart';
import '../services/login.dart';
import 'homePage.dart';
import 'tweetPage.dart';
import 'instaPage.dart';
import 'shopPage.dart';

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late String userId;

  String? adminId = dotenv.env['ADMIN_ID'];

  @override
  Widget build(BuildContext context) {
    // Access login state via Provider (Provider를 통해 로그인 상태 접근)
    final loginService = Provider.of<LoginService>(context);
    // Extract user ID from user info map (사용자 정보에서 ID 추출)
    userId = loginService.userInfo?['id'] ?? '';

    return DefaultTabController(
      // Number of tabs in the TabBar (탭바의 탭 개수)
      length: 4,
      child: Scaffold(
        // Scaffold background color (배경색 설정)
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          // AppBar background color (앱바 배경색)
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          // Center the title text (타이틀 가운데 정렬)
          centerTitle: true,
          title: Text(
            'PPF',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
          ),
          // Remove AppBar shadow (앱바 그림자 제거)
          elevation: 0,
          // Disable back button (뒤로가기 버튼 비활성화)
          automaticallyImplyLeading: false,
          bottom: PreferredSize(
            // Height of the TabBar container (탭바 높이 지정)
            preferredSize: Size.fromHeight(48),
            child: Center(
              child: SizedBox(
                // Fixed width for the TabBar container (탭바 가로 너비 고정)
                width: 340,
                // Fixed height for the TabBar container (탭바 세로 높이 고정)
                height: 40,
                child: Container(
                  decoration: BoxDecoration(
                    // TabBar background color (탭바 배경색)
                    color: Color.fromARGB(242, 242, 242, 242),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  // Clip overflow for rounded corners (오버플로우 클리핑)
                  clipBehavior: Clip.hardEdge,
                  child: TabBar(
                    // Active tab label color (선택된 탭 텍스트 색상)
                    labelColor: Colors.white,
                    // Inactive tab label color (비선택 탭 텍스트 색상)
                    unselectedLabelColor: Color.fromRGBO(52, 52, 52, 52),
                    indicator: BoxDecoration(
                      // Indicator background color (인디케이터 배경색)
                      color: Color(0xff333333),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    // Indicator size matches tab size (인디케이터 크기 탭과 동일)
                    indicatorSize: TabBarIndicatorSize.tab,
                    // Horizontal padding inside each tab (탭 내부 좌우 패딩)
                    labelPadding: EdgeInsets.symmetric(horizontal: 15),
                    // Define tabs with text labels (텍스트 라벨이 있는 탭 정의)
                    tabs: [
                      Tab(text: 'Home'),
                      Tab(text: 'Tweet'),
                      Tab(text: 'Insta'),
                      Tab(text: 'Shop'),
                    ],
                  ),
                ),
              ),
            ),
          ),
          actions: [
            if (userId == adminId)
              IconButton(
                icon: Icon(
                  Icons.book_outlined,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
                onPressed: () {
                  // Navigate to admin dashboard (관리자 대시보드로 이동)
                  Navigator.pushNamed(context, AppRoutes.dashboard);
                },
              ),
            IconButton(
              icon: Icon(
                Icons.person_2_outlined,
                color: Color.fromRGBO(52, 52, 52, 52),
              ),
              onPressed: () {
                // Navigate to user profile page (사용자 프로필 페이지로 이동)
                Navigator.pushNamed(context, AppRoutes.user);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout_outlined,
                color: Color.fromRGBO(52, 52, 52, 52),
              ),
              onPressed: () async {
                // Show logout confirmation dialog (로그아웃 확인 다이얼로그 표시)
                bool shouldLogout = await showDialog<bool>(
                      context: context,
                      // Prevent dismiss by tapping outside (외부 터치로 닫기 방지)
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Color.fromARGB(255, 255, 255, 255),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          title: Text(
                            'Log out',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          content: SizedBox(
                            width: 360,
                            height: 120,
                            child: Center(
                              // Confirmation message (확인 메시지)
                              child: Text(
                                'Are you sure you want to log out?',
                                style: TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          actions: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // Logout button color (로그아웃 버튼 색상)
                                backgroundColor: Color(0xFFF04452),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () async {
                                // Confirm logout (로그아웃 확인)
                                Navigator.of(context).pop(true);
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    'Log out',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // Cancel button background (취소 버튼 배경색)
                                backgroundColor:
                                    Color.fromARGB(242, 242, 242, 242),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () {
                                // Cancel logout (로그아웃 취소)
                                Navigator.of(context).pop(false);
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Color.fromRGBO(52, 52, 52, 52),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;
                if (shouldLogout) {
                  // Trigger logout logic in service (서비스에서 로그아웃 처리)
                  await loginService.logoutUser();
                  // Navigate to login page (로그인 페이지로 이동)
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
            SizedBox(width: 5),
          ],
        ),
        body: TabBarView(
          children: [
            HomePage(),
            TweetPage(),
            InstaPage(),
            ShopPage(),
          ],
        ),
      ),
    );
  }
}
