import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/login.dart';
import '../services/shop.dart';
import '../services/purchase.dart';

class ShopPage extends StatefulWidget {
  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final TextEditingController _itemTitleController = TextEditingController();
  final TextEditingController _itemController = TextEditingController();
  final TextEditingController _itemPriceController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  late String userId;
  List<Map<String, dynamic>> items = [];
  String? adminId = dotenv.env['ADMIN_ID'];
  File? _imageFile;
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
            borderRadius: BorderRadius.circular(5),
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
                      borderRadius: BorderRadius.circular(5),
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
                      borderRadius: BorderRadius.circular(5),
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
                      borderRadius: BorderRadius.circular(5),
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
                        borderRadius: BorderRadius.circular(5),
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

  Future<void> _deleteItem(String itemId) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await ShopService().itemDelete(itemId, userId);
      print('Item deleted successfully');
      fetchItems();
    } catch (error) {
      print('Error deleting item: $error');
    }
  }

  void _showItemDetailDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(item['itemTitle'] ?? 'No Title',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w400)),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.black54),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  if (item['photo'] != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Image.network(
                        item['photo'],
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(child: Text('Failed to load image'));
                        },
                      ),
                    ),
                  ],
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Spacer(),
                      Text(
                        '${NumberFormat('###,###,###').format(item['itemPrice'] ?? 0)}원 ',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(item['itemContents'] ?? 'No Contents',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w400)),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      await _purchaseItem(item);
                      _showPurchaseConfirmationDialog();
                    },
                    child: Text('Buy'),
                  ),
                  if (userId == adminId) ...[
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit_outlined, color: Colors.blue),
                          onPressed: () {
                            _itemTitleController.text = item['itemTitle'] ?? '';
                            _itemController.text = item['itemContents'] ?? '';
                            _itemPriceController.text =
                                item['itemPrice']?.toString() ?? '';
                            _imageFile = null;
                            Navigator.of(context).pop();
                            _showEditDialog(item['itemId']);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(item['itemId']);
                          },
                        ),
                      ],
                    ),
                  ],
                ],
              ),
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
            borderRadius: BorderRadius.circular(5),
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
                      borderRadius: BorderRadius.circular(5),
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
                      borderRadius: BorderRadius.circular(5),
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
                      borderRadius: BorderRadius.circular(5),
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
                        borderRadius: BorderRadius.circular(5),
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
                      child: Text('Pick Image'),
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
                      child: Text('Update Item'),
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

  Future<void> _purchaseItem(Map<String, dynamic> item) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    if (userId.isEmpty) return;

    final itemId = item['itemId'];

    try {
      await PurchaseService().purchaseCreate(
        userId,
        itemId,
      );
      fetchItems();
    } catch (error) {
      print('Error processing purchase: $error');
    }
  }

  void _showDeleteConfirmationDialog(String itemId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Delete Item',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Are you sure you want to delete this item?',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF44558C8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () async {
                await _deleteItem(itemId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 5),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromARGB(242, 242, 242, 242),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color.fromRGBO(52, 52, 52, 52),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPurchaseConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                Center(
                  child: Text(
                    'Thank you for your purchase!',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: Text('OK'),
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
    final loginService = Provider.of<LoginService>(context, listen: false);
    userId = loginService.userInfo?['id'] ?? '';
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Container(
          width: 360,
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                  child: loading
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
                            childAspectRatio: 0.65,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              color: Color.fromARGB(242, 242, 242, 242),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: InkWell(
                                onTap: () => _showItemDetailDialog(item),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(15),
                                        ),
                                        child: item['photo'] != null
                                            ? Image.network(
                                                item['photo'] ?? '',
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  return Center(
                                                    child: Text(
                                                      'Failed to load image',
                                                    ),
                                                  );
                                                },
                                              )
                                            : Container(
                                                color: Color.fromARGB(
                                                    255, 255, 255, 255),
                                                child: Center(
                                                  child: Icon(
                                                    Icons.image,
                                                    size: 50,
                                                    color: Color.fromARGB(
                                                        242, 242, 242, 242),
                                                  ),
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['itemTitle'] ?? 'No Title',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Spacer(),
                                              Text(
                                                '${NumberFormat('###,###,###').format(item['itemPrice'] ?? 0)}원 ',
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  color: Color.fromRGBO(
                                                      52, 52, 52, 52),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
              SizedBox(height: 5),
            ],
          ),
        ),
      ),
      floatingActionButton: (userId == adminId)
          ? FloatingActionButton(
              onPressed: () {
                _itemTitleController.clear();
                _itemController.clear();
                _itemPriceController.clear();
                _imageFile = null;
                _showItemDialog();
              },
              backgroundColor: Color(0xFF44558C8),
              shape: CircleBorder(),
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
