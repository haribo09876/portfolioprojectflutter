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
  // Form validation key (폼 유효성 검사 키)
  final _formKey = GlobalKey<FormState>();
  // Signup API service instance (회원가입 API 서비스 인스턴스)
  final SignupService _signupService = SignupService();
  // Email input controller (이메일 입력 컨트롤러)
  final TextEditingController _emailController = TextEditingController();
  // Password input controller (비밀번호 입력 컨트롤러)
  final TextEditingController _passwordController = TextEditingController();
  // Username input controller (사용자명 입력 컨트롤러)
  final TextEditingController _nameController = TextEditingController();
  // Age input controller (나이 입력 컨트롤러)
  final TextEditingController _ageController = TextEditingController();

  // Default gender value (기본 성별 값)
  String userGender = 'Male';
  // Initial user money (초기 사용자 자금)
  int userMoney = 1000000;
  // Initial user spending (초기 사용자 지출)
  int userSpend = 0;
  // Submission state flag (제출 상태 플래그)
  bool _isSubmitting = false;
  // Selected profile image file (선택된 프로필 이미지 파일)
  File? _image;

  // Gender dropdown options (성별 드롭다운 옵션)
  final Map<String, String> _genderOptions = {
    'Male': 'Male',
    'Female': 'Female',
  };

  // Email validation regex (이메일 유효성 검사 정규식)
  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  // Username validation regex (사용자명 유효성 검사 정규식)
  final RegExp nameRegex = RegExp(r"^[a-zA-Z가-힣0-9]{2,20}$");
  // Age validation regex (나이 유효성 검사 정규식)
  final RegExp ageRegex = RegExp(r'^[1-9][0-9]?$|^120$');

  Future<void> _pickImage() async {
    // Image picker instance (이미지 픽커 인스턴스)
    final ImagePicker _picker = ImagePicker();
    // Select image from gallery (갤러리에서 이미지 선택)
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        // Update image file state (이미지 파일 상태 업데이트)
        _image = File(image.path);
      });
    }
  }

  Future<String> _convertImageToBase64(File image) async {
    // Read image bytes asynchronously (이미지 바이트 비동기 읽기)
    final bytes = await image.readAsBytes();
    // Convert bytes to Base64 string (바이트를 Base64 문자열로 변환)
    return base64Encode(bytes);
  }

  void _showErrorDialog(String message) {
    // Display error alert dialog (오류 알림 대화상자 표시)
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
                // Close dialog on cancel (취소 시 대화상자 닫기)
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
    // Display success alert dialog (성공 알림 대화상자 표시)
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
    // Form validation and signup workflow (폼 유효성 검사 및 회원가입 워크플로우)
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        // Disable button and show loading (버튼 비활성화 및 로딩 표시)
        _isSubmitting = true;
      });

      String userEmail = _emailController.text.trim();
      String userPassword = _passwordController.text;
      String userName = _nameController.text.trim();
      int userAge = int.tryParse(_ageController.text) ?? 0;

      if (_image == null) {
        // Require profile image (프로필 이미지 필수)
        _showErrorDialog('Please select an image.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (!emailRegex.hasMatch(userEmail)) {
        // Email format validation (이메일 형식 검증)
        _showErrorDialog('Invalid email format.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (!nameRegex.hasMatch(userName)) {
        // Username length and character check (사용자명 길이 및 문자 체크)
        _showErrorDialog('Invalid username. Must be 2-20 characters.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (!ageRegex.hasMatch(userAge.toString())) {
        // Age range validation (나이 범위 검증)
        _showErrorDialog('Invalid age. Must be between 1 and 120.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Check if user/email exists (사용자/이메일 존재 여부 확인)
      final checkUserResponse =
          await _signupService.checkUser(userEmail, userName);

      if (checkUserResponse == null) {
        // Handle server no-response (서버 응답 없음 처리)
        _showErrorDialog('No response from server.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      if (checkUserResponse['status'] == 'exists') {
        // Duplicate user error (중복 사용자 오류)
        _showErrorDialog('Email or username already exists.');
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // Convert image file to Base64 string (이미지 파일을 Base64 문자열로 변환)
      String imageBase64 = await _convertImageToBase64(_image!);

      // Construct user data payload (사용자 데이터 페이로드 생성)
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

      // Create user API call (사용자 생성 API 호출)
      final createUserResponse = await _signupService.createUser(userInfo);

      setState(() {
        // Reset submitting flag (제출 상태 플래그 리셋)
        _isSubmitting = false;
      });

      if (createUserResponse['status'] == 'success') {
        // Show success dialog (성공 대화상자 표시)
        _showSuccessDialog();
      } else {
        _showErrorDialog(
            // Show error message (오류 메시지 표시)
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
    // Custom reusable text input widget with validation (재사용 가능한 텍스트 입력 위젯 및 검증)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 360,
        child: TextFormField(
          controller: controller,
          // Hide text for passwords (비밀번호 텍스트 숨김)
          obscureText: obscureText,
          // Input validation function (입력 검증 함수)
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
    // Gender selection dropdown widget (성별 선택 드롭다운 위젯)
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Container(
        width: 360,
        child: DropdownButtonFormField<String>(
          value: value,
          // Dropdown onChanged callback (드롭다운 변경 콜백)
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
          // Map gender options to dropdown items (성별 옵션을 드롭다운 항목으로 매핑)
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
                          ) // Display selected image (선택된 이미지 표시)
                        : CircleAvatar(
                            radius: 50,
                            backgroundColor: Color.fromARGB(242, 242, 242, 242),
                            child: Icon(
                              Icons.person,
                              size: 50,
                              color: Color.fromRGBO(52, 52, 52, 52),
                            ),
                          ), // Default avatar placeholder (기본 아바타 플레이스홀더)
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
                              _image =
                                  null; // Remove selected image (선택된 이미지 제거)
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
                      validator: (value) => value != null &&
                              nameRegex.hasMatch(value)
                          ? null
                          : 'Invalid username', // Username validation message (사용자명 유효성 메시지)
                    ),
                    _buildTextField(
                      controller: _emailController,
                      hintText: ' Email',
                      validator: (value) => value != null &&
                              emailRegex.hasMatch(value)
                          ? null
                          : 'Invalid email', // Email validation message (이메일 유효성 메시지)
                    ),
                    _buildTextField(
                      controller: _passwordController,
                      hintText: ' Password',
                      obscureText: true,
                      validator: (value) => value != null && value.length >= 6
                          ? null
                          : 'Password must be at least 6 characters', // Password length check (비밀번호 길이 검사)
                    ),
                    _buildTextField(
                      controller: _ageController,
                      hintText: ' Age',
                      validator: (value) => value != null &&
                              ageRegex.hasMatch(value)
                          ? null
                          : 'Invalid age', // Age validation message (나이 유효성 메시지)
                    ),
                    _buildDropdownField(
                      value: userGender,
                      onChanged: (value) {
                        setState(() {
                          userGender =
                              value!; // Update gender on selection (선택 시 성별 업데이트)
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 360,
                      child: ElevatedButton(
                        onPressed: () async {
                          // Trigger image picker (이미지 픽커 실행)
                          await _pickImage();
                        },
                        child: Text(
                          'Add image',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(52, 52, 52, 52),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(242, 242, 242, 242),
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10),
                    SizedBox(
                      width: 360,
                      child: ElevatedButton(
                        // Disable when submitting (제출 중 비활성화)
                        onPressed: _isSubmitting ? null : _signup,
                        child: _isSubmitting
                            ? CircularProgressIndicator(
                                color:
                                    Colors.white) // Loading indicator (로딩 표시)
                            : Text(
                                'Sign up',
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF44558C8),
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
