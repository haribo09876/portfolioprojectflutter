import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserInsta extends StatefulWidget {
  @override
  _UserInstaState createState() => _UserInstaState();
}

class _UserInstaState extends State<UserInsta> {
  final TextEditingController _instaController = TextEditingController();
  bool _isLoading = false;
  XFile? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? selectedImage = await _picker.pickImage(source: source);
    if (selectedImage != null) {
      final int fileSize = await selectedImage.length();
      if (fileSize / (1024 * 1024) > 3) {
        _showAlert('파일 크기 초과', '선택한 이미지가 3MB를 초과합니다.');
      } else {
        setState(() {
          _imageFile = selectedImage;
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
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitInsta() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null ||
        _isLoading ||
        _instaController.text.isEmpty ||
        _instaController.text.length > 180) {
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final DocumentReference instaRef =
          FirebaseFirestore.instance.collection('instas').doc();
      final instaData = {
        'insta': _instaController.text,
        'createdAt': FieldValue.serverTimestamp(),
        'username': user.displayName ?? 'Anonymous',
        'userId': user.uid,
        'modifiedAt': FieldValue.serverTimestamp(),
      };

      await instaRef.set(instaData);

      if (_imageFile != null) {
        final Reference storageRef =
            FirebaseStorage.instance.ref('instas/${user.uid}/${instaRef.id}');
        final UploadTask uploadTask =
            storageRef.putFile(File(_imageFile!.path));

        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          // Do something if needed during upload
        }, onError: (e) {
          print('Image upload error: $e');
          _showAlert('업로드 오류', '이미지 업로드 중 오류가 발생했습니다.');
        });

        final TaskSnapshot completedTask = await uploadTask;
        final String downloadUrl = await completedTask.ref.getDownloadURL();
        await instaRef.update({'photo': downloadUrl});

        setState(() {
          _imageFile = null;
        });
      }

      _instaController.clear();
      Navigator.of(context).pop();
    } catch (error) {
      print('Insta submission error: $error');
      _showAlert('제출 오류', '인스타 제출 중 오류가 발생했습니다.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withOpacity(0.5),
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                TextField(
                  controller: _instaController,
                  maxLength: 180,
                  maxLines: null,
                  decoration: InputDecoration(
                    hintText: '내용을 입력하세요',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                if (_imageFile != null)
                  Column(
                    children: [
                      Image.file(File(_imageFile!.path), height: 200),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _imageFile = null;
                          });
                        },
                        child: Text('이미지 제거'),
                      ),
                    ],
                  ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _pickImage(ImageSource.gallery),
                      child: Text('사진 추가'),
                    ),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitInsta,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('게시'),
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
        title: Text('User Insta'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _openModal,
          ),
        ],
      ),
      body: UserInstaTimeline(),
    );
  }
}

class UserInstaTimeline extends StatefulWidget {
  @override
  _UserInstaTimelineState createState() => _UserInstaTimelineState();
}

class _UserInstaTimelineState extends State<UserInstaTimeline> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final User? user = _auth.currentUser;

    if (user == null) {
      return Center(
        child: Text('로그인이 필요합니다.'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('instas')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('게시물이 없습니다.'));
        }

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final doc = snapshot.data!.docs[index];
            final data = doc.data() as Map<String, dynamic>;

            return InstaItem(
              username: data['username'] ?? 'Anonymous',
              insta: data['insta'],
              createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
              photoUrl: data['photo'],
            );
          },
        );
      },
    );
  }
}

class InstaItem extends StatelessWidget {
  final String username;
  final String insta;
  final DateTime? createdAt;
  final String? photoUrl;

  InstaItem({
    required this.username,
    required this.insta,
    this.createdAt,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            title: Text(username),
            subtitle: Text(DateFormat('yyyy-MM-dd HH:mm')
                .format(createdAt ?? DateTime.now())),
          ),
          if (photoUrl != null) Image.network(photoUrl!),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(insta),
          ),
        ],
      ),
    );
  }
}
