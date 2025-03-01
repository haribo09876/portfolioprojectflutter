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
    'Male': 'Male',
    'Female': 'Female',
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
        _showErrorDialog('Email or username cannot be empty.');
        return;
      }

      final checkUserResponse =
          await _signupService.checkUser(userEmail, userName);

      if (checkUserResponse == null) {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('No response from server.');
        return;
      }

      final status = checkUserResponse['status'];
      if (status == 'exists') {
        setState(() {
          _isSubmitting = false;
        });
        _showErrorDialog('Email or username already exists.');
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
        final errorMessage =
            createUserResponse['message'] ?? 'Sign up error occurred.';
        _showErrorDialog(errorMessage);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
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
          content: Text('Sign up completed successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign up')),
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
                        decoration: InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          userName = value;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          userEmail = value;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password.';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          userPassword = value;
                        },
                      ),
                      SizedBox(height: 15),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(labelText: 'Gender'),
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
                      SizedBox(height: 15),
                      TextFormField(
                        decoration: InputDecoration(labelText: 'Age'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your age';
                          }
                          final n = num.tryParse(value);
                          if (n == null || n <= 0) {
                            return 'Please enter proper age';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          userAge = int.parse(value);
                        },
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 340,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff3498db),
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          onPressed: _signup,
                          child: Text(
                            'Sign up',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.white,
                            ),
                          ),
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
