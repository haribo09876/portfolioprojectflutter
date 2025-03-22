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
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();

  String userGender = 'Male';
  int userMoney = 1000000;
  int userSpend = 0;
  bool _isSubmitting = false;
  File? _image;

  final Map<String, String> _genderOptions = {
    'Male': 'Male',
    'Female': 'Female',
  };

  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  final RegExp nameRegex = RegExp(r"^[a-zA-Z가-힣0-9]{2,20}$");
  final RegExp ageRegex = RegExp(r'^[1-9][0-9]?$|^120$');

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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sign up error'),
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
          title: Text('Sign up success'),
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

  void _signup() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSubmitting = true;
      });

      String userEmail = _emailController.text.trim();
      String userPassword = _passwordController.text;
      String userName = _nameController.text.trim();
      int userAge = int.tryParse(_ageController.text) ?? 0;

      if (!emailRegex.hasMatch(userEmail)) {
        _showErrorDialog('Invalid email format.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (!nameRegex.hasMatch(userName)) {
        _showErrorDialog('Invalid username. Must be 2-20 characters.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (!ageRegex.hasMatch(userAge.toString())) {
        _showErrorDialog('Invalid age. Must be between 1 and 120.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      final checkUserResponse =
          await _signupService.checkUser(userEmail, userName);

      if (checkUserResponse == null) {
        _showErrorDialog('No response from server.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (checkUserResponse['status'] == 'exists') {
        _showErrorDialog('Email or username already exists.');
        setState(() {
          _isSubmitting = false;
        });
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
        _showErrorDialog(
            createUserResponse['message'] ?? 'Sign up error occurred.');
      }
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 360,
        child: TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Color.fromRGBO(52, 52, 52, 52),
            ),
            filled: true,
            fillColor: Color.fromARGB(242, 242, 242, 242),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required void Function(String?) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 360,
        decoration: BoxDecoration(
          color: Color.fromARGB(242, 242, 242, 242),
          borderRadius: BorderRadius.circular(50),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: TextStyle(
            color: Color.fromRGBO(52, 52, 52, 52),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
          items: _genderOptions.entries.map((entry) {
            return DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value),
            );
          }).toList(),
        ),
      ),
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
                  backgroundColor: Color.fromARGB(242, 242, 242, 242),
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? Icon(Icons.person,
                          size: 50, color: Color.fromRGBO(52, 52, 52, 52))
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
                      _buildTextField(
                        controller: _nameController,
                        hintText: ' Username',
                        validator: (value) =>
                            value != null && nameRegex.hasMatch(value)
                                ? null
                                : 'Invalid username',
                      ),
                      _buildTextField(
                        controller: _emailController,
                        hintText: ' Email',
                        validator: (value) =>
                            value != null && emailRegex.hasMatch(value)
                                ? null
                                : 'Invalid email',
                      ),
                      _buildTextField(
                        controller: _passwordController,
                        hintText: ' Password',
                        obscureText: true,
                        validator: (value) => value != null && value.length >= 6
                            ? null
                            : 'Password must be at least 6 characters',
                      ),
                      _buildTextField(
                        controller: _ageController,
                        hintText: ' Age',
                        validator: (value) =>
                            value != null && ageRegex.hasMatch(value)
                                ? null
                                : 'Invalid age',
                      ),
                      _buildDropdownField(
                        value: userGender,
                        onChanged: (value) {
                          setState(() {
                            userGender = value!;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      SizedBox(
                        width: 360,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _signup,
                          child: _isSubmitting
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Sign up',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xff4A7FF7),
                            elevation: 0,
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
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
