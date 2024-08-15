import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class Shop extends StatefulWidget {
  final String id;
  final String username;
  final String itemTitle;
  final double itemPrice;
  final String itemDetail;
  final String photo;

  Shop({
    required this.id,
    required this.username,
    required this.itemTitle,
    required this.itemPrice,
    required this.itemDetail,
    required this.photo,
  });

  @override
  _ShopState createState() => _ShopState();
}

class _ShopState extends State<Shop> {
  bool _modalVisible = false;
  bool _editModalVisible = false;
  late String _newItemTitle;
  late double _newItemPrice;
  late String _newItemDetail;
  late String _newPhoto;
  XFile? _imageFile;

  final _currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _newItemTitle = widget.itemTitle;
    _newItemPrice = widget.itemPrice;
    _newItemDetail = widget.itemDetail;
    _newPhoto = widget.photo;
  }

  Future<void> _deleteShop() async {
    try {
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(widget.id)
          .delete();
      if (widget.photo.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(widget.photo).delete();
      }
    } catch (error) {
      print('Error deleting shop: $error');
    }
  }

  Future<void> _editShop() async {
    try {
      String updatedPhoto = _newPhoto;
      if (_imageFile != null) {
        final reference = FirebaseStorage.instance
            .ref()
            .child('shops/${_currentUser?.uid}/${widget.id}');
        await reference.putFile(File(_imageFile!.path));
        updatedPhoto = await reference.getDownloadURL();
      }
      await FirebaseFirestore.instance
          .collection('shops')
          .doc(widget.id)
          .update({
        'itemTitle': _newItemTitle,
        'itemPrice': _newItemPrice,
        'itemDetail': _newItemDetail,
        'photo': updatedPhoto,
        'modifiedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        _editModalVisible = false;
        _modalVisible = false;
      });
    } catch (error) {
      print('Error updating shop: $error');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    setState(() {
      _imageFile = pickedFile;
    });
  }

  Future<void> _purchase() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('moneys')
          .where('userEmail', isEqualTo: _currentUser?.email)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var document in querySnapshot.docs) {
          final currentSpend = document.data()['spend'] as double;
          final updatedSpend = currentSpend + widget.itemPrice;
          await document.reference.update({
            'spend': updatedSpend,
            'modifiedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        print('No documents found with the given userEmail.');
      }

      final moneyRef = FirebaseFirestore.instance.collection('sales').doc();
      final moneyData = {
        'createdAt': FieldValue.serverTimestamp(),
        'itemId': widget.id,
        'itemTitle': widget.itemTitle,
        'itemPrice': widget.itemPrice,
        'userId': _currentUser?.uid,
      };
      await moneyRef.set(moneyData);
      Navigator.of(context).pushNamed('/completionPage');
    } catch (error) {
      print('Error purchase: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() {
        _modalVisible = true;
      }),
      child: Container(
        width: MediaQuery.of(context).size.width / 2,
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(vertical: 5),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.itemTitle, style: TextStyle(fontSize: 16)),
            if (widget.photo.isNotEmpty)
              Image.network(widget.photo, height: 200, fit: BoxFit.cover),
            Text('${widget.itemPrice} 원', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

class ShopTimeline extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shops')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final shops = snapshot.data!.docs.map((doc) {
          return Shop(
            id: doc.id,
            username: doc['username'],
            itemTitle: doc['itemTitle'],
            itemPrice: doc['itemPrice'],
            itemDetail: doc['itemDetail'],
            photo: doc['photo'],
          );
        }).toList();

        return GridView.builder(
          itemCount: shops.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
          itemBuilder: (context, index) {
            return shops[index];
          },
        );
      },
    );
  }
}
