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
  late Future<List<Map<String, dynamic>>> userData;
  late Future<List<Map<String, dynamic>>> instaData;
  late Future<List<Map<String, dynamic>>> tweetData;
  late Future<List<Map<String, dynamic>>> itemData;

  @override
  void initState() {
    super.initState();

    final loginService = Provider.of<LoginService>(context, listen: false);
    userId = loginService.userInfo?['id'] ?? '';
    userData = UserService().userRead(userId);
    instaData = InstaService().instaRead(userId);
    tweetData = TweetService().tweetRead(userId);
    itemData = ShopService().itemRead(userId);
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<Map<String, dynamic>>>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('User 내역이 없습니다'));
                } else {
                  final data = snapshot.data!;
                  final user = data[0];

                  return Row(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                  );
                }
              },
            ),
            SizedBox(height: 20),
            Text(
              'My Tweet',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            Container(
              height: 80,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: tweetData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Tweet 내역이 없습니다'));
                  } else {
                    final data = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final tweet = data[index];
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
                              tweet['tweet'] ?? 'No Tweet',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'My Insta',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            Container(
              height: 100,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: instaData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Insta 내역이 없습니다'));
                  } else {
                    final data = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final insta = data[index];
                        return Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(right: 1),
                          color: Colors.grey,
                          child: insta['photo'] != null
                              ? Image.network(
                                  insta['photo'],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    'No Image',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              'My Item',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
            SizedBox(height: 8),
            Container(
              height: 150,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: itemData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('Item 내역이 없습니다'));
                  } else {
                    final data = snapshot.data!;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Container(
                          width: 100,
                          height: 100,
                          margin: EdgeInsets.only(right: 2),
                          color: Colors.grey,
                          child: item['itemImg'] != null
                              ? Image.network(
                                  item['itemImg'],
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    'No Image',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  ),
                                ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Text(
              '회원 탈퇴',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
