import 'package:flutter/material.dart';
import '../routes.dart';

class IntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Top spacing (상단 여백)
            SizedBox(height: 50),
            Text(
              'Welcome to PPF',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w600,
                color: Color(0xff333333),
              ),
              // Center align text (텍스트 중앙 정렬)
              textAlign: TextAlign.center,
            ),
            Text(
              'Portfolio Project with Flutter and AWS',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color.fromRGBO(89, 89, 89, 89),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 250),
            SizedBox(
              // Fixed width for button (버튼 너비 고정)
              width: 340,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF44558C8),
                  // Remove shadow (그림자 제거)
                  elevation: 0,
                  // Internal padding (내부 여백)
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                // Navigate to login page (로그인 페이지로 이동)
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.login);
                },
                child: Text(
                  'Get started',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
