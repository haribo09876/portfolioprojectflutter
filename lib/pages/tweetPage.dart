import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/login.dart';
import '../services/tweet.dart';

class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  // Tweet input controller (트윗 입력 컨트롤러)
  final TextEditingController _tweetController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? adminId = dotenv.env['ADMIN_ID'];
  List<Map<String, dynamic>> tweets = [];
  bool loading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    // Load tweets on init (초기화 시 트윗 로드)
    fetchTweets();
  }

  Future<void> fetchTweets() async {
    setState(() {
      loading = true;
    });
    final tweetService = TweetService();
    // Fetch tweets from API (API로부터 트윗 가져오기)
    final fetchedTweets = await tweetService.tweetRead();
    setState(() {
      tweets = fetchedTweets;
      loading = false;
    });
  }

  Future<void> _postTweet() async {
    // Skip if empty (입력값이 없으면 종료)
    if (_tweetController.text.isEmpty) return;
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';
    try {
      await TweetService().tweetCreate(
        userId,
        _tweetController.text,
        _imageFile != null
            ? XFile(_imageFile!.path)
            : null, // Optional image upload (이미지 첨부 가능)
      );
      print('Tweet posted successfully');
    } catch (error) {
      print('Error posting tweet: $error');
    }
    setState(() {
      // Clear input (입력창 초기화)
      _tweetController.clear();
      _imageFile = null;
    });
    // Refresh tweet list (트윗 목록 갱신)
    fetchTweets();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery); // Open gallery (갤러리 열기)
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      Navigator.of(context).pop();
      // Reopen tweet dialog (트윗 작성 다이얼로그 다시 열기)
      _showTweetDialog();
    }
  }

  void _cancelImageAttachment() {
    setState(() {
      _imageFile = null;
    });
  }

  void _showTweetDialog() {
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
                'Post tweet',
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
                  // Tweet input box (트윗 입력 상자)
                  Container(
                    height: 120,
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _tweetController,
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
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Preview attached image (이미지 미리보기)
                  if (_imageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: IconButton(
                            icon:
                                Icon(Icons.cancel, color: Colors.red, size: 30),
                            onPressed: () {
                              _cancelImageAttachment();
                              Navigator.of(context).pop();
                              _showTweetDialog();
                            },
                          ),
                        ),
                      ],
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
                    onPressed: () {
                      _pickImage();
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
                      _postTweet();
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

  Future<void> _editTweet(
      String tweetId, String tweetContents, File? imageFile) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await TweetService().tweetUpdate(
        tweetId,
        userId,
        tweetContents,
        imageFile != null
            ? XFile(imageFile.path)
            : null, // Update with optional image (선택적 이미지 포함 업데이트)
      );
      print('Tweet updated successfully');
      fetchTweets(); // Refresh after update (업데이트 후 새로고침)
    } catch (error) {
      print('Error updating tweet: $error');
    }
  }

  Future<void> _deleteTweet(String tweetId) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await TweetService()
          .tweetDelete(tweetId, userId); // Delete tweet via API (API를 통한 트윗 삭제)
      print('Tweet deleted successfully');
      fetchTweets();
    } catch (error) {
      print('Error deleting tweet: $error');
    }
  }

  void _showTweetDetailDialog(Map<String, dynamic> tweet) {
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
                  // Header with user info and close icon (사용자 정보와 닫기 버튼)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            tweet['userImgURL'] != null &&
                                    tweet['userImgURL'] != ''
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(tweet['userImgURL']!),
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
                                tweet['username'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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
                  SizedBox(
                    height: 10,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tweet['tweet'],
                            style: TextStyle(fontSize: 15),
                          ), // Tweet text (트윗 본문)
                          SizedBox(
                            height: 15,
                          ),
                          if (tweet['photo'] != null)
                            ClipRRect(
                              child: Image.network(
                                tweet['photo'],
                                fit: BoxFit.contain,
                              ), // Display image (이미지 표시)
                            ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                DateFormat('MMM d, yyyy, h:mm a').format(
                                  DateTime.parse(tweet['createdAt']).toLocal(),
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
                            height: 15,
                          ),
                          // Edit/Delete only for owner or admin (작성자 또는 관리자만 편집/삭제 가능)
                          if (tweet['userId'] ==
                                  Provider.of<LoginService>(context,
                                          listen: false)
                                      .userInfo?['id'] ||
                              Provider.of<LoginService>(context, listen: false)
                                      .userInfo?['id'] ==
                                  adminId) ...[
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
                                _showEditTweetDialog(tweet);
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
                                _showDeleteConfirmationDialog(tweet['id']);
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

  // Trigger tweet editing dialog with pre-filled data (기존 트윗 데이터를 기반으로 편집 다이얼로그 호출)
  void _showEditTweetDialog(Map<String, dynamic> tweet) {
    final controller = TextEditingController(text: tweet['tweet']);
    File? _newImageFile = null;
    String? existingImageUrl = tweet['photo'];

    // Refresh widget state if still mounted (위젯이 활성 상태일 때 상태 갱신)
    void refreshState() {
      if (mounted) setState(() {});
    }

    // Pick image from gallery using ImagePicker (갤러리에서 이미지 선택)
    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _newImageFile = File(pickedFile.path);
        existingImageUrl = null;
        refreshState();
      }
    }

    // Render edit tweet modal with image support (이미지 포함 편집 모달 UI 렌더링)
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
                    // Tweet text field (트윗 텍스트 입력 필드)
                    TextField(
                      controller: controller,
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
                    // Display selected or existing image with removable icon (선택 또는 기존 이미지 표시 및 제거 버튼)
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
                                '$existingImageUrl?${DateTime.now().millisecondsSinceEpoch}',
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
                    // Submit tweet update (트윗 업데이트 실행)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4558C8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () async {
                        await _editTweet(
                            tweet['id'], controller.text, _newImageFile);
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

  // Show confirmation dialog for tweet deletion (트윗 삭제 확인 다이얼로그)
  void _showDeleteConfirmationDialog(String tweetId) {
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
            // Confirm deletion (삭제 확정)
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF44558C8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                await _deleteTweet(tweetId);
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
    final loginService = Provider.of<LoginService>(context);
    final currentUserId = loginService.userInfo?['id'] ?? '';

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: loading
          ? Center(
              child: CircularProgressIndicator()) // Loading spinner (로딩 중 표시)
          : RefreshIndicator(
              onRefresh: fetchTweets, // Pull-to-refresh handler (당겨서 새로고침)
              child: ListView.builder(
                itemCount: tweets.length,
                itemBuilder: (context, index) {
                  final tweet = tweets[index];
                  final isOwnTweet = tweet['userId'] == currentUserId;

                  return Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: 360,
                      child: Card(
                        color: Color.fromARGB(255, 255, 255, 255),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            // Tweet tile with tap to detail (트윗 항목 클릭 시 상세 보기)
                            GestureDetector(
                              onTap: () => _showTweetDetailDialog(tweet),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(15),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Display profile image or default icon (프로필 이미지 또는 기본 아이콘 표시)
                                        tweet['userImgURL'] != null &&
                                                tweet['userImgURL'] != ''
                                            ? CircleAvatar(
                                                backgroundImage: NetworkImage(
                                                    tweet['userImgURL']!),
                                                radius: 20,
                                              )
                                            : CircleAvatar(
                                                child: Icon(
                                                    Icons
                                                        .account_circle_outlined,
                                                    color: Colors.grey,
                                                    size: 30),
                                                radius: 20,
                                              ),
                                        SizedBox(width: 15),
                                        Text(
                                          tweet['username'],
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 15),
                                    Text(
                                      tweet['tweet'],
                                      style: TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    if (tweet['photo'] != null)
                                      SizedBox(height: 5),
                                    if (tweet['photo'] != null)
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          '${tweet['photo']}?${DateTime.now().millisecondsSinceEpoch}',
                                          width: double.infinity,
                                          height: 200,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      children: [
                                        Spacer(),
                                        // Display local timestamp (로컬 시간 기준 트윗 생성 시각 표시)
                                        Text(
                                          DateFormat('MMM d, yyyy, h:mm a')
                                              .format(
                                            DateTime.parse(tweet['createdAt'])
                                                .toLocal(),
                                          ),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color:
                                                Color.fromRGBO(52, 52, 52, 52),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                                isThreeLine: true,
                              ),
                            ),
                            Divider(
                              color: Color.fromARGB(242, 242, 242, 242),
                              thickness: 1,
                              height: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
      // FAB for adding new tweet (새 트윗 추가용 FloatingActionButton)
      floatingActionButton: FloatingActionButton(
        onPressed: _showTweetDialog,
        backgroundColor: Color(0xFF44558C8),
        elevation: 0,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
