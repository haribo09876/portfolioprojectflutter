import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  bool isLoading = false;
  String itemTitle = '';
  String itemPrice = '';
  String itemDetail = '';
  XFile? file;
  bool isModalVisible = false;
  String userEmail = 'user@example.com';

  final ImagePicker _picker = ImagePicker();

  void onChangeItemTitle(String text) {
    setState(() {
      itemTitle = text;
    });
  }

  void onChangeItemPrice(String text) {
    setState(() {
      itemPrice = text;
    });
  }

  void onChangeItemDetail(String text) {
    setState(() {
      itemDetail = text;
    });
  }

  Future<void> onFileChange() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        file = pickedFile;
      });
    }
  }

  void clearFile() {
    setState(() {
      file = null;
    });
  }

  void onSubmit() {
    if (itemTitle.isEmpty || itemTitle.length > 180) {
      return;
    }
    setState(() {
      isLoading = true;
    });

    setState(() {
      itemTitle = '';
      itemPrice = '';
      itemDetail = '';
      file = null;
      isModalVisible = false;
      isLoading = false;
    });
  }

  void openModal() {
    setState(() {
      isModalVisible = true;
    });
  }

  void closeModal() {
    setState(() {
      isModalVisible = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop Page'),
      ),
      body: Stack(
        children: [
          if (userEmail == 'admin@gmail.com')
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ElevatedButton(
                  onPressed: openModal,
                  child: Text('새 상품 추가'),
                ),
              ),
            ),
          Center(
            child: Text('Shop Timeline Placeholder'),
          ),
          if (isModalVisible)
            Center(
              child: Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: closeModal,
                          ),
                        ),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Item Title',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: onChangeItemTitle,
                          maxLength: 50,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Item Price',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: onChangeItemPrice,
                          maxLength: 9,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Item Detail',
                            border: OutlineInputBorder(),
                          ),
                          onChanged: onChangeItemDetail,
                          maxLines: 5,
                        ),
                        SizedBox(height: 10),
                        if (file != null)
                          Column(
                            children: [
                              Image.file(
                                File(file!.path),
                                height: 200,
                              ),
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
                              child: Text('Add Photo'),
                            ),
                            ElevatedButton(
                              onPressed: onSubmit,
                              child: isLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text('Post Shop'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
