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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tweet',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tweetController,
                  decoration: InputDecoration(
                    hintText: 'What’s happening?',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                  maxLines: 11,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 10),
                if (_imageFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: IconButton(
                          icon: Icon(Icons.cancel, color: Colors.red, size: 30),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.photo, color: Colors.blue),
                      onPressed: _pickImage,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        _postTweet();
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Tweet',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tweet['username'],
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tweet['photo'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      tweet['photo'],
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                SizedBox(height: 30),
                Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    tweet['tweet'],
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  tweet['timestamp'] ?? '',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 20),
                if (tweet['userId'] ==
                    Provider.of<LoginService>(context, listen: false)
                        .userInfo?['id'])
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showEditTweetDialog(tweet);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showDeleteConfirmationDialog(tweet['id']);
                        },
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditTweetDialog(Map<String, dynamic> tweet) {
    final controller = TextEditingController(text: tweet['tweet']);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Edit Tweet', style: TextStyle(fontSize: 22)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.4,
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Update your tweet',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () async {
                await _editTweet(tweet['id'], controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Update', style: TextStyle(color: Colors.blue)),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(String tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Delete Tweet', style: TextStyle(fontSize: 22)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Center(
              child: Text('Are you sure you want to delete this tweet?'),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.black54)),
            ),
            TextButton(
              onPressed: () async {
                await _deleteTweet(tweetId);
                Navigator.of(context).pop();
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
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
      body: RefreshIndicator(
        onRefresh: fetchTweets,
        child: ListView.builder(
          itemCount: tweets.length,
          itemBuilder: (context, index) {
            final tweet = tweets[index];
            final isOwnTweet = tweet['userId'] == currentUserId;

            return GestureDetector(
              onTap: () => _showTweetDetailDialog(tweet),
              child: Card(
                margin: EdgeInsets.all(8.0),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.0),
                  leading: tweet['userImgURL'] != null &&
                          tweet['userImgURL'] != ''
                      ? CircleAvatar(
                          backgroundImage: NetworkImage(tweet['userImgURL']!),
                          radius: 25,
                        )
                      : CircleAvatar(
                          child: Icon(Icons.account_circle_outlined,
                              color: Colors.grey, size: 30),
                          radius: 25,
                        ),
                  title: Text(tweet['username'],
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w400)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        tweet['tweet'],
                        style: TextStyle(fontSize: 18),
                      ),
                      if (tweet['photo'] != null) SizedBox(height: 10),
                      if (tweet['photo'] != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(tweet['photo'],
                              width: double.infinity,
                              height: 150,
                              fit: BoxFit.cover),
                        ),
                      SizedBox(height: 6),
                      Text(
                        tweet['timestamp'] ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showTweetDialog,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
