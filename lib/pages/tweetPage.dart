import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../services/login.dart';
import '../services/tweet.dart';

class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  final TextEditingController _tweetController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? adminId = dotenv.env['ADMIN_ID'];
  List<Map<String, dynamic>> tweets = [];
  bool loading = false;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    fetchTweets();
  }

  Future<void> fetchTweets() async {
    setState(() {
      loading = true;
    });
    final tweetService = TweetService();
    final fetchedTweets = await tweetService.tweetRead();
    setState(() {
      tweets = fetchedTweets;
      loading = false;
    });
  }

  Future<void> _postTweet() async {
    if (_tweetController.text.isEmpty) return;
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';
    try {
      await TweetService().tweetCreate(
        userId,
        _tweetController.text,
        _imageFile != null ? XFile(_imageFile!.path) : null,
      );
      print('Tweet posted successfully');
    } catch (error) {
      print('Error posting tweet: $error');
    }
    setState(() {
      _tweetController.clear();
      _imageFile = null;
    });
    fetchTweets();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      Navigator.of(context).pop();
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
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Post tweet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
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
                  Container(
                    height: 120,
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _tweetController,
                        decoration: InputDecoration(
                          hintText: 'What’s happening?',
                          hintStyle: TextStyle(
                            color: Color.fromRGBO(52, 52, 52, 52),
                          ),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                        ),
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_imageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
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
                          'Add Image',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
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
                            fontWeight: FontWeight.w400,
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

  Future<void> _editTweet(String tweetId, String tweetContents) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await TweetService().tweetUpdate(
        tweetId,
        userId,
        tweetContents,
        _imageFile != null ? XFile(_imageFile!.path) : null,
      );
      print('Tweet updated successfully');
      fetchTweets();
    } catch (error) {
      print('Error updating tweet: $error');
    }
  }

  Future<void> _deleteTweet(String tweetId) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await TweetService().tweetDelete(tweetId, userId);
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
            borderRadius: BorderRadius.circular(15),
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
                                  fontWeight: FontWeight.w400,
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
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          if (tweet['photo'] != null)
                            ClipRRect(
                              child: Image.network(
                                tweet['photo'],
                                fit: BoxFit.contain,
                              ),
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
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromRGBO(52, 52, 52, 52),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          if (tweet['userId'] ==
                                  Provider.of<LoginService>(context,
                                          listen: false)
                                      .userInfo?['id'] ||
                              Provider.of<LoginService>(context, listen: false)
                                      .userInfo?['id'] ==
                                  adminId) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF44558C8),
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
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFEE5E37),
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
                                      fontWeight: FontWeight.w400,
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

  void _showEditTweetDialog(Map<String, dynamic> tweet) {
    final controller = TextEditingController(text: tweet['tweet']);
    File? _newImageFile = null;
    String? existingImageUrl = tweet['photo'];

    void _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _newImageFile = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            'Edit tweet',
            style: TextStyle(
              fontSize: 20,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 360,
              height: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: 'Update your tweet',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                  ),
                  SizedBox(height: 10),
                  if (_newImageFile != null || existingImageUrl != null)
                    Stack(
                      children: [
                        if (_newImageFile != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _newImageFile!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          )
                        else if (existingImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
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
                              setState(() {
                                _newImageFile = null;
                              });
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
                            color: Color.fromRGBO(52, 52, 52, 52),
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
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
                    onPressed: () async {
                      final tweetService = TweetService();
                      final userId =
                          Provider.of<LoginService>(context, listen: false)
                                  .userInfo?['id'] ??
                              '';
                      String? imageUrl =
                          _newImageFile != null ? null : existingImageUrl;
                      await tweetService.tweetUpdate(
                        tweet['id'],
                        userId,
                        controller.text,
                        _newImageFile != null
                            ? XFile(_newImageFile!.path)
                            : null,
                      );
                      fetchTweets();
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
                            fontWeight: FontWeight.w400,
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
                            fontWeight: FontWeight.w400,
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
  }

  void _showDeleteConfirmationDialog(String tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
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
                  fontWeight: FontWeight.w400,
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
                      fontWeight: FontWeight.w400,
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
                      fontWeight: FontWeight.w400,
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
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: fetchTweets,
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
                        color: Color.fromARGB(242, 242, 242, 242),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: GestureDetector(
                          onTap: () => _showTweetDetailDialog(tweet),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(15),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    tweet['userImgURL'] != null &&
                                            tweet['userImgURL'] != ''
                                        ? CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                tweet['userImgURL']!),
                                            radius: 20,
                                          )
                                        : CircleAvatar(
                                            child: Icon(
                                                Icons.account_circle_outlined,
                                                color: Colors.grey,
                                                size: 30),
                                            radius: 20,
                                          ),
                                    SizedBox(width: 15),
                                    Text(
                                      tweet['username'],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
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
                                if (tweet['photo'] != null) SizedBox(height: 5),
                                if (tweet['photo'] != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(15),
                                    child: Image.network(
                                      tweet['photo'],
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
                                    Text(
                                      DateFormat('MMM d, yyyy, h:mm a').format(
                                        DateTime.parse(tweet['createdAt'])
                                            .toLocal(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        color: Color.fromRGBO(52, 52, 52, 52),
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
                      ),
                    ),
                  );
                },
              ),
            ),
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
