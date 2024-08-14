import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  bool isLoading = false;
  String tweet = '';
  File? file;
  final ImagePicker _picker = ImagePicker();

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
                Navigator.of(context).pop();
                final pickedFile = await _picker.pickImage(
                    source: ImageSource.camera,
                    imageQuality: 50,
                    maxWidth: 600);
                if (pickedFile != null) {
                  setState(() {
                    file = File(pickedFile.path);
                  });
                }
              },
              child: Text('Take Photo'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final pickedFile = await _picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 50,
                    maxWidth: 600);
                if (pickedFile != null) {
                  setState(() {
                    file = File(pickedFile.path);
                  });
                }
              },
              child: Text('Choose from Library'),
            ),
          ],
        );
      },
    );
  }

  void clearFile() {
    setState(() {
      file = null;
    });
  }

  void onSubmit() {
    if (tweet.isEmpty || isLoading || tweet.length > 180) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    setState(() {
      tweet = '';
      file = null;
      isLoading = false;
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tweet Page'),
      ),
      body: Center(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              maxLength: 180,
                              maxLines: 5,
                              onChanged: onChange,
                              decoration: InputDecoration(
                                hintText: '내용을 입력하세요',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            if (file != null)
                              Column(
                                children: [
                                  Image.file(file!),
                                  TextButton(
                                    onPressed: clearFile,
                                    child: Text('Remove Image'),
                                  ),
                                ],
                              ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: onFileChange,
                                  child: Text('Add photo'),
                                ),
                                ElevatedButton(
                                  onPressed: onSubmit,
                                  child: isLoading
                                      ? CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Colors.white),
                                        )
                                      : Text('Post Tweet'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              child: Text('새 Tweet 추가'),
            ),
          ],
        ),
      ),
    );
  }
}
