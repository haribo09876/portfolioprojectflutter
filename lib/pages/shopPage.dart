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
    fetchItems(); // Fetch shop items on widget init (위젯 초기화 시 아이템 목록 조회)
  }

  Future<void> fetchItems() async {
    setState(() {
      loading = true;
    });

    final shopService = ShopService();
    final fetchedItems =
        await shopService.itemRead(); // Fetch items from backend (백엔드에서 아이템 조회)

    setState(() {
      items = fetchedItems; // Update item list state (아이템 목록 상태 업데이트)
      loading = false;
    });
  }

  Future<void> _refresh() async {
    await fetchItems(); // Pull-to-refresh handler to reload items (아이템 새로고침 핸들러)
  }

  Future<void> _postItem() async {
    if (_itemTitleController.text.isEmpty ||
        _itemController.text.isEmpty ||
        _itemPriceController.text.isEmpty)
      return; // Input validation check (입력 유효성 검사)

    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ??
        ''; // Get current user ID (현재 사용자 ID 획득)

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
      _itemTitleController.clear(); // Clear input fields (입력 필드 초기화)
      _itemController.clear();
      _itemPriceController.clear();
      _imageFile = null;
    });
    fetchItems(); // Refresh item list after posting (게시 후 아이템 목록 갱신)
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery); // Launch image picker (갤러리에서 이미지 선택)
    if (pickedFile != null) {
      setState(() {
        _imageFile =
            File(pickedFile.path); // Store picked image file (선택한 이미지 파일 저장)
      });
      Navigator.of(context).pop();
      _showItemDialog();
    }
  }

  void _cancelImageAttachment() {
    setState(() {
      _imageFile = null; // Remove attached image (첨부 이미지 제거)
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
                          keyboardType: TextInputType
                              .multiline, // Multiline input for title (제목 다중행 입력)
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
                          keyboardType: TextInputType
                              .multiline, // Price input with keyboard type (가격 입력 필드)
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
                          keyboardType: TextInputType
                              .multiline, // Multiline contents input (내용 다중행 입력)
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_imageFile !=
                      null) // Display attached image preview (첨부 이미지 미리보기 표시)
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
                            icon: Icon(Icons.cancel,
                                color: Colors.red,
                                size: 30), // Cancel image button (이미지 취소 버튼)
                            onPressed: () {
                              setState(() {
                                _imageFile = null;
                              });
                              Navigator.of(context).pop();
                              _showItemDialog(); // Refresh dialog to update UI (UI 갱신을 위한 다이얼로그 재호출)
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
                      _showItemDialog(); // Refresh dialog after picking image (이미지 선택 후 다이얼로그 재오픈)
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
                      _postItem(); // Trigger item post API call (아이템 등록 API 호출)
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
      fetchItems(); // Refresh item list after update (업데이트 후 목록 갱신)
    } catch (error) {
      print('Error updating item: $error');
    }
  }

  Future<void> _deleteItem(String itemId) async {
    final loginService = Provider.of<LoginService>(context, listen: false);
    final userId = loginService.userInfo?['id'] ?? '';

    try {
      await ShopService()
          .itemDelete(itemId, userId); // Call delete API (삭제 API 호출)
      print('Item deleted successfully');
      fetchItems(); // Refresh list after deletion (삭제 후 목록 갱신)
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
                          Image.network(item['photo'],
                              fit: BoxFit
                                  .cover) // Display item image from URL (URL로부터 이미지 표시)
                        else
                          Container(
                            color: Colors.grey[200],
                            height: 200,
                            width: double.infinity,
                            child: Center(
                                child: Text(
                                    'No image')), // Placeholder if no image (이미지 없을 시 플레이스홀더)
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
                              await _purchaseItem(
                                  item); // Trigger purchase process (구매 처리 트리거)
                              _showPurchaseConfirmationDialog(); // Show confirmation UI (구매 확인 UI 표시)
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
                        // Admin-only controls (관리자 전용 기능)
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

  // Displays an edit item dialog with image picker and form fields (아이템 편집 다이얼로그 표시 및 이미지 선택 및 폼 입력 처리)
  void _showEditDialog(Map<String, dynamic> item, String itemId) {
    File? _newImageFile;
    String? existingImageUrl = item['photo'];

    // Triggers UI rebuild if widget is mounted (위젯이 마운트된 경우 UI 갱신)
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
                    // Text input for item title (아이템 제목 입력 필드)
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
                    // Text input for item price (아이템 가격 입력 필드)
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
                    // Text input for item description (아이템 설명 입력 필드)
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
                    // Display selected or existing image (선택된 또는 기존 이미지 표시)
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
                                '$existingImageUrl?${DateTime.now().millisecondsSinceEpoch}',
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
                    // Button to pick a new image (새 이미지 선택 버튼)
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
                    // Button to update item (아이템 업데이트 버튼)
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

  // Handles item purchase by logged-in user (로그인된 사용자의 아이템 구매 처리)
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
      fetchItems(); // Refresh item list after purchase (구매 후 아이템 목록 갱신)
    } catch (error) {
      print('Error processing purchase: $error');
    }
  }

  // Shows confirmation dialog for item deletion (아이템 삭제 확인 다이얼로그 표시)
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
            // Confirm deletion button (삭제 확정 버튼)
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

  // Displays confirmation message after purchase (구매 완료 후 확인 메시지 표시)
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

  // Renders the main shop UI (메인 상점 UI 렌더링)
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
              // Displays item list in grid view (그리드 형태로 아이템 목록 표시)
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
                                                '${item['photo']}?${DateTime.now().millisecondsSinceEpoch}',
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
      // FAB for admin to add item (관리자 전용 아이템 추가 버튼)
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
