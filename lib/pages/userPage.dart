import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/login.dart';
import '../services/userInfo.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  late String userId;
  late Future<Map<String, dynamic>> allData;

  @override
  void initState() {
    super.initState();

    final loginService = Provider.of<LoginService>(context, listen: false);
    userId = loginService.userInfo?['id'] ?? '';

    allData = Future.wait([
      UserService().userRead(userId),
      TweetService().tweetRead(userId),
      InstaService().instaRead(userId),
      ShopService().itemRead(userId)
    ]).then((responses) {
      return {
        'userData': responses[0],
        'tweetData': responses[1],
        'instaData': responses[2],
        'itemData': responses[3],
      };
    });
  }

  void onAvatarChange() {
    print('Avatar change clicked');
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit'),
          content: Text('Here is Edit Dialog'),
          actions: [
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

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text(
            'Are you sure to delete this Account?'
            '\n\nor\n\nAre you sure to delete this Tweet?'
            '\n\nor\n\nAre you sure to delete this Insta?',
            textAlign: TextAlign.left,
          ),
          actions: [
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
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

  void _showDetailDialog(String title, Widget content, {bool isItem = false}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: content,
          actions: [
            if (isItem)
              TextButton(
                child: Text('Refund'),
                onPressed: () {
                  _showConfirmDialog();
                },
              )
            else
              IconButton(
                icon: Icon(Icons.edit_outlined),
                onPressed: () {
                  _showEditDialog();
                },
              ),
            if (!isItem)
              IconButton(
                icon: Icon(Icons.delete_outline),
                onPressed: () {
                  _showConfirmDialog();
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
          final itemData =
              snapshot.data!['itemData'] as List<Map<String, dynamic>>;

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
                      onTap: onAvatarChange,
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
                    SizedBox(width: 8),
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
                              size: 15,
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
                _buildSectionTitle('My Tweet'),
                _buildHorizontalList(
                    tweetData, 'tweetContents', 'No TweetContents'),
                SizedBox(height: 20),
                _buildSectionTitle('My Insta'),
                _buildInstaImageList(instaData),
                SizedBox(height: 20),
                _buildSectionTitle('My Item'),
                _buildItemImageList(itemData),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
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
