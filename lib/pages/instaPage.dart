import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class InstaPage extends StatefulWidget {
  @override
  _InstaPageState createState() => _InstaPageState();
}

class _InstaPageState extends State<InstaPage> {
  bool _isLoading = false;
  String _instaText = '';
  XFile? _selectedFile;

  final ImagePicker _picker = ImagePicker();

  void _onChange(String text) {
    setState(() {
      _instaText = text;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        final double fileSizeInMB = (await pickedFile.length()) / (1024 * 1024);
        if (fileSizeInMB > 3) {
          _showErrorDialog('The selected image exceeds the 3MB size limit.');
        } else {
          setState(() {
            _selectedFile = pickedFile;
          });
        }
      }
    } catch (e) {
      _showErrorDialog('ImagePicker Error: $e');
    }
  }

  void _onFileChange() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Library'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  void _clearFile() {
    setState(() {
      _selectedFile = null;
    });
  }

  void _onSubmit() {
    if (_isLoading || _instaText.isEmpty || _instaText.length > 180) return;

    setState(() {
      _isLoading = true;
    });

    setState(() {
      _instaText = '';
      _selectedFile = null;
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _openModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  onChanged: _onChange,
                  maxLength: 180,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (_selectedFile != null) ...[
                  SizedBox(height: 10),
                  Image.file(
                    File(_selectedFile!.path),
                    height: 200,
                  ),
                  TextButton(
                    onPressed: _clearFile,
                    child: Text('Remove Image'),
                  ),
                ],
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: _onFileChange,
                      child: Text('Add photo'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _onSubmit,
                      child: _isLoading
                          ? CircularProgressIndicator()
                          : Text('Post Insta'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Insta Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _openModal,
          child: Text('새 Insta 추가'),
        ),
      ),
    );
  }
}
