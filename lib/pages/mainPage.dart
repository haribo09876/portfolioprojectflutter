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
    final loginService = Provider.of<LoginService>(context);
    userId = loginService.userInfo?['id'] ?? '';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          centerTitle: true,
          title: Text(
            'PPF',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w500,
            ),
          ),
          elevation: 0,
          automaticallyImplyLeading: false,
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
                  Navigator.pushNamed(context, AppRoutes.dashboard);
                },
              ),
            IconButton(
              icon: Icon(
                Icons.person_2_outlined,
                color: Color.fromRGBO(52, 52, 52, 52),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.user);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.logout_outlined,
                color: Color.fromRGBO(52, 52, 52, 52),
              ),
              onPressed: () async {
                bool shouldLogout = await showDialog<bool>(
                      context: context,
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
                                backgroundColor: Color(0xFFF04452),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () async {
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
                                backgroundColor:
                                    Color.fromARGB(242, 242, 242, 242),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () {
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
                  await loginService.logoutUser();
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
