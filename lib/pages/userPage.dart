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
      InstaService().instaRead(userId),
      TweetService().tweetRead(userId),
      ShopService().itemRead(userId)
    ]).then((responses) {
      return {
        'userData': responses[0],
        'instaData': responses[1],
        'tweetData': responses[2],
        'itemData': responses[3],
      };
    });
  }

  void onAvatarChange() {
    print('Avatar change clicked');
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
          final instaData =
              snapshot.data!['instaData'] as List<Map<String, dynamic>>;
          final tweetData =
              snapshot.data!['tweetData'] as List<Map<String, dynamic>>;
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
                              Icons.edit,
                              size: 15,
                            ),
                            onPressed: () {
                              print('userEdit clicked');
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
                Text(
                  '회원 탈퇴',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
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
          final item = data[index];
          return Container(
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
                item[key] ?? defaultValue,
                style: TextStyle(color: Colors.black, fontSize: 12),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
          final item = data[index];
          return Container(
            width: 100,
            height: 100,
            margin: EdgeInsets.only(right: 1),
            color: Colors.grey,
            child: item['instaImgURL'] != null
                ? Image.network(
                    item['instaImgURL'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      'No Image',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
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
          return Container(
            width: 100,
            height: 150,
            margin: EdgeInsets.only(right: 1),
            color: Colors.grey,
            child: item['itemImgURL'] != null
                ? Image.network(
                    item['itemImgURL'],
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      'No Image',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
          );
        },
      ),
    );
  }
}
