import 'package:flutter/material.dart';
import '../routes.dart';
import 'homePage.dart';
import 'tweetPage.dart';
import 'instaPage.dart';
import 'shopPage.dart';

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('PPF'),
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
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.login);
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
