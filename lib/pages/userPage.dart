import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../routes.dart';
import '../services/login.dart';
import '../services/userInfo.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late String userId;
  late Future<Map<String, dynamic>> allData;
  XFile? selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final loginService = Provider.of<LoginService>(context);
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    userId = args?['userId'] ?? loginService.userInfo?['id'] ?? '';
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      allData = Future.wait([
        UserService().userRead(userId),
        TweetService().tweetRead(userId),
        InstaService().instaRead(userId),
        ShopService().purchaseRead(userId),
      ]).then((responses) {
        return {
          'userData': responses[0],
          'tweetData': responses[1],
          'instaData': responses[2],
          'purchaseData': responses[3],
        };
      });
    });
  }

  Future<void> userUpdate(String userPassword, String userName,
      String userGender, dynamic userAge, XFile? userImgFile) async {
    await UserService().userUpdate(
        userPassword, userName, userGender, userAge, userImgFile, userId);
    _fetchData();
  }

  Future<void> userDelete() async {
    await UserService().userDelete(userId);
    Navigator.pushReplacementNamed(context, AppRoutes.intro);
  }

  Future<void> tweetUpdate(
      String tweetId, String tweetContents, XFile? imageFile) async {
    await TweetService().tweetUpdate(tweetId, userId, tweetContents, imageFile);
    _fetchData();
  }

  Future<void> tweetDelete(String tweetId) async {
    await TweetService().tweetDelete(tweetId, userId);
    _fetchData();
  }

  Future<void> instaUpdate(
      String instaId, String instaContents, XFile? imageFile) async {
    await InstaService().instaUpdate(instaId, userId, instaContents, imageFile);
    _fetchData();
  }

  Future<void> instaDelete(String instaId) async {
    await InstaService().instaDelete(instaId, userId);
    _fetchData();
  }

  Future<void> purchaseUpdate(String purchaseId, dynamic itemPrice) async {
    double price = (itemPrice is int) ? itemPrice.toDouble() : itemPrice;
    await ShopService().purchaseUpdate(purchaseId, userId, price);
    _fetchData();
  }

  void tweetDetailDialog(BuildContext context, String tweetContents,
      String? tweetImgURL, String tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tweet Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tweetContents),
              if (tweetImgURL != null)
                Image.network(
                  tweetImgURL,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined),
                  onPressed: () {
                    Navigator.of(context).pop();
                    tweetUpdateDialog(tweetId, tweetContents);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    Navigator.of(context).pop();
                    tweetDeleteDialog(tweetId);
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void instaDetailDialog(BuildContext context, String instaId,
      String instaContents, String instaImgURL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Insta Detail'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                instaImgURL,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              Text(instaContents.isNotEmpty ? instaContents : 'No Content'),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined),
                  onPressed: () {
                    instaUpdateDialog(instaId, instaContents);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    instaDeleteDialog(instaId);
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void purchaseDetailDialog(
    BuildContext context,
    String itemTitle,
    String itemImgURL,
    String itemContents,
    String purchaseId,
    dynamic itemPrice,
    dynamic purchaseStatus,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(itemTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.network(
                itemImgURL,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
              ),
              SizedBox(height: 8),
              Text(itemContents.isNotEmpty ? itemContents : 'No Content'),
              SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${NumberFormat('###,###,###').format(itemPrice)}원',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                purchaseStatus == 1
                    ? TextButton(
                        child: Text('Refund'),
                        onPressed: () {
                          purchaseUpdateDialog(purchaseId, itemPrice);
                        },
                      )
                    : Text('Refund Completed',
                        style: TextStyle(color: Colors.red)),
                TextButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void userUpdateDialog(String userPassword, String userName, String userGender,
      dynamic userAge, String userImgURL) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController nameController =
            TextEditingController(text: userName);
        TextEditingController passwordController =
            TextEditingController(text: userPassword);
        TextEditingController ageController =
            TextEditingController(text: userAge.toString());
        final Map<String, String> _genderOptions = {
          'Male': '남성',
          'Female': '여성',
        };
        String? selectedGender = userGender ?? 'Male';

        return AlertDialog(
          title: Text('Update User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: userImgURL != null
                            ? ClipOval(
                                child: Image.network(
                                  userImgURL,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(),
                      ),
                    ),
                    SizedBox(height: 5),
                    IconButton(
                      icon: Icon(
                        Icons.photo_outlined,
                        size: 20,
                      ),
                      onPressed: () async {
                        XFile? pickedImage = await _picker.pickImage(
                            source: ImageSource.gallery);
                        setState(() {
                          selectedImage = pickedImage;
                        });
                      },
                    ),
                  ],
                ),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Nickname'),
                controller: nameController,
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Password'),
                controller: passwordController,
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: selectedGender,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
                items: _genderOptions.entries
                    .map((entry) => DropdownMenuItem(
                          child: Text(entry.value),
                          value: entry.key,
                        ))
                    .toList(),
              ),
              TextField(
                decoration: InputDecoration(labelText: 'Age'),
                controller: ageController,
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text('Update'),
              onPressed: () {
                userUpdate(
                  passwordController.text,
                  nameController.text,
                  selectedGender ?? userGender,
                  int.tryParse(ageController.text) ?? userAge,
                  selectedImage,
                );
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void tweetUpdateDialog(String tweetId, String tweetContents) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _controller =
            TextEditingController(text: tweetContents);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Tweet'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Tweet Content',
                    ),
                    maxLines: 3,
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                      }
                    },
                    child: Text('Add Image'),
                  ),
                  SizedBox(height: 10),
                  if (selectedImage != null)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: IconButton(
                              icon: Icon(Icons.cancel,
                                  color: Colors.red, size: 30),
                              onPressed: () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Update'),
                  onPressed: () async {
                    await tweetUpdate(tweetId, _controller.text, selectedImage);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void instaUpdateDialog(String instaId, String instaContents) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController _controller =
            TextEditingController(text: instaContents);
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Insta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedImage != null)
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: 200,
                        maxWidth: double.infinity,
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(selectedImage!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: IconButton(
                              icon: Icon(Icons.cancel,
                                  color: Colors.red, size: 30),
                              onPressed: () {
                                setState(() {
                                  selectedImage = null;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () async {
                      final XFile? image =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                      }
                    },
                    child: Text('Add Image'),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Insta Content',
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Update'),
                  onPressed: () async {
                    await instaUpdate(instaId, _controller.text, selectedImage);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void purchaseUpdateDialog(String purchaseId, dynamic itemPrice) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure to refund this Item?'),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                purchaseUpdate(purchaseId, itemPrice);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void userDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure to delete this Account?'),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                userDelete();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void tweetDeleteDialog(String tweetId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure you want to delete this Tweet?'),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                tweetDelete(tweetId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void instaDeleteDialog(String instaId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure to delete this Insta?'),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                instaDelete(instaId);
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Page'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: allData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return Center(child: Text('데이터가 없습니다'));
          }
          final userData =
              snapshot.data!['userData'] as List<Map<String, dynamic>>;
          final tweetData =
              snapshot.data!['tweetData'] as List<Map<String, dynamic>>;
          final instaData =
              snapshot.data!['instaData'] as List<Map<String, dynamic>>;
          final purchaseData =
              snapshot.data!['purchaseData'] as List<Map<String, dynamic>>;
          if (userData.isEmpty) {
            return Center(child: Text('User 내역이 없습니다'));
          }
          return _buildContent(userData, tweetData, instaData, purchaseData);
        },
      ),
    );
  }

  Widget _buildContent(
    List<Map<String, dynamic>> userData,
    List<Map<String, dynamic>> tweetData,
    List<Map<String, dynamic>> instaData,
    List<Map<String, dynamic>> purchaseData,
  ) {
    final user = userData[0];
    final userEmail = user['userEmail'];
    final userPassword = user['userPassword'];
    final userName = user['userName'];
    final userGender = user['userGender'];
    final userAge = user['userAge'];
    final userImgURL = user['userImgURL'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  GestureDetector(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(60),
                      ),
                      child: user['userImgURL'] != null
                          ? ClipOval(
                              child: Image.network(
                                user['userImgURL']!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.account_circle,
                              size: 60,
                              color: Colors.white,
                            ),
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    user['userName'] ?? 'No userName',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(52, 52, 52, 52),
                    ),
                  ),
                  Text(
                    user['userEmail'] ?? 'No userEmail',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color.fromRGBO(89, 89, 89, 89),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              Spacer(),
              Text(
                '${NumberFormat('###,###,###').format((user['userMoney'] - user['userSpend']) ?? 0)}원',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color.fromRGBO(52, 52, 52, 52),
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(width: 10),
            ],
          ),
          sectionTweet(tweetData),
          SizedBox(height: 20),
          sectionInsta(instaData),
          SizedBox(height: 20),
          sectionPurchase(purchaseData),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF44558C8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () {
              userUpdateDialog(
                  userPassword, userName, userGender, userAge, userImgURL);
            },
            child: SizedBox(
              width: 360,
              child: Center(
                child: Text(
                  'Edit account',
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
              backgroundColor: Color(0xFFF04452),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            onPressed: () {
              userDeleteDialog();
            },
            child: SizedBox(
              width: 360,
              child: Center(
                child: Text(
                  'Delete account',
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
      ),
    );
  }

  Widget sectionTweet(List<Map<String, dynamic>> tweetData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Text(
                'My Tweet   ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              Text(
                '${tweetData.length}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: tweetData.length,
            itemBuilder: (context, index) {
              final tweet = tweetData[index];
              final tweetContents = tweet['tweetContents'];
              final tweetImgURL = tweet['tweetImgURL'];
              final tweetId = tweet['tweetId'];
              return GestureDetector(
                onTap: () {
                  tweetDetailDialog(
                      context, tweetContents, tweetImgURL, tweetId);
                },
                child: Container(
                  width: 120,
                  height: 80,
                  margin: EdgeInsets.only(right: 2),
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 1),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      tweet['tweetContents'] ?? '',
                      style: TextStyle(color: Colors.black, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget sectionInsta(List<Map<String, dynamic>> instaData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Text(
                'My Insta   ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              Text(
                '${instaData.length}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: instaData.length,
            itemBuilder: (context, index) {
              final insta = instaData[index];
              final instaContents = insta['instaContents'];
              final instaImgURL = insta['instaImgURL'];
              final instaId = insta['instaId'];
              return GestureDetector(
                onTap: () {
                  instaDetailDialog(
                      context, instaId, instaContents, instaImgURL);
                },
                child: Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(right: 1),
                  color: Colors.grey,
                  child: insta['instaImgURL'] != null
                      ? Image.network(
                          insta['instaImgURL'],
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.camera_alt_outlined),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget sectionPurchase(List<Map<String, dynamic>> purchaseData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              Text(
                'My Purchase   ',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              Text(
                '${purchaseData.length}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w400,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: purchaseData.length,
            itemBuilder: (context, index) {
              final purchase = purchaseData[index];
              final itemTitle = purchase['itemTitle'];
              final itemImgURL = purchase['itemImgURL'];
              final itemContents = purchase['itemContents'];
              final purchaseId = purchase['purchaseId'];
              final itemPrice = purchase['itemPrice'];
              final purchaseStatus = purchase['purchaseStatus'];
              return GestureDetector(
                onTap: () {
                  purchaseDetailDialog(context, itemTitle, itemImgURL,
                      itemContents, purchaseId, itemPrice, purchaseStatus);
                },
                child: Container(
                  width: 100,
                  height: 150,
                  margin: EdgeInsets.only(right: 1),
                  color: Colors.grey,
                  child: purchase['itemImgURL'] != null
                      ? Image.network(
                          purchase['itemImgURL'],
                          fit: BoxFit.cover,
                        )
                      : Icon(Icons.camera_alt_outlined),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
