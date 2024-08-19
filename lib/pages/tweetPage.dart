import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/login.dart';
import '../services/tweet.dart';

class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  final TextEditingController _tweetController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Map<String, dynamic>> tweets = [];

  @override
  void initState() {
    super.initState();
    fetchTweets();
  }

  Future<void> fetchTweets() async {
    final tweetService = TweetService();
    final fetchedTweets = await tweetService.tweetRead();
    setState(() {
      tweets = fetchedTweets;
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
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Post a Tweet'),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _tweetController,
                    decoration: InputDecoration(
                      hintText: 'What\'s happening?',
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  _imageFile == null
                      ? Container()
                      : Stack(
                          children: [
                            Image.file(
                              _imageFile!,
                              height: 200,
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.cancel, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _cancelImageAttachment();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.photo),
                        onPressed: () async {
                          final pickedFile = await _picker.pickImage(
                              source: ImageSource.gallery);
                          if (pickedFile != null) {
                            setState(() {
                              _imageFile = File(pickedFile.path);
                            });
                          }
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _postTweet();
                          Navigator.of(context).pop();
                        },
                        child: Text('Tweet'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginService = Provider.of<LoginService>(context);
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _showTweetDialog,
                  child: Text('Tweet'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: tweets.length,
              itemBuilder: (context, index) {
                final tweet = tweets[index];
                return ListTile(
                  title: Text(tweet['tweet']),
                  subtitle: Text(tweet['username']),
                  trailing: tweet['photo'] != null
                      ? Image.network(tweet['photo'])
                      : null,
                  onTap: () {
                    // 트윗 수정 또는 삭제 코드 추가 가능
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
