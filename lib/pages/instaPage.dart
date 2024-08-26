import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../services/login.dart';
import '../services/insta.dart';

class InstaPage extends StatefulWidget {
  @override
  _InstaPageState createState() => _InstaPageState();
}

class _InstaPageState extends State<InstaPage> {
  final TextEditingController _instaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Map<String, dynamic>> instas = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchInstas();
  }

  Future<void> fetchInstas() async {
    setState(() {
      loading = true;
    });

    final instaService = InstaService();
    final fetchedInstas = await instaService.instaRead();

    setState(() {
      instas = fetchedInstas;
      loading = false;
    });
  }

  Future<void> _postInsta() async {
    if (_instaController.text.isEmpty) return;

    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await InstaService().instaCreate(
        userId,
        _instaController.text,
        _imageFile != null ? XFile(_imageFile!.path) : null,
      );
      print('Insta posted successfully');
    } catch (error) {
      print('Error posting insta: $error');
    }

    setState(() {
      _instaController.clear();
      _imageFile = null;
    });
    fetchInstas();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showInstaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Create Insta Post',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _instaController,
                  decoration: InputDecoration(
                    hintText: 'Write a caption...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  maxLines: null,
                ),
                if (_imageFile != null)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: Image.file(_imageFile!, fit: BoxFit.cover),
                  ),
                TextButton(
                  onPressed: () async {
                    await _pickImage();
                    Navigator.of(context).pop();
                    _showInstaDialog();
                  },
                  child: Text('Change Image'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _imageFile = null;
                });
                Navigator.of(context).pop();
                _showInstaDialog();
              },
              child: Text('Remove Image'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _postInsta();
              },
              child: Text('Post'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            ),
          ],
        );
      },
    );
  }

  void _showInstaPostDialog(Map<String, dynamic> insta) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                insta['username'],
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(insta['photo'], fit: BoxFit.cover),
              SizedBox(height: 5),
              Text(
                insta['instaContents'],
                textAlign: TextAlign.left,
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: instas.length,
              itemBuilder: (context, index) {
                final insta = instas[index];
                return GestureDetector(
                  onTap: () => _showInstaPostDialog(insta),
                  child: Image.network(
                    insta['photo'] ?? '',
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInstaDialog();
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
