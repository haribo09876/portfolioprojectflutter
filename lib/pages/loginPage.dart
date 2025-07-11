import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../routes.dart';
import '../services/login.dart';

// Stateful login page widget (상태 기반 로그인 페이지 위젯)
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Controller for email input field (이메일 입력 필드용 컨트롤러)
  final TextEditingController _emailController = TextEditingController();
  // Controller for password input field (비밀번호 입력 필드용 컨트롤러)
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  // Handles the login action using the LoginService (LoginService를 통한 로그인 처리)
  void _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Get login service from provider (Provider로부터 로그인 서비스 획득)
    final loginService = Provider.of<LoginService>(context, listen: false);
    final result = await loginService.loginUser(
        _emailController.text, _passwordController.text);

    setState(() {
      _isLoading = false;
    });

    // Navigate to main page on success, show error otherwise (성공 시 메인 페이지로 이동, 실패 시 에러 표시)
    if (result['success']) {
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } else {
      setState(() {
        _errorMessage = result['error'];
      });
    }
  }

  // Clean up controllers when widget is disposed (위젯 dispose 시 컨트롤러 해제)
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // UI build method for login page (로그인 페이지 UI 빌드 메서드)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              // Application logo or title (앱 로고 또는 제목)
              Text(
                'PPF',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 40),
              // Email input field (이메일 입력 필드)
              _buildTextField(
                controller: _emailController,
                hintText: ' Email',
              ),
              // Password input field (비밀번호 입력 필드)
              _buildTextField(
                controller: _passwordController,
                hintText: ' Password',
                obscureText: true,
              ),
              SizedBox(height: 125),
              // Display error message if present (에러 메시지가 있을 경우 출력)
              if (_errorMessage != null) ...[
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Colors.red),
                ),
              ],
              SizedBox(height: 15),
              // Show loading spinner or login button (로딩 중이면 스피너, 아니면 로그인 버튼 표시)
              _isLoading
                  ? CircularProgressIndicator()
                  : _buildButton('Log in', _handleLogin),
              SizedBox(height: 10),
              // Navigation to signup page (회원가입 페이지로 이동)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(242, 242, 242, 242),
                  elevation: 0,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.signup);
                },
                child: SizedBox(
                  width: 280,
                  child: Center(
                    child: Text(
                      'Sign up',
                      style: TextStyle(
                        color: Color.fromRGBO(52, 52, 52, 52),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Custom reusable text input field (재사용 가능한 텍스트 입력 필드 위젯)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        width: 340,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(
                color: Color(0xFF44558C8),
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Custom reusable elevated button widget (재사용 가능한 커스텀 버튼 위젯)
  Widget _buildButton(
    String text,
    VoidCallback onPressed, {
    Color color = const Color(0xFF44558C8),
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        width: 340,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            elevation: 0,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
