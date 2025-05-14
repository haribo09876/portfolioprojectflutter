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
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Sign up error',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(242, 242, 242, 242),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(52, 52, 52, 52),
                    ),
                  ),
                ),
              ),
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
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Sign up success',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Sign up completed successfully.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(242, 242, 242, 242),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(52, 52, 52, 52),
                    ),
                  ),
                ),
              ),
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

      if (_image == null) {
        _showErrorDialog('Please select an image.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

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

      String imageBase64 = await _convertImageToBase64(_image!);

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
          maxLines: 1,
          keyboardType: TextInputType.multiline,
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
        child: DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          style: TextStyle(
            color: Color.fromRGBO(52, 52, 52, 52),
          ),
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(
                color: Color(0xFF44558C8),
                width: 1.5,
              ),
            ),
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
      appBar: AppBar(
        title: Text('Sign up'),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
      ),
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  ClipOval(
                    child: _image != null
                        ? Image.file(
                            _image!,
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          )
                        : CircleAvatar(
                            radius: 50,
                            backgroundColor: Color.fromARGB(242, 242, 242, 242),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color.fromRGBO(52, 52, 52, 52),
                            ),
                          ),
                  ),
                  if (_image != null)
                    Positioned(
                      top: 67,
                      left: 67,
                      child: IconButton(
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(
                            () {
                              _image = null;
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
              SizedBox(height: 10),
              Form(
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
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(242, 242, 242, 242),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () async {
                        await _pickImage();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Add image',
                            style: TextStyle(
                              color: Color.fromRGBO(52, 52, 52, 52),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
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
            ],
          ),
        ),
      ),
    );
  }
}
