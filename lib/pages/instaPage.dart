import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../services/login.dart';
import '../services/insta.dart';

class InstaPage extends StatefulWidget {
  @override
  _InstaPageState createState() => _InstaPageState();
}

class _InstaPageState extends State<InstaPage> {
  // Controller to manage input text for the insta post (인스타 포스트 입력 텍스트 컨트롤러)
  final TextEditingController _instaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? adminId = dotenv.env['ADMIN_ID'];
  List<Map<String, dynamic>> instas = [];
  bool loading = false;
  // Local reference to the selected image file (선택된 이미지 파일 로컬 참조)
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Initial fetch of insta posts on widget load (위젯 로드 시 초기 인스타 포스트 가져오기)
    fetchInstas();
  }

  Future<void> fetchInstas() async {
    setState(() {
      // Set loading state before fetching data (데이터 가져오기 전 로딩 상태 설정)
      loading = true;
    });

    final instaService = InstaService();
    // Fetch posts from backend service (백엔드 서비스에서 포스트 데이터 읽기)
    final fetchedInstas = await instaService.instaRead();

    setState(() {
      // Update UI with fetched posts (가져온 포스트로 UI 업데이트)
      instas = fetchedInstas;
      // Reset loading state after fetch (가져오기 완료 후 로딩 상태 초기화)
      loading = false;
    });
  }

  Future<void> _postInsta() async {
    // Prevent empty posts submission (빈 포스트 제출 방지)
    if (_instaController.text.isEmpty) return;

    final loginService = Provider.of<LoginService>(context, listen: false);
    // Get current user ID from login service (로그인 서비스에서 현재 사용자 ID 가져오기)
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await InstaService().instaCreate(
        userId,
        _instaController.text,
        _imageFile != null ? XFile(_imageFile!.path) : null,
      );
      print('Insta posted successfully');
    } catch (error) {
      print('Error posting insta: $error');
    }

    setState(() {
      // Clear input text after posting (포스트 후 입력창 초기화)
      _instaController.clear();
      // Clear selected image reference (선택된 이미지 참조 초기화)
      _imageFile = null;
    });
    // Refresh the post list after new post (새 포스트 후 리스트 갱신)
    fetchInstas();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        // Store selected image as File (선택한 이미지를 File 형태로 저장)
        _imageFile = File(pickedFile.path);
      });
      Navigator.of(context).pop();
      _showInstaDialog();
    }
  }

  void _cancelImageAttachment() {
    setState(() {
      _imageFile = null;
    });
  }

  void _showInstaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Post insta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
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
          content: SizedBox(
            width: 360,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_imageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.contain,
                            // Maintain image aspect ratio (이미지 비율 유지)
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: IconButton(
                            icon:
                                Icon(Icons.cancel, color: Colors.red, size: 30),
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                              });
                              Navigator.of(context).pop();
                              _showInstaDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Container(
                    height: 120,
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _instaController,
                        decoration: InputDecoration(
                          hintText: 'What’s happening?',
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
                        // Multi-line input support (멀티라인 입력 지원)
                      ),
                    ),
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
                      Navigator.of(context).pop();
                      _showInstaDialog();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Add image',
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
                      backgroundColor: Color(0xFF44558C8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      // Submit the post with optional image (이미지 포함 포스트 제출)
                      _postInsta();
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color: Colors.white,
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
      },
    );
  }

  Future<void> _editInsta(
      String instaId, String instaContents, File? _imageFile) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    // Get user ID for authorization (수정 권한 검사용 사용자 ID)
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await InstaService().instaUpdate(
        instaId,
        userId,
        instaContents,
        _imageFile != null ? XFile(_imageFile.path) : null,
      );
      // Call update API with new content and optional image (수정 API 호출, 선택 이미지 포함)

      print('Insta updated successfully');
      fetchInstas();
    } catch (error) {
      print('Error updating insta: $error');
    }
  }

  Future<void> _deleteInsta(String instaId) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    // Get user ID for delete authorization (삭제 권한 검사용 사용자 ID)
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await InstaService().instaDelete(instaId, userId);
      // Call delete API with instaId and userId (삭제 API 호출)

      print('Insta deleted successfully');
      fetchInstas();
    } catch (error) {
      print('Error deleting insta: $error');
    }
  }

  void _showInstaDetailDialog(Map<String, dynamic> insta) {
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            insta['userImgURL'] != null &&
                                    insta['userImgURL'] != ''
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(insta['userImgURL']!),
                                    radius: 20,
                                  )
                                : CircleAvatar(
                                    child: Icon(Icons.account_circle_outlined,
                                        color: Colors.grey, size: 24),
                                    radius: 20,
                                  ),
                            SizedBox(width: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                insta['username'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (insta['photo'] != null)
                            Image.network(insta['photo'], fit: BoxFit.cover)
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
                            insta['insta'] ?? 'No contents',
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                DateFormat('MMM d, yyyy, h:mm a').format(
                                  DateTime.parse(insta['createdAt']).toLocal(),
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(52, 52, 52, 52),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (insta['userId'] ==
                                  Provider.of<LoginService>(context,
                                          listen: false)
                                      .userInfo?['id'] ||
                              Provider.of<LoginService>(context, listen: false)
                                      .userInfo?['id'] ==
                                  adminId) ...[
                            // Show edit/delete buttons if current user or admin (현재 사용자 혹은 관리자만 수정/삭제 버튼 표시)
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
                                _showEditInstaDialog(insta);
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
                                // Trigger delete confirmation dialog (삭제 확인 다이얼로그 호출)
                                _showDeleteConfirmationDialog(insta['id']);
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

  void _showEditInstaDialog(Map<String, dynamic> insta) {
    final controller = TextEditingController(text: insta['insta']);
    File? _newImageFile;
    String? existingImageUrl = insta['photo'];

    void refreshState() {
      if (mounted) setState(() {});
    }

    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _newImageFile = File(pickedFile.path);
        existingImageUrl = null;
        refreshState();
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setModalState) {
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
                    // Display either newly selected image or existing image URL (이미지 파일 또는 기존 URL 표시)
                    if (_newImageFile != null || existingImageUrl != null)
                      Stack(
                        children: [
                          if (_newImageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _newImageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (existingImageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                '$existingImageUrl?${DateTime.now().millisecondsSinceEpoch}', // Cache busting (캐시 무효화)
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          // Button to remove selected or existing image (이미지 제거 버튼)
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
                    // TextField for insta content editing (인스타 내용 입력 필드)
                    TextField(
                      controller: controller,
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
                            () {}); // Update dialog UI after image pick (이미지 선택 후 UI 갱신)
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
                    // Submit button to update insta content and image (인스타 업데이트 요청 버튼)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF44558C8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () async {
                        await _editInsta(
                            insta['id'], controller.text, _newImageFile);
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
        });
      },
    );
  }

  void _showDeleteConfirmationDialog(String instaId) {
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
            // Confirm deletion button (삭제 확정 버튼)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF44558C8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                await _deleteInsta(instaId);
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
            // Cancel deletion button (삭제 취소 버튼)
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
      body: Center(
        child: Container(
          width: 340,
          child: Column(
            children: [
              SizedBox(height: 5),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchInstas, // Pull to refresh instas (새로고침 기능)
                  child: loading
                      ? Center(
                          child:
                              CircularProgressIndicator()) // Loading spinner (로딩 표시)
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                          ),
                          itemCount: instas.length,
                          itemBuilder: (context, index) {
                            final insta = instas[index];
                            return GestureDetector(
                              onTap: () => _showInstaDetailDialog(
                                  insta), // Open detail on tap (탭 시 상세보기)
                              child: Image.network(
                                '${insta['photo']}?${DateTime.now().millisecondsSinceEpoch}', // Cache busting for images (캐시 무효화)
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: Center(
                                        child: Text(
                                            'No Image')), // Fallback UI for image errors (이미지 에러 대체 UI)
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInstaDialog(); // Open new insta dialog (새 인스타 대화상자 열기)
        },
        backgroundColor: Color(0xFF44558C8),
        elevation: 0,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
