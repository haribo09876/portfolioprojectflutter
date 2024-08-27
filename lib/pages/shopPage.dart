import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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
              Text(item['username'] ?? 'Unknown',
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
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['itemTitle'] ?? 'No Title',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w400)),
                if (item['photo'] != null) SizedBox(height: 10),
                if (item['photo'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item['photo'] ?? '',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(child: Text('Failed to load image'));
                      },
                    ),
                  ),
                SizedBox(height: 10),
                Text(
                  item['timestamp'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                if (isOwnItem) ...[
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showEditItemDialog(item);
                        },
                        child: Text('Edit'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _deleteItem(item['id'] ?? '');
                        },
                        child: Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditItemDialog(Map<String, dynamic> item) {
    final itemTitleController =
        TextEditingController(text: item['itemTitle'] ?? '');
    final itemContentsController =
        TextEditingController(text: item['itemContents'] ?? '');
    final itemPriceController =
        TextEditingController(text: (item['itemPrice'] ?? 0.0).toString());

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
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: itemTitleController,
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
                  controller: itemContentsController,
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
                  controller: itemPriceController,
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
                ElevatedButton(
                  onPressed: () {
                    final itemTitle = itemTitleController.text;
                    final itemContents = itemContentsController.text;
                    final itemPrice =
                        double.tryParse(itemPriceController.text) ?? 0.0;
                    _editItem(
                        item['id'] ?? '', itemTitle, itemContents, itemPrice);
                    Navigator.of(context).pop();
                  },
                  child: Text('Update Item'),
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
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: loading
            ? Center(child: CircularProgressIndicator())
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                padding: EdgeInsets.all(10),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
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
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Center(
                                            child:
                                                Text('Failed to load image'));
                                      },
                                    )
                                  : Container(
                                      color: Colors.grey[200],
                                      child: Center(
                                        child: Icon(Icons.image,
                                            size: 50, color: Colors.grey),
                                      ),
                                    ),
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
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  '\$${item['itemPrice'] ?? 0.0}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  item['itemContents'] ?? 'No Contents',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showItemDialog,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
