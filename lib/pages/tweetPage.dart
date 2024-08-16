import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TweetPage extends StatefulWidget {
  @override
  _TweetPageState createState() => _TweetPageState();
}

class _TweetPageState extends State<TweetPage> {
  bool _isLoading = false;
  final TextEditingController _tweetController = TextEditingController();
  XFile? _file;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    _tweetController.dispose();
    super.dispose();
  }

  Future<void> _onFileChange() async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          content: Text('Choose how you want to add a photo.'),
          actions: <Widget>[
            TextButton(
              child: Text('Take Photo'),
              onPressed: () => Navigator.pop(context, ImageSource.camera),
            ),
            TextButton(
              child: Text('Choose from Library'),
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        );
      },
    );

    if (source != null) {
      final XFile? selectedImage = await _picker.pickImage(source: source);
      if (selectedImage != null) {
        setState(() {
          _file = selectedImage;
        });
      }
    }
  }

  void _clearFile() {
    setState(() {
      _file = null;
    });
  }

  void _onSubmit() async {
    final tweet = _tweetController.text;

    if (tweet.isEmpty || tweet.length > 180) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    setState(() {
      _tweetController.clear();
      _file = null;
      _isLoading = false;
    });

    Navigator.of(context).pop();
  }

  void _showTweetDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Add Tweet'),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _tweetController,
                maxLength: 180,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'What’s happening?',
                  counterText: '',
                ),
                maxLines: 5,
              ),
              if (_file != null) ...[
                SizedBox(height: 16),
                Image.file(
                  File(_file!.path),
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                TextButton(
                  onPressed: _clearFile,
                  child:
                      Text('Remove Image', style: TextStyle(color: Colors.red)),
                ),
              ],
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: _onFileChange,
              child: Text('Add photo', style: TextStyle(color: Colors.blue)),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _onSubmit,
              child: Text(
                _isLoading ? 'Posting...' : 'Post Tweet',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showTweetDialog,
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        tooltip: 'Add Tweet',
        elevation: 6.0,
      ),
    );
  }
}
