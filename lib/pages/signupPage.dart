import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  int userMoney = 1000000;
  int userSpend = 0;

  bool _isSubmitting = false;
  File? _image;

  final Map<String, String> _genderOptions = {
    'Male': '남성',
    'Female': '여성',
  };

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _image = File(image.path);
      });
    }
  }

  Future<String> _convertImageToBase64(File image) async {
    final bytes = await image.readAsBytes();
    return base64Encode(bytes);
  }

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      if (userEmail.isEmpty || userName.isEmpty) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('이메일 또는 닉네임이 비어 있습니다.');
        return;
      }

      final checkUserResponse =
          await _signupService.checkUser(userEmail, userName);

      if (checkUserResponse == null) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('서버 응답이 없습니다.');
        return;
      }

      final status = checkUserResponse['status'];
      if (status == 'exists') {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('사용자 이메일 또는 이름이 중복됩니다.');
        return;
      }

      String? imageBase64;
      if (_image != null) {
        imageBase64 = await _convertImageToBase64(_image!);
      }

      final userInfo = {
        'userEmail': userEmail,
        'userPassword': userPassword,
        'userName': userName,
        'userGender': userGender,
        'userAge': userAge,
        'userMoney': userMoney,
        'userSpend': userSpend,
        'fileContent': imageBase64 ?? '',
      };

      final createUserResponse = await _signupService.createUser(userInfo);

      setState(() {
        _isSubmitting = false;
      });

      if (createUserResponse['status'] == 'success') {
        _showSuccessDialog();
      } else {
        final errorMessage = createUserResponse['message'] ?? '회원가입 오류 발생';
        _showErrorDialog(errorMessage);
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
          content: Text('회원가입이 완료되었습니다.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('회원가입')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.person, size: 50, color: Colors.grey[600])
                      : null,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
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
                      SizedBox(height: 16),
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
                      SizedBox(height: 16),
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
                      SizedBox(height: 16),
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
                                  child: Text(entry.value),
                                  value: entry.key,
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 16),
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
                      SizedBox(
                        width: double.infinity,
                        child: _isSubmitting
                            ? Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: _signup,
                                child: Text('회원가입'),
                              ),
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
