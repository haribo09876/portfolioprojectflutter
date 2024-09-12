import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import '../services/login.dart';
import '../services/userInfo.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late String userId;
  late Future<Map<String, dynamic>> allData;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    final loginService = Provider.of<LoginService>(context, listen: false);
    userId = loginService.userInfo?['id'] ?? '';

    allData = Future.wait([
      UserService().userRead(userId),
      TweetService().tweetRead(userId),
      InstaService().instaRead(userId),
      ShopService().purchaseRead(userId)
    ]).then((responses) {
      return {
        'userData': responses[0],
        'tweetData': responses[1],
        'instaData': responses[2],
        'purchaseData': responses[3],
      };
    });
  }

  Future<void> userUpdate(
      String password, String name, String gender, int age) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    await UserService()
        .userUpdate(userId, password, name, gender, age, imageFile: image);
  }

  Future<void> userDelete() async {
    await UserService().userDelete(userId);
  }

  Future<void> tweetUpdate(String tweetId, String contents) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    await TweetService().tweetUpdate(tweetId, userId, contents, image);
  }

  Future<void> tweetDelete(String tweetId) async {
    await TweetService().tweetDelete(tweetId, userId);
  }

  Future<void> instaUpdate(String instaId, String contents) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    await InstaService().instaUpdate(instaId, userId, contents, image);
  }

  Future<void> instaDelete(String instaId) async {
    await InstaService().instaDelete(instaId, userId);
  }

  Future<void> purchaseUpdate(
      String purchaseId, String userId, double itemPrice) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    await ShopService().purchaseUpdate(purchaseId, userId, itemPrice, image);
  }

  void tweetDetailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tweet Detail'),
          content: Text('???'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined),
                  onPressed: () {
                    tweetUpdateDialog();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    tweetDeleteDialog();
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

  void instaDetailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Intsa Detail'),
          content: Text('???'),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined),
                  onPressed: () {
                    instaUpdateDialog();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline),
                  onPressed: () {
                    instaDeleteDialog();
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

  void purchaseDetailDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Purchase Detail'),
          content: Text('???'),
          actions: [
            IconButton(
              icon: Icon(Icons.refresh_outlined),
              onPressed: () {
                purchaseUpdateDialog();
              },
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

  void userUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('userUpdate'),
          content: Text('???'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                userUpdate(password, name, gender, age);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void tweetUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('tweetUpdate'),
          content: Text('???'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                tweetUpdate(tweetId, contents);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void instaUpdateDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('instaUpdate'),
          content: Text('???'),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                instaUpdate(instaId, contents);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void purchaseUpdateDialog() {
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
                purchaseUpdate(purchaseId, userId, itemPrice);
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

  void tweetDeleteDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text('Are you sure to delete this Tweet?'),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                tweetDelete();
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

  void instaDeleteDialog() {
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
                instaDelete();
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

          final user = userData[0];

          return SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: user['userImgURL'] != null
                            ? ClipOval(
                                child: Image.network(
                                  user['userImgURL']!,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.account_circle,
                                size: 40,
                                color: Colors.white,
                              ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['userName'] ?? 'No userName',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Text(
                                      user['userEmail'] ?? 'No userEmail',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${NumberFormat('###,###,###').format((user['userMoney'] - user['userSpend']) ?? 0)}원  ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.edit_outlined,
                              size: 17,
                            ),
                            onPressed: () {
                              _showEditDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                _buildSectionTitle('My Tweet', tweetData.length),
                SizedBox(height: 10),
                _buildHorizontalList(
                    tweetData, 'tweetContents', 'No TweetContents'),
                SizedBox(height: 20),
                _buildSectionTitle('My Insta', instaData.length),
                SizedBox(height: 10),
                _buildInstaImageList(instaData),
                SizedBox(height: 20),
                _buildSectionTitle('My Purchase', purchaseData.length),
                SizedBox(height: 10),
                _buildItemImageList(purchaseData),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    _showConfirmDialog();
                  },
                  child: Text(
                    'Delete Account',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title   ',
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w400, color: Colors.black),
          ),
          TextSpan(
            text: '$count',
            style: TextStyle(
                fontSize: 17, fontWeight: FontWeight.w400, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(
      List<Map<String, dynamic>> data, String key, String defaultValue) {
    return Container(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final tweet = data[index];
          return GestureDetector(
            onTap: () {
              _showDetailDialog(
                '',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(tweet['tweetContents'] ?? defaultValue),
                    if (tweet['tweetImgURL'] != null)
                      Image.network(
                        tweet['tweetImgURL'],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                  ],
                ),
              );
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
                  tweet[key] ?? defaultValue,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInstaImageList(List<Map<String, dynamic>> data) {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final insta = data[index];
          return GestureDetector(
            onTap: () {
              _showDetailDialog(
                '',
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      insta['instaImgURL'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Text(insta['instaContents'] ?? 'No Content'),
                  ],
                ),
              );
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
    );
  }

  Widget _buildItemImageList(List<Map<String, dynamic>> data) {
    return Container(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) {
          final item = data[index];
          return GestureDetector(
            onTap: () {
              _showDetailDialog(
                item['itemTitle'],
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.network(
                      item['itemImgURL'],
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    Text(item['itemContents'] ?? 'No Content'),
                  ],
                ),
                isItem: true,
              );
            },
            child: Container(
              width: 100,
              height: 150,
              margin: EdgeInsets.only(right: 1),
              color: Colors.grey,
              child: item['itemImgURL'] != null
                  ? Image.network(
                      item['itemImgURL'],
                      fit: BoxFit.cover,
                    )
                  : Icon(Icons.shopping_bag_outlined),
            ),
          );
        },
      ),
    );
  }
}
