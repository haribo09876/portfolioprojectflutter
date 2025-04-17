import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import '../services/login.dart';
import '../services/insta.dart';

class InstaPage extends StatefulWidget {
  @override
  _InstaPageState createState() => _InstaPageState();
}

class _InstaPageState extends State<InstaPage> {
  final TextEditingController _instaController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? adminId = dotenv.env['ADMIN_ID'];
  List<Map<String, dynamic>> instas = [];
  bool loading = false;
  File? _imageFile;

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
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Post insta',
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
                  if (_imageFile != null)
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
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
                              _showInstaDialog();
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 20),
                  Container(
                    height: 120,
                    child: SingleChildScrollView(
                      child: TextField(
                        controller: _instaController,
                        decoration: InputDecoration(
                          hintText: 'What’s happening?',
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide(
                              color: Color(0xFF44558C8),
                              width: 1.5,
                            ),
                          ),
                        ),
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                      ),
                    ),
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
                      _showInstaDialog();
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
                      backgroundColor: Color(0xFF12AC79),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    onPressed: () {
                      _postInsta();
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SizedBox(
            width: 360,
            height: 480,
            child: Container(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            insta['userImgURL'] != null &&
                                    insta['userImgURL'] != ''
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(insta['userImgURL']!),
                                    radius: 20,
                                  )
                                : CircleAvatar(
                                    child: Icon(Icons.account_circle_outlined,
                                        color: Colors.grey, size: 24),
                                    radius: 20,
                                  ),
                            SizedBox(width: 10),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                insta['username'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
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
                          if (insta['photo'] != null)
                            Image.network(insta['photo'], fit: BoxFit.cover)
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
                          Text(
                            insta['insta'] ?? 'No contents',
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Spacer(),
                              Text(
                                DateFormat('MMM d, yyyy, h:mm a').format(
                                  DateTime.parse(insta['createdAt']).toLocal(),
                                ),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Color.fromRGBO(52, 52, 52, 52),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          if (insta['userId'] ==
                                  Provider.of<LoginService>(context,
                                          listen: false)
                                      .userInfo?['id'] ||
                              Provider.of<LoginService>(context, listen: false)
                                      .userInfo?['id'] ==
                                  adminId) ...[
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF44558C8),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () {
                                _showEditInstaDialog(insta);
                              },
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Text(
                                    'Edit',
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
                                backgroundColor: Color(0xFFEE5E37),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                              onPressed: () {
                                _showDeleteConfirmationDialog(insta['id']);
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
          ),
        );
      },
    );
  }

  void _showEditInstaDialog(Map<String, dynamic> insta) {
    final controller = TextEditingController(text: insta['insta']);
    File? _newImageFile;
    String? existingImageUrl = insta['photo'];

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
              borderRadius: BorderRadius.circular(15),
            ),
            title: Text(
              'Edit insta',
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
                    if (_newImageFile != null || existingImageUrl != null)
                      Stack(
                        children: [
                          if (_newImageFile != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.file(
                                _newImageFile!,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          else if (existingImageUrl != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
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
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Update your insta',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide(
                            color: Color(0xFF44558C8),
                            width: 1.5,
                          ),
                        ),
                      ),
                      maxLines: 3,
                      keyboardType: TextInputType.multiline,
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
                        backgroundColor: Color(0xFF44558C8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      onPressed: () async {
                        final instaService = InstaService();
                        final userId =
                            Provider.of<LoginService>(context, listen: false)
                                    .userInfo?['id'] ??
                                '';
                        await instaService.instaUpdate(
                          insta['id'],
                          userId,
                          controller.text,
                          _newImageFile != null
                              ? XFile(_newImageFile!.path)
                              : null,
                        );
                        fetchInstas();
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

  void _showDeleteConfirmationDialog(String instaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('Delete insta',
              style: TextStyle(
                fontSize: 20,
              )),
          content: SizedBox(
            width: 360,
            height: 120,
            child: Center(
              child: Text(
                'Are you sure you want to delete this insta?',
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
                await _deleteInsta(instaId);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      body: Center(
        child: Container(
          width: 360,
          child: Column(
            children: [
              SizedBox(height: 5),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: fetchInstas,
                  child: loading
                      ? Center(child: CircularProgressIndicator())
                      : GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 0,
                            mainAxisSpacing: 0,
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
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showInstaDialog();
        },
        backgroundColor: Color(0xFF44558C8),
        elevation: 0,
        shape: CircleBorder(),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
