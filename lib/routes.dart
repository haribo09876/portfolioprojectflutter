import 'package:flutter/material.dart';
import 'pages/introPage.dart';
import 'pages/loginPage.dart';
import 'pages/signupPage.dart';
import 'pages/mainPage.dart';
import 'pages/homePage.dart';
import 'pages/tweetPage.dart';
import 'pages/instaPage.dart';
import 'pages/shopPage.dart';
import 'pages/userPage.dart';
import 'pages/dashboardPage.dart';
import 'pages/dashboardUsersPage.dart';
import 'pages/dashboardContentsPage.dart';
import 'pages/dashboardSalesPage.dart';

class AppRoutes {
  static const String intro = '/';
  static const String login = '/loginPage';
  static const String signup = '/signupPage';
  static const String main = '/mainPage';
  static const String home = '/homePage';
  static const String tweet = '/tweetPage';
  static const String insta = '/instaPage';
  static const String shop = '/shopPage';
  static const String user = '/userPage';
  static const String dashboard = '/dashboardPage';
  static const String dashboardUsers = '/dashboardUsersPage';
  static const String dashboardContents = '/dashboardContentsPage';
  static const String dashboardSales = '/dashboardSalesPage';

  static final routes = <String, WidgetBuilder>{
    intro: (BuildContext context) => IntroPage(),
    login: (BuildContext context) => LoginPage(),
    signup: (BuildContext context) => SignupPage(),
    main: (BuildContext context) => MainPage(),
    home: (BuildContext context) => HomePage(),
    tweet: (BuildContext context) => TweetPage(),
    insta: (BuildContext context) => InstaPage(),
    shop: (BuildContext context) => ShopPage(),
    user: (BuildContext context) => UserPage(),
    dashboard: (BuildContext context) => DashboardPage(),
    dashboardUsers: (BuildContext context) => DashboardUsersPage(),
    dashboardContents: (BuildContext context) => DashboardContentsPage(),
    dashboardSales: (BuildContext context) => DashboardSalesPage(),
  };
}
