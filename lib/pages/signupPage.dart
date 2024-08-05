import 'package:flutter/material.dart';
import '../services/signup.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final SignupService _signupService = SignupService();

  String userEmail = '';
  String userPassword = '';
  String userName = '';
  String userGender = 'Male';
  int userAge = 0;
  int userMoney = 100000;
  int userSpend = 0;

  bool _isSubmitting = false;

  final Map<String, String> _genderOptions = {
    'Male': '남성',
    'Female': '여성',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(labelText: '닉네임'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '닉네임을 입력하세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  userName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '이메일'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '이메일을 입력하세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  userEmail = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '비밀번호'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '비밀번호를 입력하세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  userPassword = value;
                },
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: '성별'),
                value: userGender,
                onChanged: (value) {
                  setState(() {
                    userGender = value!;
                  });
                },
                items: _genderOptions.entries
                    .map((entry) => DropdownMenuItem(
                          child: Text(entry.value), // Display Korean text
                          value: entry.key, // Internal value
                        ))
                    .toList(),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: '나이'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '나이를 입력하세요';
                  }
                  final n = num.tryParse(value);
                  if (n == null || n <= 0) {
                    return '올바른 나이를 입력하세요';
                  }
                  return null;
                },
                onChanged: (value) {
                  userAge = int.parse(value);
                },
              ),
              SizedBox(height: 20),
              _isSubmitting
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _signup,
                      child: Text('Signup'),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      final checkUserResponse =
          await _signupService.checkUser(userEmail, userName);
      if (checkUserResponse['status'] == 'exists') {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('사용자 이메일 또는 이름이 중복됩니다.');
        return;
      }

      final userInfo = {
        'userEmail': userEmail,
        'userPassword': userPassword,
        'userName': userName,
        'userGender': userGender,
        'userAge': userAge,
        'userMoney': userMoney,
        'userSpend': userSpend,
      };

      final createUserResponse = await _signupService.createUser(userInfo);

      setState(() {
        _isSubmitting = false;
      });

      if (createUserResponse['status'] == 'success') {
        _showSuccessDialog();
      } else {
        _showErrorDialog(createUserResponse['message']);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('오류'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('성공'),
          content: Text('회원가입이 완료되었습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context)
                    .pop(); // Pop twice to go back to the previous screen
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
