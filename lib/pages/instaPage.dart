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
      Navigator.of(context).pop();
      _showInstaDialog();
    }
  }

  void _cancelImageAttachment() {
    setState(() {
      _imageFile = null;
    });
  }

  void _showInstaDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Create Insta Post'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _instaController,
                decoration: InputDecoration(
                  hintText: 'Write something...',
                ),
              ),
              if (_imageFile != null)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Image.file(_imageFile!),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: _cancelImageAttachment,
              child: Text('Remove Image'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _postInsta();
              },
              child: Text('Post'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: instas.length,
              itemBuilder: (context, index) {
                final insta = instas[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(insta['userImgURL']),
                  ),
                  title: Text(insta['username']),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(insta['instaContents']),
                      if (insta['photo'] != null) Image.network(insta['photo']),
                    ],
                  ),
                  onTap: () {},
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
