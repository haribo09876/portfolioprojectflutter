import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class InstaPost extends StatefulWidget {
  final String username;
  final String avatar;
  final String insta;
  final String photo;
  final String id;
  final String userId;

  InstaPost(
      {required this.username,
      required this.avatar,
      required this.insta,
      required this.photo,
      required this.id,
      required this.userId});

  @override
  _InstaPostState createState() => _InstaPostState();
}

class _InstaPostState extends State<InstaPost> {
  User? currentUser = FirebaseAuth.instance.currentUser;
  bool _modalVisible = false;
  bool _editModalVisible = false;
  String? _newInsta;
  String? _newPhoto;
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    _newInsta = widget.insta;
    _newPhoto = widget.photo;
  }

  Future<void> deleteInsta() async {
    try {
      await FirebaseFirestore.instance
          .collection('instas')
          .doc(widget.id)
          .delete();
      if (widget.photo.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(widget.photo).delete();
      }
    } catch (error) {
      print('Error deleting insta: $error');
    }
  }

  Future<void> editInsta() async {
    try {
      String updatedPhoto = _newPhoto ?? widget.photo;
      if (_imageFile != null) {
        final ref = FirebaseStorage.instance
            .ref('instas/${currentUser?.uid}/${widget.id}');
        await ref.putFile(_imageFile!);
        updatedPhoto = await ref.getDownloadURL();
      }

      await FirebaseFirestore.instance
          .collection('instas')
          .doc(widget.id)
          .update({
        'insta': _newInsta,
        'photo': updatedPhoto,
        'modifiedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _editModalVisible = false;
        _modalVisible = false;
      });
    } catch (error) {
      print('Error updating insta: $error');
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _modalVisible = true;
        });
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 3,
        height: MediaQuery.of(context).size.width / 3,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: widget.photo.isNotEmpty
            ? Image.network(widget.photo, fit: BoxFit.cover)
            : Container(color: Colors.grey[200]),
      ),
    );
  }
}

class InstaTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('instas')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final instas = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return InstaPost(
            username: data['username'],
            avatar: '', // 추가 구현 필요
            insta: data['insta'],
            photo: data['photo'],
            id: doc.id,
            userId: data['userId'],
          );
        }).toList();

        return GridView.builder(
          itemCount: instas.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, index) {
            return instas[index];
          },
        );
      },
    );
  }
}
