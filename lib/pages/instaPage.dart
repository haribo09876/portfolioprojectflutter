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

  Future<void> _editInsta(String instaId, String instaContents) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await InstaService().instaUpdate(
        instaId,
        userId,
        instaContents,
        _imageFile != null ? XFile(_imageFile!.path) : null,
      );
      print('Insta updated successfully');
      fetchInstas();
    } catch (error) {
      print('Error updating insta: $error');
    }
  }

  Future<void> _deleteInsta(String instaId) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await InstaService().instaDelete(instaId, userId);
      print('Insta deleted successfully');
      fetchInstas();
    } catch (error) {
      print('Error deleting insta: $error');
    }
  }

  void _showInstaDetailDialog(Map<String, dynamic> insta) {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

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
                insta['username'] ?? 'Unknown User',
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
              if (insta['photo'] != null)
                Image.network(insta['photo'], fit: BoxFit.cover)
              else
                Container(
                  color: Colors.grey[200],
                  height: 200,
                  width: double.infinity,
                  child: Center(child: Text('No Image')),
                ),
              SizedBox(height: 5),
              Text(
                insta['instaContents'] ?? 'No Content',
                textAlign: TextAlign.left,
              ),
              SizedBox(height: 20),
              if (insta['userId'] == userId)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit_outlined, color: Colors.blue),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showEditInstaDialog(insta);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        Navigator.of(context).pop();
                        _showDeleteConfirmationDialog(insta['id']);
                      },
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  void _showEditInstaDialog(Map<String, dynamic> insta) {
    final controller = TextEditingController(text: insta['insta']);
    File? _newImageFile = null;
    String? existingImageUrl = insta['photo'];

    void _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _newImageFile = File(pickedFile.path);
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Edit Insta', style: TextStyle(fontSize: 22)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: 'Update your insta',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 10),
                if (_newImageFile != null || existingImageUrl != null)
                  Stack(
                    children: [
                      if (_newImageFile != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _newImageFile!,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        )
                      else if (existingImageUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            existingImageUrl!,
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
                            setState(() {
                              _newImageFile = null;
                            });
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
                      onPressed: () async {
                        final instaService = InstaService();
                        final userId =
                            Provider.of<LoginService>(context, listen: false)
                                    .userInfo?['id'] ??
                                '';
                        String? imageUrl =
                            _newImageFile != null ? null : existingImageUrl;
                        await instaService.instaUpdate(
                          insta['id'],
                          userId,
                          controller.text,
                          _newImageFile != null
                              ? XFile(_newImageFile!.path)
                              : null,
                        );
                        Navigator.of(context).pop();
                        fetchInstas();
                      },
                      child: Text(
                        'Update',
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

  void _showDeleteConfirmationDialog(String instaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Delete Insta', style: TextStyle(fontSize: 22)),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.3,
            child: Center(
              child: Text('Are you sure you want to delete this insta?'),
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
                await _deleteInsta(instaId);
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
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: fetchInstas,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: instas.length,
                itemBuilder: (context, index) {
                  final insta = instas[index];
                  return GestureDetector(
                    onTap: () => _showInstaDetailDialog(insta),
                    child: Image.network(
                      insta['photo'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[200],
                          child: Center(child: Text('No Image')),
                        );
                      },
                    ),
                  );
                },
              ),
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
