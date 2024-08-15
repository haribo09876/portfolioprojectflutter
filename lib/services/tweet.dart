import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Tweet extends StatefulWidget {
  final String username;
  final String avatar;
  final String tweet;
  final String? photo;
  final String id;
  final String userId;

  const Tweet({
    required this.username,
    required this.avatar,
    required this.tweet,
    this.photo,
    required this.id,
    required this.userId,
  });

  @override
  _TweetState createState() => _TweetState();
}

class _TweetState extends State<Tweet> {
  final String apiUrl = dotenv.env['TWEET_FUNC_URL']!;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _tweetController = TextEditingController();
  bool editModalVisible = false;
  String? newPhoto;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _tweetController.text = widget.tweet;
  }

  Future<void> deleteTweet() async {
    try {
      final response = await http.post(
        Uri.parse('$apiUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'delete',
          'tweetId': widget.id,
          'userId': widget.userId,
        }),
      );
      if (response.statusCode == 200) {
      } else {}
    } catch (error) {
      print('Error deleting tweet: $error');
    }
  }

  Future<void> editTweet() async {
    try {
      String? updatedPhoto = widget.photo;
      if (_imageFile != null) {
        final request = http.MultipartRequest('POST', Uri.parse('$apiUrl'))
          ..fields['action'] = 'update'
          ..fields['tweetId'] = widget.id
          ..fields['tweetContents'] = _tweetController.text
          ..files.add(await http.MultipartFile.fromPath(
              'fileContent', _imageFile!.path));
        final response = await request.send();
        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseJson = json.decode(responseBody);
          updatedPhoto = responseJson['fileUrl'];
        } else {
          // Handle error
        }
      }

      final response = await http.post(
        Uri.parse('$apiUrl'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'action': 'update',
          'tweetId': widget.id,
          'tweetContents': _tweetController.text,
          'fileContent': updatedPhoto,
          'userId': widget.userId,
        }),
      );
      if (response.statusCode == 200) {
        setState(() {
          editModalVisible = false;
        });
      } else {
        // Handle error
      }
    } catch (error) {
      print('Error updating tweet: $error');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (BuildContext context) => buildTweetDialog(),
      ),
      child: Container(
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Icon(Icons.account_circle, size: 50),
            SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.username,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333))),
                  if (widget.photo != null)
                    Image.network(widget.photo!,
                        height: 200, fit: BoxFit.cover),
                  Text(widget.tweet,
                      style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTweetDialog() {
    return AlertDialog(
      title: Text(widget.username),
      content: SingleChildScrollView(
        child: Column(
          children: [
            if (widget.photo != null)
              Image.network(widget.photo!, height: 200, fit: BoxFit.cover),
            Text(widget.tweet,
                style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
            if (widget.userId == 'currentUserId')
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: deleteTweet,
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => buildEditTweetDialog(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget buildEditTweetDialog() {
    return AlertDialog(
      title: Text('Edit Tweet'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _tweetController,
            decoration: InputDecoration(
              hintText: 'Edit your tweet',
            ),
            maxLines: null,
          ),
          if (_imageFile != null)
            Image.file(_imageFile!, height: 200, fit: BoxFit.cover),
          Row(
            children: [
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Change Photo'),
              ),
              ElevatedButton(
                onPressed: editTweet,
                child: Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TweetTimeline extends StatefulWidget {
  @override
  _TweetTimelineState createState() => _TweetTimelineState();
}

class _TweetTimelineState extends State<TweetTimeline> {
  final String apiUrl = dotenv.env['TWEET_FUNC_URL']!;
  List<Map<String, dynamic>> tweets = [];

  @override
  void initState() {
    super.initState();
    fetchTweets();
  }

  Future<void> fetchTweets() async {
    try {
      final response = await http.get(Uri.parse('$apiUrl?action=read'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          tweets = data
              .map((tweet) => {
                    'id': tweet['tweetId'],
                    'username': tweet['userId'],
                    'tweet': tweet['tweetContents'],
                    'photo': tweet['tweetImgURL'],
                    'userId': tweet['userId'],
                  })
              .toList();
        });
      } else {}
    } catch (error) {
      print('Error fetching tweets: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(10),
      itemCount: tweets.length,
      itemBuilder: (context, index) {
        final tweet = tweets[index];
        return Tweet(
          id: tweet['id'],
          username: tweet['username'],
          tweet: tweet['tweet'],
          photo: tweet['photo'],
          userId: tweet['userId'],
          avatar: '',
        );
      },
    );
  }
}
