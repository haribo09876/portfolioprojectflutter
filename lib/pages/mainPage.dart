import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../routes.dart';
import '../services/login.dart';
import 'homePage.dart';
import 'tweetPage.dart';
import 'instaPage.dart';
import 'shopPage.dart';

class MainPage extends StatelessWidget {
  late String userId;
  String? adminId = dotenv.env['ADMIN_ID'];

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);
    userId = loginService.userInfo?['id'] ?? '';

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('                   PPF'),
          ),
          automaticallyImplyLeading: false,
          bottom: TabBar(
            tabs: [
              Tab(text: 'Home'),
              Tab(text: 'Tweet'),
              Tab(text: 'Insta'),
              Tab(text: 'Shop'),
            ],
          ),
          actions: [
            if (userId == adminId)
              IconButton(
                icon: Icon(Icons.book_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.dashboard);
                },
              ),
            IconButton(
              icon: Icon(Icons.person_2_outlined),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.user);
              },
            ),
            IconButton(
              icon: Icon(Icons.logout_outlined),
              onPressed: () async {
                bool shouldLogout = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Log out'),
                          content: Text('Are you sure you want to log out?'),
                          actions: <Widget>[
                            TextButton(
                              child: Text('Log out'),
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                            ),
                            TextButton(
                              child: Text('Cancel'),
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;

                if (shouldLogout) {
                  // Perform logout
                  await loginService.logoutUser();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                }
              },
            ),
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
