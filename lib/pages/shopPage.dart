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
            ? Text(
                '- 환영합니다, ${loginService.userInfo?['name']}님!\n'
                '- 아이디: ${loginService.userInfo?['id']}\n'
                '- 이메일: ${loginService.userInfo?['email']}\n'
                '- 비밀번호: ${loginService.userInfo?['password']}\n'
                '- 성별: ${loginService.userInfo?['gender']}\n'
                '- 연령: ${loginService.userInfo?['age']}\n'
                '- 소지금: ${loginService.userInfo?['money']}\n'
                '- 소비액: ${loginService.userInfo?['spend']}\n'
                '- URL: ${loginService.userInfo?['imgURL']}',
                style: TextStyle(fontSize: 20),
              )
            : Text(
                '- 로그인 후에 쇼핑할 수 있습니다.',
                style: TextStyle(fontSize: 20),
              ),
      ),
    );
  }
}
