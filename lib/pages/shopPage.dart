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
  String? adminId = dotenv.env['ADMIN_ID'];
  List<Map<String, dynamic>> items = [];
  bool loading = false;
  File? _imageFile;
  late String userId;

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
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Post item',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    child: Column(
                      children: [
                        TextField(
                          controller: _itemTitleController,
                          decoration: InputDecoration(
                            hintText: 'Item title',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Color(0xFF44558C8),
                                width: 1.5,
                              ),
                            ),
                          ),
                          maxLines: 2,
                          keyboardType: TextInputType.multiline,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _itemPriceController,
                          decoration: InputDecoration(
                            hintText: 'Item price',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Color(0xFF44558C8),
                                width: 1.5,
                              ),
                            ),
                          ),
                          maxLines: 1,
                          keyboardType: TextInputType.multiline,
                        ),
                        SizedBox(height: 10),
                        TextField(
                          controller: _itemController,
                          decoration: InputDecoration(
                            hintText: 'Item contents',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey,
                                width: 1.5,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Color(0xFF44558C8),
                                width: 1.5,
                              ),
                            ),
                          ),
                          maxLines: 5,
                          keyboardType: TextInputType.multiline,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_imageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.file(
                            _imageFile!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        Positioned(
                          right: 5,
                          top: 5,
                          child: IconButton(
                            icon:
                                Icon(Icons.cancel, color: Colors.red, size: 30),
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                              });
                              Navigator.of(context).pop();
                              _showItemDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(242, 242, 242, 242),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () async {
                      await _pickImage();
                      Navigator.of(context).pop();
                      _showItemDialog();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Add image',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Color.fromRGBO(52, 52, 52, 52),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF44558C8),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      _postItem();
                      Navigator.of(context).pop();
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Post',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editItem(String itemId, String itemTitle, String itemContents,
      double itemPrice, File? _newImageFile) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await ShopService().itemUpdate(
        itemId,
        userId,
        itemTitle,
        itemContents,
        itemPrice,
        _newImageFile != null ? XFile(_newImageFile!.path) : null,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item['itemTitle'] ?? 'No Title',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.close,
                            color: Color.fromRGBO(52, 52, 52, 52),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item['photo'] != null)
                          Image.network(item['photo'], fit: BoxFit.cover)
                        else
                          Container(
                            color: Colors.grey[200],
                            height: 200,
                            width: double.infinity,
                            child: Center(child: Text('No image')),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${NumberFormat('###,###,###').format(item['itemPrice'] ?? 0)}원',
                            style: TextStyle(
                                fontSize: 18, color: Colors.grey[700]),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          item['itemContents'] ?? 'No Contents',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF44558C8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () async {
                              await _purchaseItem(item);
                              _showPurchaseConfirmationDialog();
                            },
                            child: Text(
                              'Purchase',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                        if (userId == adminId) ...[
                          SizedBox(
                            height: 5,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(242, 242, 242, 242),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              _itemTitleController.text =
                                  item['itemTitle'] ?? '';
                              _itemController.text = item['itemContents'] ?? '';
                              _itemPriceController.text =
                                  item['itemPrice']?.toString() ?? '';
                              _imageFile = null;
                              _showEditDialog(item, item['itemId']);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Edit',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color.fromRGBO(52, 52, 52, 52),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFF04452),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            onPressed: () {
                              _showDeleteConfirmationDialog(item['itemId']);
                            },
                            child: SizedBox(
                              width: double.infinity,
                              child: Center(
                                child: Text(
                                  'Delete',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> item, String itemId) {
    File? _newImageFile;
    String? existingImageUrl = item['photo'];

    void refreshState() {
      if (mounted) setState(() {});
    }

    Future<void> _pickImage() async {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        _newImageFile = File(pickedFile.path);
        existingImageUrl = null;
        refreshState();
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Color.fromARGB(255, 255, 255, 255),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Edit item',
              style: TextStyle(
                fontSize: 20,
              ),
            ),
            content: SizedBox(
              width: 360,
              height: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _itemTitleController,
                      decoration: InputDecoration(
                        hintText: 'Update item title',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Color(0xFF44558C8),
                            width: 1.5,
                          ),
                        ),
                      ),
                      maxLines: 2,
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _itemPriceController,
                      decoration: InputDecoration(
                        hintText: 'Update item price',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Color(0xFF44558C8),
                            width: 1.5,
                          ),
                        ),
                      ),
                      maxLines: 1,
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _itemController,
                      decoration: InputDecoration(
                        hintText: 'Update item contents',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide(
                            color: Color(0xFF44558C8),
                            width: 1.5,
                          ),
                        ),
                      ),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                    SizedBox(height: 10),
                    if (_newImageFile != null || existingImageUrl != null)
                      Stack(
                        children: [
                          if (_newImageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.file(
                                _newImageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (existingImageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
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
                              icon: Icon(
                                Icons.cancel,
                                color: Colors.red,
                                size: 30,
                              ),
                              onPressed: () {
                                setModalState(() {
                                  _newImageFile = null;
                                  existingImageUrl = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(242, 242, 242, 242),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () async {
                        await _pickImage();
                        setModalState(() {});
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Add image',
                            style: TextStyle(
                              color: Color.fromRGBO(52, 52, 52, 52),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4558C8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () {
                        _editItem(
                          itemId,
                          _itemTitleController.text,
                          _itemController.text,
                          double.tryParse(_itemPriceController.text) ?? 0.0,
                          _newImageFile,
                        );
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Center(
                          child: Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
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
                              fontWeight: FontWeight.w500,
                              color: Color.fromRGBO(52, 52, 52, 52),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
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
            borderRadius: BorderRadius.circular(20),
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
                  fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w500,
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
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text('Purchase item',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Thank you for your purchase!',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          actions: [
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
                Navigator.of(context).pop();
              },
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
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
                            childAspectRatio: 0.6,
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            return Card(
                              color: Color.fromARGB(255, 255, 255, 255),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: InkWell(
                                onTap: () => _showItemDetailDialog(item),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
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
                                              fontSize: 20,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
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
              elevation: 0,
              shape: CircleBorder(),
              child: Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}
