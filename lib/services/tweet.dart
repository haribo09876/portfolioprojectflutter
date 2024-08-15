import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

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
  final User? currentUser = FirebaseAuth.instance.currentUser;
  bool modalVisible = false;
  bool editModalVisible = false;
  String newTweet = '';
  String? newPhoto;
  String? imageUri;

  @override
  void initState() {
    super.initState();
    newTweet = widget.tweet;
    newPhoto = widget.photo;
  }

  Future<void> deleteTweet() async {
    try {
      await FirebaseFirestore.instance
          .collection('tweets')
          .doc(widget.id)
          .delete();
      if (widget.photo != null) {
        final storageRef = FirebaseStorage.instance.refFromURL(widget.photo!);
        await storageRef.delete();
      }
    } catch (error) {
      print('Error deleting tweet: $error');
    }
  }

  Future<void> editTweet() async {
    try {
      String? updatedPhoto = newPhoto;
      if (imageUri != null) {
        final reference = FirebaseStorage.instance
            .ref('/tweets/${currentUser!.uid}/${widget.id}');
        await reference.putFile(File(imageUri!));
        updatedPhoto = await reference.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('tweets')
          .doc(widget.id)
          .update({
        'tweet': newTweet,
        'photo': updatedPhoto,
        'modifiedAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        editModalVisible = false;
        modalVisible = false;
      });
    } catch (error) {
      print('Error updating tweet: $error');
    }
  }

  Future<void> onFileChange() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        imageUri = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => modalVisible = true),
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

  Widget buildModal() {
    return Modal(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => setState(() => modalVisible = false),
          child: Container(
            color: Colors.black54,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Icon(Icons.account_circle, size: 50),
                        Text(widget.username,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333))),
                        if (widget.photo != null)
                          Image.network(widget.photo!,
                              height: 200, fit: BoxFit.cover),
                        Text(widget.tweet,
                            style: TextStyle(
                                fontSize: 16, color: Color(0xFF666666))),
                        if (currentUser != null &&
                            (currentUser!.uid == widget.userId ||
                                currentUser!.email == 'admin@gmail.com'))
                          Column(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: deleteTweet,
                                color: Colors.red,
                              ),
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () =>
                                    setState(() => editModalVisible = true),
                                color: Colors.blue,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildEditModal() {
    return Modal(
      context: context,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () => setState(() => editModalVisible = false),
          child: Container(
            color: Colors.black54,
            child: Center(
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(widget.username,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF333333))),
                        if (imageUri != null)
                          Image.file(File(imageUri!),
                              height: 200, fit: BoxFit.cover),
                        TextField(
                          controller: TextEditingController(text: newTweet),
                          onChanged: (value) => newTweet = value,
                          maxLines: null,
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Edit your tweet',
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onFileChange,
                          child: Text('Change Photo'),
                        ),
                        ElevatedButton(
                          onPressed: editTweet,
                          child: Text('Save'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class TweetTimeline extends StatefulWidget {
  @override
  _TweetTimelineState createState() => _TweetTimelineState();
}

class _TweetTimelineState extends State<TweetTimeline> {
  final List<Map<String, dynamic>> tweets = [];

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection('tweets')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((querySnapshot) {
      setState(() {
        tweets.clear();
        for (var doc in querySnapshot.docs) {
          tweets.add({
            'id': doc.id,
            'username': doc['username'],
            'tweet': doc['tweet'],
            'photo': doc['photo'],
            'userId': doc['userId'],
            'createdAt': doc['createdAt']?.toDate(),
          });
        }
      });
    });
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
