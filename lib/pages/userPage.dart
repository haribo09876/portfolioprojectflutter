import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../routes.dart';
import '../services/login.dart';
import '../services/userInfo.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late String userId;
  late Future<Map<String, dynamic>> allData;
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Retrieve userId from arguments or fallback to login info (인자 또는 로그인 정보에서 사용자 ID 설정)
    final loginService = Provider.of<LoginService>(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userId = args?['userId'] ?? loginService.userInfo?['id'] ?? '';

    // Trigger data fetching (데이터 가져오기 실행)
    _fetchData();
  }

  // Fetch user, tweet, insta, and purchase data asynchronously (비동기적으로 사용자 관련 모든 데이터 가져오기)
  void _fetchData() {
    setState(() {
      allData = Future.wait([
        UserService().userRead(userId),
        TweetService().tweetRead(userId),
        InstaService().instaRead(userId),
        ShopService().purchaseRead(userId),
      ]).then((responses) {
        return {
          'userData': responses[0],
          'tweetData': responses[1],
          'instaData': responses[2],
          'purchaseData': responses[3],
        };
      });
    });
  }

  // Show error dialog with a custom message (에러 메시지를 포함한 다이얼로그 표시)
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
          title: Text('Image error',
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

  // Update user profile with optional image (선택 이미지 포함 사용자 정보 업데이트)
  Future<void> userUpdate(
    String userPassword,
    String userName,
    String userGender,
    dynamic userAge,
    XFile? imageFile,
    String? existingImageUrl,
  ) async {
    XFile? finalImageFile = imageFile;

    // If no new image is provided, download the existing one (새 이미지가 없으면 기존 이미지 다운로드)
    if (finalImageFile == null &&
        existingImageUrl != null &&
        existingImageUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(existingImageUrl));
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_image.jpg');
        await tempFile.writeAsBytes(response.bodyBytes);
        finalImageFile = XFile(tempFile.path);
      } catch (e) {
        _showErrorDialog('Failed to load existing image.'); // 기존 이미지 불러오기 실패
        return;
      }
    }

    // If still no image, show error (이미지가 없으면 에러 표시)
    if (finalImageFile == null) {
      _showErrorDialog('Please select an image.');
      return;
    }
    await UserService().userUpdate(
      userPassword,
      userName,
      userGender,
      userAge,
      finalImageFile,
      userId,
    );
    _fetchData();
    Navigator.of(context).pop();
  }

  // Delete user account (사용자 계정 삭제)
  Future<void> userDelete() async {
    await UserService().userDelete(userId);
    Navigator.pushReplacementNamed(context, AppRoutes.intro);
  }

  // Update tweet with new content and optional image (내용 및 이미지로 트윗 업데이트)
  Future<void> tweetUpdate(
    String tweetId,
    String tweetContents,
    XFile? imageFile,
  ) async {
    await TweetService().tweetUpdate(
      tweetId,
      userId,
      tweetContents,
      imageFile,
    );
    _fetchData();
  }

  // Delete tweet (트윗 삭제)
  Future<void> tweetDelete(
    String tweetId,
  ) async {
    await TweetService().tweetDelete(
      tweetId,
      userId,
    );
    _fetchData();
  }

  // Update Instagram post (인스타그램 게시물 수정)
  Future<void> instaUpdate(
    String instaId,
    String instaContents,
    XFile? imageFile,
  ) async {
    await InstaService().instaUpdate(
      instaId,
      userId,
      instaContents,
      imageFile,
    );
    _fetchData();
  }

  // Delete Instagram post (인스타그램 게시물 삭제)
  Future<void> instaDelete(
    String instaId,
  ) async {
    await InstaService().instaDelete(
      instaId,
      userId,
    );
    _fetchData();
  }

  // Update purchase status (구매 정보 업데이트)
  Future<void> purchaseUpdate(
    String purchaseId,
    dynamic itemPrice,
  ) async {
    double price = (itemPrice is int) ? itemPrice.toDouble() : itemPrice;
    await ShopService().purchaseUpdate(
      purchaseId,
      userId,
      price,
    );
    _fetchData();
  }

  // Show detailed tweet modal with edit/delete (트윗 상세 모달 및 수정/삭제 버튼)
  void tweetDetailDialog(BuildContext context, String tweetContents,
      String tweetImgURL, String tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Color.fromRGBO(52, 52, 52, 52),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tweetContents,
                            style: TextStyle(fontSize: 15),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          if (tweetImgURL != null)
                            ClipRRect(
                              child: Image.network(
                                tweetImgURL,
                                fit: BoxFit.contain,
                              ),
                            ),
                          SizedBox(
                            height: 15,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(242, 242, 242, 242),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              tweetUpdateDialog(
                                  tweetId, tweetContents, tweetImgURL);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(52, 52, 52, 52),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF04452),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              tweetDeleteDialog(tweetId);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Show Instagram post details with edit/delete (인스타 상세 다이얼로그)
  void instaDetailDialog(BuildContext context, String instaId,
      String instaContents, String instaImgURL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: Color.fromRGBO(52, 52, 52, 52),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (instaImgURL != null)
                            Image.network(instaImgURL, fit: BoxFit.cover)
                          else
                            Container(
                              color: Colors.grey[200],
                              height: 200,
                              width: double.infinity,
                              child: Center(child: Text('No image')),
                            ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            instaContents ?? 'No contents',
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          // Edit Instagram post (인스타 수정)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(242, 242, 242, 242),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              instaUpdateDialog(
                                  instaId, instaContents, instaImgURL);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(52, 52, 52, 52),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          // Delete Instagram post (삭제)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF04452),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              instaDeleteDialog(instaId);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Display purchase details and refund option (구매 상세 정보 및 환불 처리)
  void purchaseDetailDialog(
    BuildContext context,
    String itemTitle,
    String itemImgURL,
    String itemContents,
    String purchaseId,
    dynamic itemPrice,
    dynamic purchaseStatus,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        itemTitle ?? 'No Title',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Color.fromRGBO(52, 52, 52, 52),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (itemImgURL != null)
                          Image.network(itemImgURL, fit: BoxFit.cover)
                        else
                          Container(
                            color: Colors.grey[200],
                            height: 200,
                            width: double.infinity,
                            child: Center(child: Text('No image')),
                          ),
                        SizedBox(height: 10),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${NumberFormat('###,###,###').format(itemPrice)}원',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          itemContents ?? 'No Contents',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 30),
                        // Refund button shown only for active purchases (활성 구매에만 환불 표시)
                        if (purchaseStatus == 1)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFF04452),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () {
                                purchaseUpdateDialog(purchaseId, itemPrice);
                              },
                              child: Text(
                                'Refund',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        else
                          Center(
                            child: Text(
                              'Refund Completed',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFF04452),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show user profile update dialog (사용자 프로필 수정 다이얼로그 표시)
  void userUpdateDialog(String userPassword, String userName, String userGender,
      dynamic userAge, String userImgURL) {
    // Initialize controllers with current user info (현재 사용자 정보로 입력 컨트롤러 초기화)
    TextEditingController nameController =
        TextEditingController(text: userName);
    TextEditingController passwordController =
        TextEditingController(text: userPassword);
    TextEditingController ageController =
        TextEditingController(text: userAge.toString());
    // New selected image file (새로 선택된 이미지 파일)
    XFile? _newImageFile;
    // Existing user image URL (기존 사용자 이미지 URL)
    String? existingImageUrl = userImgURL;

    // Refresh UI by calling setState (UI 갱신을 위한 상태 업데이트 함수)
    void refreshState() {
      if (mounted) setState(() {});
    }

    // Open image picker and update image file (이미지 선택기 열기 및 이미지 상태 갱신)
    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _newImageFile = pickedFile;
        existingImageUrl = null;
        refreshState();
      }
    }

    // Gender options for dropdown (성별 선택 드롭다운 옵션)
    final Map<String, String> _genderOptions = {
      'Male': '남성',
      'Female': '여성',
    };

    // Default gender (기본 성별 설정)
    String? selectedGender = userGender ?? 'Male';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit user',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: 360,
                height: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile image with cancel option (프로필 이미지 및 제거 버튼)
                      Stack(
                        children: [
                          ClipOval(
                            child: _newImageFile != null
                                ? Image.file(
                                    File(_newImageFile!.path),
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  )
                                : existingImageUrl != null
                                    ? Image.network(
                                        existingImageUrl!,
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                      )
                                    : CircleAvatar(
                                        radius: 50,
                                        backgroundColor:
                                            Color.fromARGB(242, 242, 242, 242),
                                        child: Icon(
                                          Icons.person,
                                          size: 50,
                                          color: Color.fromRGBO(52, 52, 52, 52),
                                        ),
                                      ),
                          ),
                          // Cancel image button (이미지 제거 버튼)
                          if (_newImageFile != null || existingImageUrl != null)
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
                                  setModalState(
                                    () {
                                      _newImageFile = null;
                                      existingImageUrl = null;
                                    },
                                  );
                                },
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Nickname input field (닉네임 입력 필드)
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Update your nickname',
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
                      SizedBox(height: 10),
                      // Password input field (비밀번호 입력 필드)
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: 'Update your password',
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
                      SizedBox(height: 10),
                      // Gender dropdown (성별 선택 드롭다운)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          hintText: 'Update your gender',
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
                        value: selectedGender,
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedGender = newValue;
                          });
                        },
                        items: _genderOptions.entries
                            .map((entry) => DropdownMenuItem(
                                  value: entry.key,
                                  child: Text(entry.value),
                                ))
                            .toList(),
                      ),
                      SizedBox(height: 10),
                      // Age input field (나이 입력 필드)
                      TextField(
                        controller: ageController,
                        decoration: InputDecoration(
                          hintText: 'Update your age',
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
                      SizedBox(height: 10),
                      // Image picker button (이미지 선택 버튼)
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
                          setModalState(() {});
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
                      // Submit update button (업데이트 제출 버튼)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4558C8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () {
                          userUpdate(
                            passwordController.text,
                            nameController.text,
                            selectedGender ?? userGender,
                            int.tryParse(ageController.text) ?? userAge,
                            _newImageFile,
                            existingImageUrl,
                          );
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void tweetUpdateDialog(
      String tweetId, String tweetContents, String tweetImgURL) {
    // Initialize TextEditingController with existing tweet content (기존 트윗 내용을 포함하여 텍스트 컨트롤러 초기화)
    final TextEditingController _controller =
        TextEditingController(text: tweetContents);

    // Variables for managing new image selection and existing image URL (새 이미지 선택 및 기존 이미지 URL 관리를 위한 변수)
    XFile? _newImageFile = null;
    String? existingImageUrl = tweetImgURL;

    // Refresh widget state safely if mounted (마운트 여부 확인 후 안전하게 상태 갱신)
    void refreshState() {
      if (mounted) setState(() {});
    }

    // Pick image from gallery asynchronously (갤러리에서 비동기로 이미지 선택)
    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _newImageFile = pickedFile;
        existingImageUrl = null;
        refreshState();
      }
    }

    // Show modal dialog with stateful builder for dynamic UI updates (동적 UI 업데이트를 위한 StatefulBuilder가 포함된 모달 다이얼로그 표시)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit tweet',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: 360,
                height: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Editable multiline TextField with input decoration (입력 데코레이션이 적용된 다중 행 텍스트 필드)
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Update your tweet',
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
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 10),
                      // Display selected or existing image with dismiss option (선택된 이미지 또는 기존 이미지를 표시하고 닫기 옵션 제공)
                      if (_newImageFile != null || existingImageUrl != null)
                        Stack(
                          children: [
                            if (_newImageFile != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(_newImageFile!.path),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (existingImageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  existingImageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                onPressed: () {
                                  // Clear selected and existing images on cancel (취소 시 선택된 이미지 및 기존 이미지 삭제)
                                  setModalState(() {
                                    _newImageFile = null;
                                    existingImageUrl = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      // Button to add/select new image from gallery (갤러리에서 새 이미지 선택 버튼)
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
                          setModalState(
                              () {}); // Trigger UI update on image pick
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
                      // Button to confirm and update the tweet (트윗 업데이트 확인 버튼)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4558C8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () async {
                          await tweetUpdate(
                              tweetId, _controller.text, _newImageFile);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      // Cancel button to close dialog without changes (변경 없이 다이얼로그 닫기 버튼)
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void instaUpdateDialog(
      String instaId, String instaContents, String instaImgURL) {
    // Initialize TextEditingController with existing insta content (기존 인스타 내용으로 텍스트 컨트롤러 초기화)
    final TextEditingController _controller =
        TextEditingController(text: instaContents);

    // Variables for new image file and existing image URL management (새 이미지 파일 및 기존 이미지 URL 관리 변수)
    XFile? _newImageFile = null;
    String? existingImageUrl = instaImgURL;

    // Safe state refresh method (안전한 상태 갱신 함수)
    void refreshState() {
      if (mounted) setState(() {});
    }

    // Async image picker from gallery (갤러리에서 비동기 이미지 선택)
    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _newImageFile = pickedFile;
        existingImageUrl = null; // Remove old image URL after new pick
        refreshState();
      }
    }

    // Stateful dialog for editing insta post (인스타 포스트 수정을 위한 Stateful 다이얼로그)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: Color.fromARGB(255, 255, 255, 255),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Text(
                'Edit insta',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              content: SizedBox(
                width: 360,
                height: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Display image preview if any (선택된 이미지 또는 기존 이미지 미리보기)
                      if (_newImageFile != null || existingImageUrl != null)
                        Stack(
                          children: [
                            if (_newImageFile != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.file(
                                  File(_newImageFile!.path),
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else if (existingImageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  existingImageUrl!,
                                  height: 200,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Positioned(
                              right: 10,
                              top: 10,
                              child: IconButton(
                                icon: Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                onPressed: () {
                                  setModalState(() {
                                    _newImageFile = null;
                                    existingImageUrl = null;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      SizedBox(height: 10),
                      // Multiline TextField for editing insta content (인스타 내용 편집을 위한 다중 행 텍스트 필드)
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Update your insta',
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
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                      SizedBox(height: 10),
                      // Button to pick an image (이미지 선택 버튼)
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
                          setModalState(() {});
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
                      // Confirm update button invoking instaUpdate method (instaUpdate 메서드를 호출하는 업데이트 확인 버튼)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4558C8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        onPressed: () async {
                          await instaUpdate(
                              instaId, _controller.text, _newImageFile);
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 5),
                      // Cancel button to close without saving (저장하지 않고 닫기 버튼)
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
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void purchaseUpdateDialog(String purchaseId, dynamic itemPrice) {
    // Confirmation dialog for refund action (환불 작업을 위한 확인 다이얼로그)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Refund Item',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Are you sure you want to refund this item?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          actions: [
            // Confirm refund button triggering purchaseUpdate method (purchaseUpdate 메서드를 실행하는 환불 확인 버튼)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF44558C8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                purchaseUpdate(purchaseId, itemPrice);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            // Cancel button to abort refund process (환불 프로세스 중단 취소 버튼)
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

  void userDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Delete account',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Are you sure you want to delete this account?',
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
                backgroundColor: Color(0xFF44558C8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                userDelete(); // Trigger user account deletion API call (사용자 계정 삭제 API 호출)
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
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

  void tweetDeleteDialog(String tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Delete tweet',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Are you sure you want to delete this tweet?',
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
                backgroundColor: Color(0xFF44558C8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                tweetDelete(
                    tweetId); // Call tweet deletion API with tweetId (tweetId로 트윗 삭제 API 호출)
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
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

  void instaDeleteDialog(String instaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Delete insta',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Are you sure you want to delete this insta?',
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
                backgroundColor: Color(0xFF44558C8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                instaDelete(
                    instaId); // Call Instagram deletion API with instaId (instaId로 인스타 삭제 API 호출)
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        title: Text(
          'User Page',
          style: TextStyle(
            fontSize: 20,
          ),
        ),
        centerTitle: true, // Center the app bar title (앱바 타이틀 중앙 정렬)
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future:
            allData, // Fetch aggregated user-related data asynchronously (비동기 사용자 관련 데이터 로드)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child:
                    CircularProgressIndicator()); // Show loading indicator while waiting (로딩 인디케이터 표시)
          } else if (snapshot.hasError) {
            return Center(
                child: Text(
                    'Error: ${snapshot.error}')); // Show error message on failure (오류 메시지 표시)
          } else if (!snapshot.hasData) {
            return Center(
                child: Text(
                    '데이터가 없습니다')); // Show empty state if no data (데이터 없음 상태 표시)
          }
          final userData = snapshot.data!['userData']
              as List<Map<String, dynamic>>; // Extract user data (사용자 데이터 추출)
          final tweetData = snapshot.data!['tweetData']
              as List<Map<String, dynamic>>; // Extract tweet data (트윗 데이터 추출)
          final instaData = snapshot.data!['instaData'] as List<
              Map<String, dynamic>>; // Extract Instagram data (인스타 데이터 추출)
          final purchaseData = snapshot.data!['purchaseData'] as List<
              Map<String, dynamic>>; // Extract purchase data (구매 데이터 추출)
          if (userData.isEmpty) {
            return Center(child: Text('User 내역이 없습니다'));
          }
          return _buildContent(userData, tweetData, instaData,
              purchaseData); // Build UI with loaded data (로딩된 데이터로 UI 빌드)
        },
      ),
    );
  }

  Widget _buildContent(
    List<Map<String, dynamic>> userData,
    List<Map<String, dynamic>> tweetData,
    List<Map<String, dynamic>> instaData,
    List<Map<String, dynamic>> purchaseData,
  ) {
    final user = userData[0];
    // Cache-busting image URL (유저 이미지 캐시 방지)
    final userImgURL =
        '${user['userImgURL']}?${DateTime.now().millisecondsSinceEpoch}';
    final userEmail = user['userEmail'];
    final userPassword = user['userPassword'];
    final userName = user['userName'];
    final userGender = user['userGender'];
    final userAge = user['userAge'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: userImgURL != null
                          ? ClipOval(
                              child: Image.network(
                                userImgURL!, // Display user profile image (사용자 프로필 이미지 표시)
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons
                                  .account_circle, // Default user icon fallback (기본 사용자 아이콘)
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    user['userName'] ?? 'No userName',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(52, 52, 52, 52),
                    ),
                  ),
                  Text(
                    user['userEmail'] ?? 'No userEmail',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(89, 89, 89, 89),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Spacer(),
              Text(
                '${NumberFormat('###,###,###').format((user['userMoney'] - user['userSpend']) ?? 0)}원',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(width: 10),
            ],
          ),
          sectionTweet(tweetData), // Render tweets section (트윗 섹션 렌더링)
          SizedBox(height: 20),
          sectionInsta(
              instaData), // Render Instagram posts section (인스타 섹션 렌더링)
          SizedBox(height: 20),
          sectionPurchase(
              purchaseData), // Render purchase history section (구매 내역 섹션 렌더링)
          SizedBox(height: 30),
          SizedBox(
            width: 360,
            child: ElevatedButton(
              onPressed: () {
                userUpdateDialog(userPassword, userName, userGender, userAge,
                    userImgURL); // Trigger user info update dialog (사용자 정보 수정 다이얼로그 호출)
              },
              child: Text(
                'Edit account',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(242, 242, 242, 242),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
              onPressed: () {
                userDeleteDialog(); // Trigger account deletion confirmation dialog (계정 삭제 확인 다이얼로그 호출)
              },
              child: Text(
                'Delete account',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF04452),
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Render tweet section with horizontal scrollable cards (트윗 섹션을 수평 스크롤 카드로 렌더링)
  Widget sectionTweet(List<Map<String, dynamic>> tweetData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with section title and tweet count (섹션 제목과 트윗 개수 출력)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                'My Tweet   ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
              ),
              Text(
                '${tweetData.length}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF44558C8),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scroll list of tweet cards (트윗 카드 리스트 - 수평 스크롤)
        Container(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tweetData.length,
            itemBuilder: (context, index) {
              final tweet = tweetData[index];
              final tweetId = tweet['tweetId'];
              // Add cache-busting query param to image URL (이미지 캐시 방지용 타임스탬프 추가)
              final tweetImgURL =
                  '${tweet['tweetImgURL']}?${DateTime.now().millisecondsSinceEpoch}';
              final tweetContents = tweet['tweetContents'];
              final userId = tweet['userId'];

              return GestureDetector(
                // Open tweet detail dialog on tap (탭 시 상세 트윗 다이얼로그 표시)
                onTap: () {
                  tweetDetailDialog(
                      context, tweetContents, tweetImgURL, tweetId);
                },
                child: Container(
                  width: 240,
                  height: 230,
                  margin: EdgeInsets.only(right: 10),
                  child: Card(
                    color: Colors.white,
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 10),
                          // Display tweet content with ellipsis overflow (트윗 내용 표시 - 최대 2줄)
                          Text(
                            tweetContents ?? '',
                            style: TextStyle(
                              fontSize: 15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          // Conditional rendering of tweet image (이미지 존재 시 표시)
                          if (tweetImgURL != null && tweetImgURL.isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                tweetImgURL,
                                width: 200,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Render Instagram section with thumbnails (인스타그램 섹션 - 썸네일 목록)
  Widget sectionInsta(List<Map<String, dynamic>> instaData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with count (섹션 헤더와 데이터 개수)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                'My Insta   ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
              ),
              Text(
                '${instaData.length}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF44558C8),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrollable Instagram preview list (수평 스크롤 가능한 인스타 미리보기)
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: instaData.length,
            itemBuilder: (context, index) {
              final insta = instaData[index];
              final instaContents = insta['instaContents'];
              // Cache-busting image URL (이미지 캐시 방지)
              final instaImgURL =
                  '${insta['instaImgURL']}?${DateTime.now().millisecondsSinceEpoch}';
              final instaId = insta['instaId'];
              return GestureDetector(
                // Open Instagram detail dialog (탭 시 상세 보기)
                onTap: () {
                  instaDetailDialog(
                      context, instaId, instaContents, instaImgURL);
                },
                child: Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(right: 3),
                  color: Colors.grey,
                  // Conditional image display (이미지 존재 여부에 따른 조건부 렌더링)
                  child: instaImgURL != null
                      ? Image.network(
                          instaImgURL,
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.camera_alt_outlined),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Render purchase history section with product thumbnails (구매 내역 섹션 - 썸네일 표시)
  Widget sectionPurchase(List<Map<String, dynamic>> purchaseData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with section title and item count (섹션 제목과 항목 개수 표시)
        Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Text(
                'My Purchase   ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
              ),
              Text(
                '${purchaseData.length}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF44558C8),
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrollable purchase list (수평 스크롤 구매 목록)
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: purchaseData.length,
            itemBuilder: (context, index) {
              final purchase = purchaseData[index];
              final itemTitle = purchase['itemTitle'];
              final itemImgURL = purchase['itemImgURL'];
              final itemContents = purchase['itemContents'];
              final purchaseId = purchase['purchaseId'];
              final itemPrice = purchase['itemPrice'];
              final purchaseStatus = purchase['purchaseStatus'];
              return GestureDetector(
                // Show detailed purchase dialog on tap (탭 시 구매 상세 다이얼로그 표시)
                onTap: () {
                  purchaseDetailDialog(context, itemTitle, itemImgURL,
                      itemContents, purchaseId, itemPrice, purchaseStatus);
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 100,
                    height: 150,
                    margin: EdgeInsets.only(right: 3),
                    color: Colors.grey,
                    // Display image if available (이미지가 있으면 표시)
                    child: purchase['itemImgURL'] != null
                        ? Image.network(
                            purchase['itemImgURL'],
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.camera_alt_outlined),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
