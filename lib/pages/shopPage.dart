import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/login.dart';
import '../services/shop.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final TextEditingController _itemTitleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  List<Map<String, dynamic>> items = [];
  bool loading = false;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    setState(() {
      loading = true;
    });

    final shopService = ShopService();
    final fetchedItems = await shopService.itemRead();

    setState(() {
      items = fetchedItems;
      loading = false;
    });
  }

  Future<void> _refresh() async {
    await fetchItems();
  }

  Future<void> _postItem() async {
    if (_itemTitleController.text.isEmpty ||
        _itemController.text.isEmpty ||
        _itemPriceController.text.isEmpty) return;

    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      final itemPrice = double.tryParse(_itemPriceController.text) ?? 0.0;
      await ShopService().itemCreate(
        userId,
        _itemTitleController.text,
        _itemController.text,
        itemPrice,
        _imageFile != null ? XFile(_imageFile!.path) : null,
      );
      print('Item posted successfully');
      Navigator.of(context).pop();
    } catch (error) {
      print('Error posting item: $error');
    }

    setState(() {
      _itemTitleController.clear();
      _itemController.clear();
      _itemPriceController.clear();
      _imageFile = null;
    });
    fetchItems();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      Navigator.of(context).pop();
      _showItemDialog();
    }
  }

  void _cancelImageAttachment() {
    setState(() {
      _imageFile = null;
    });
  }

  void _showItemDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Post Item',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _itemTitleController,
                  decoration: InputDecoration(
                    hintText: 'Item Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    hintText: 'Item Contents',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _itemPriceController,
                  decoration: InputDecoration(
                    hintText: 'Item Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                if (_imageFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
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
                            _cancelImageAttachment();
                            Navigator.of(context).pop();
                            _showItemDialog();
                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Pick Image'),
                    ),
                    ElevatedButton(
                      onPressed: _postItem,
                      child: Text('Post Item'),
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

  Future<void> _editItem(String itemId, String itemTitle, String itemContents,
      double itemPrice) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await ShopService().itemUpdate(
        itemId,
        userId,
        itemTitle,
        itemContents,
        itemPrice,
        _imageFile != null ? XFile(_imageFile!.path) : null,
      );
      print('Item updated successfully');
      fetchItems();
    } catch (error) {
      print('Error updating item: $error');
    }
  }

  Future<void> _pickEditImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showItemDetailDialog(Map<String, dynamic> item) {
    final isOwnItem = item['userId'] ==
        Provider.of<LoginService>(context, listen: false).userInfo?['id'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(item['itemTitle'] ?? 'No Title',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item['photo'] != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['photo'],
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                ],
                Text(
                  item['itemContents'] ?? 'No Content',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 10),
                Text(
                  '\$${item['itemPrice']?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.green,
                      fontWeight: FontWeight.w600),
                ),
                if (isOwnItem) ...[
                  Spacer(),
                  ElevatedButton(
                    onPressed: () {
                      _itemTitleController.text = item['itemTitle'] ?? '';
                      _itemController.text = item['itemContents'] ?? '';
                      _itemPriceController.text =
                          item['itemPrice']?.toString() ?? '';
                      _imageFile = null;
                      Navigator.of(context).pop();
                      _showEditDialog(item['itemId']);
                    },
                    child: Text('Edit Item'),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Edit Item',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              IconButton(
                icon: Icon(Icons.close, color: Colors.black54),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _itemTitleController,
                  decoration: InputDecoration(
                    hintText: 'Item Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _itemController,
                  decoration: InputDecoration(
                    hintText: 'Item Contents',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _itemPriceController,
                  decoration: InputDecoration(
                    hintText: 'Item Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 10),
                if (_imageFile != null)
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _imageFile!,
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
                            _cancelImageAttachment();
                            Navigator.of(context).pop();
                            _showEditDialog(itemId);
                          },
                        ),
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: _pickEditImage,
                      child: Text('Change Image'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _editItem(
                          itemId,
                          _itemTitleController.text,
                          _itemController.text,
                          double.tryParse(_itemPriceController.text) ?? 0.0,
                        );
                        Navigator.of(context).pop();
                      },
                      child: Text('Save Changes'),
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
        title: Text('Shop'),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refresh,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: GridView.builder(
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.75,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        _showItemDetailDialog(item);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item['photo'] != null)
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(15),
                                ),
                                child: Image.network(
                                  item['photo'],
                                  height: 120,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['itemTitle'] ?? 'No Title',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    '\$${item['itemPrice']?.toStringAsFixed(2) ?? '0.00'}',
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _itemTitleController.clear();
          _itemController.clear();
          _itemPriceController.clear();
          _imageFile = null;
          _showItemDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
