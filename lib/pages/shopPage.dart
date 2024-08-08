import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/login.dart';

class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
      ),
      body: Center(
        child: loginService.isLoggedIn
            ? Text('환영합니다, ${loginService.userEmail}님!',
                style: TextStyle(fontSize: 24))
            : Text('로그인 후에 쇼핑할 수 있습니다.', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
