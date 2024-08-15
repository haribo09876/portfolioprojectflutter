import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class UserTweet extends StatefulWidget {
  @override
  _UserTweetState createState() => _UserTweetState();
}

class _UserTweetState extends State<UserTweet> {
  final TextEditingController _tweetController = TextEditingController();
  bool _isLoading = false;
  File? _imageFile;
  final picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      final fileSizeInMB = File(pickedFile.path).lengthSync() / (1024 * 1024);
      if (fileSizeInMB > 3) {
        _showAlert('File size error',
            'The selected image exceeds the 3MB size limit.');
      } else {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    }
  }

  void _showAlert(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitTweet() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        _isLoading ||
        _tweetController.text.isEmpty ||
        _tweetController.text.length > 180) return;

    setState(() {
      _isLoading = true;
    });

    try {
      DocumentReference tweetRef =
          FirebaseFirestore.instance.collection('tweets').doc();
      Map<String, dynamic> tweetData = {
        'tweet': _tweetController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'username': user.displayName ?? 'Anonymous',
        'userId': user.uid,
        'modifiedAt': FieldValue.serverTimestamp(),
      };
      await tweetRef.set(tweetData);

      if (_imageFile != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('tweets/${user.uid}/${tweetRef.id}');
        await storageRef.putFile(_imageFile!);
        String url = await storageRef.getDownloadURL();
        await tweetRef.update({'photo': url});
        setState(() {
          _imageFile = null;
        });
      }

      _tweetController.clear();
      Navigator.of(context).pop();
    } catch (error) {
      _showAlert(
          'Submission Error', 'There was an error submitting your tweet.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showTweetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _tweetController,
                  maxLength: 180,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              if (_imageFile != null)
                Column(
                  children: [
                    Image.file(
                      _imageFile!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _imageFile = null;
                        });
                      },
                      child: Text("Remove Image"),
                    ),
                  ],
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => _pickImage(ImageSource.camera),
                    child: Text('Take Photo'),
                  ),
                  TextButton(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: Text('Choose from Library'),
                  ),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitTweet,
                    child: _isLoading
                        ? CircularProgressIndicator()
                        : Text('Post Tweet'),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tweets'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showTweetModal,
          ),
        ],
      ),
      body: UserTweetTimeline(),
    );
  }
}

class UserTweetTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tweets')
          .where('userId', isEqualTo: user?.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var tweets = snapshot.data!.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          return Tweet(
            tweet: data['tweet'],
            createdAt: (data['createdAt'] as Timestamp).toDate(),
            userId: data['userId'],
            username: data['username'],
            photo: data['photo'],
          );
        }).toList();

        return ListView(
          padding: EdgeInsets.all(5),
          children: tweets,
        );
      },
    );
  }
}

class Tweet extends StatelessWidget {
  final String tweet;
  final DateTime createdAt;
  final String userId;
  final String username;
  final String? photo;

  Tweet({
    required this.tweet,
    required this.createdAt,
    required this.userId,
    required this.username,
    this.photo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              tweet,
              style: TextStyle(fontSize: 16),
            ),
            if (photo != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Image.network(photo!),
              ),
            SizedBox(height: 5),
            Text(
              '${createdAt.toLocal()}',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
