import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  bool isLoading = false;
  String tweet = '';
  File? file;
  final ImagePicker _picker = ImagePicker();
  final String apiUrl = dotenv.env['TWEET_FUNC_URL'] ?? '';

  void onChange(String text) {
    setState(() {
      tweet = text;
    });
  }

  Future<void> onFileChange() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Text('Choose an option'),
          actions: [
            TextButton(
              onPressed: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() {
                    file = File(pickedFile.path);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Camera'),
            ),
            TextButton(
              onPressed: () async {
                final pickedFile =
                    await _picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    file = File(pickedFile.path);
                  });
                }
                Navigator.of(context).pop();
              },
              child: Text('Gallery'),
            ),
          ],
        );
      },
    );
  }

  Future<void> postTweet() async {
    setState(() {
      isLoading = true;
    });

    final requestPayload = {
      'action': 'create',
      'tweetContents': tweet,
    };

    if (file != null) {
      final imageBytes = await file!.readAsBytes();
      requestPayload['fileContent'] = base64Encode(imageBytes);
    }

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestPayload),
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      // Handle success
      Navigator.pop(context);
    } else {
      print('Error posting tweet: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Tweet'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              onChanged: onChange,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'What\'s on your mind?',
              ),
            ),
            SizedBox(height: 10),
            if (file != null) Image.file(file!, height: 200, fit: BoxFit.cover),
            ElevatedButton(
              onPressed: onFileChange,
              child: Text('Select Image'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: postTweet,
              child: isLoading ? CircularProgressIndicator() : Text('Post'),
            ),
          ],
        ),
      ),
    );
  }
}
